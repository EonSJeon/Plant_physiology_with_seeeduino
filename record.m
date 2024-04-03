% Assuming global variables and device initialization are done at the start
serialInfo = serialportlist("available");
disp("Available Serial Ports:");
disp(serialInfo);

port = '/dev/cu.usbmodem101'; % Adjust as per your device connection
device = serialport(port, 9600);
configureTerminator(device, "CR/LF");

% Initialize global variables for data sharing between callbacks
global dataBuffer timestampBuffer isRunning;
dataBuffer = [];
timestampBuffer = [];
isRunning = true;

% Add to the initialization section
global startTime;
startTime = datetime('now');

global showLength
showLength=100;

% Initialize plot
fig = figure;
h = plot(NaN, NaN); % Initialize with an empty plot
hold on;
grid on;
xlabel('Time');
ylabel('Data Value');
title('Real-time Data from Seeeduino');

% Data acquisition timer setup
dataTimer = timer;
dataTimer.Period = 0.001; % Fast enough for most real-time applications
dataTimer.ExecutionMode = 'fixedRate';
dataTimer.TimerFcn = @(myTimerObj, thisEvent) acquireData(device);

% Plotting timer setup
plotTimer = timer;
plotTimer.Period = 1; % Plot update interval in seconds
plotTimer.ExecutionMode = 'fixedRate';
plotTimer.TimerFcn = @(myTimerObj, thisEvent) updatePlot(h);

% Close request function for figure
fig.CloseRequestFcn = @(src, evnt) closeFigure(fig, dataTimer, plotTimer, device);

% Start timers
start(dataTimer);
start(plotTimer);

function acquireData(device)
    global dataBuffer timestampBuffer isRunning startTime showLength;

    if ~isRunning
        return;
    end

    try
        while device.NumBytesAvailable > 0
            dataLine = readline(device);
            dataParts = strsplit(dataLine, ','); % Split data line at comma
            if length(dataParts) == 2
                millis = str2double(dataParts{1});
                numericValue = str2double(dataParts{2});
                if ~isnan(numericValue) && ~isnan(millis)
                    % Convert millis to elapsed seconds for timestamp
                    elapsedSeconds = millis / 1000;
                    % Append data and timestamp
                    dataBuffer = [dataBuffer, numericValue];
                    timestampBuffer = [timestampBuffer, elapsedSeconds];
                    
                    % Limit buffer to the last 1000 samples
                    if length(dataBuffer) > showLength
                        dataBuffer = dataBuffer(end-showLength+1:end);
                        timestampBuffer = timestampBuffer(end-showLength+1:end);
                    end
                end
            end
        end
    catch ME
        disp(['Error reading data: ', ME.message]);
    end
end


function updatePlot(h)
    global dataBuffer timestampBuffer;
    if ~isempty(dataBuffer)
        % Update plot data
        set(h, 'YData', dataBuffer, 'XData', timestampBuffer); % Directly use elapsedSeconds
        drawnow limitrate; % Improve performance
    end
end


function closeFigure(fig, dataTimer, plotTimer, device)
    global isRunning;
    isRunning = false; % Stop data acquisition

    stop(dataTimer);
    delete(dataTimer);

    stop(plotTimer);
    delete(plotTimer);

    % Close and delete serial port object
    if ~isempty(device) && isvalid(device)
        delete(device);
    end

    delete(fig); % Close figure window
end
