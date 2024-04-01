% Assuming global variables and device initialization are done above
% Setup code remains similar
serialInfo = serialportlist("available");
disp("Available Serial Ports:");
disp(serialInfo);

port = '/dev/cu.usbmodem101'; % Assuming the device is the first one
device = serialport(port, 9600);
configureTerminator(device, "CR/LF");

% Initialize global variables for sharing data and timestamps between callbacks
global dataBuffer timestampBuffer;
dataBuffer = [];
timestampBuffer = [];

global isRunning;
isRunning = true;

% Initialize plot
fig = figure;
h = plot(NaN,NaN); % Create an empty plot
hold on;
grid on;
xlabel('Time');
ylabel('Data Value');
title('Real-time Data from Seeeduino');

% Ensure global flags and buffers are initialized
global dataBuffer;
dataBuffer = [];
global isRunning;
isRunning = true;

% Data acquisition timer
dataTimer = timer;
dataTimer.Period = 1e-4; % Fast enough to catch your data rate
dataTimer.ExecutionMode = 'fixedRate';
dataTimer.TimerFcn = @(myTimerObj, thisEvent) acquireData(myTimerObj, thisEvent, device);

% Plotting timer
plotTimer = timer;
plotTimer.Period = 1; % Update the plot every second
plotTimer.ExecutionMode = 'fixedRate';
plotTimer.TimerFcn = @(myTimerObj, thisEvent) updatePlot(myTimerObj, thisEvent, h);

% Set CloseRequestFcn for the figure
fig.CloseRequestFcn = @(src, evnt)closeFigure(fig, dataTimer, plotTimer, device);

% Start timers
start(dataTimer);
start(plotTimer);

function acquireData(obj, event, device)
    global dataBuffer timestampBuffer;
    global isRunning;

    if ~isRunning
        stop(obj); % Optionally stop the timer if isRunning is false
        return;
    end

    try
        if device.NumBytesAvailable > 0
            value = readline(device);
            numericValue = str2double(value);
            if ~isnan(numericValue) % Ensure it's a number
                % Append new data
                dataBuffer = [dataBuffer, numericValue];
                % Capture and append timestamp
                timestampBuffer = [timestampBuffer, datetime('now')];
            end
        end
    catch ME
        disp(['Error reading data: ', ME.message]);
    end
end


function updatePlot(obj, event, h)
    global dataBuffer timestampBuffer;

    if ~isempty(dataBuffer)
        % Convert timestamps to a format that can be plotted
        % Here, we're assuming you want to plot against the time of day
        timeOfDay = datenum(timestampBuffer);

        % Update the plot
        h.YData = dataBuffer;
        h.XData = timeOfDay;

        % Adjust plot to show readable datetime ticks on the X-axis
        ax = gca; % Get current axes to adjust properties
        ax.XTick = linspace(min(timeOfDay), max(timeOfDay), 5); % Adjust number of ticks as needed
        datetick('x', 'HH:MM:SS', 'keepticks'); % Keep the ticks fixed but change the labels to HH:MM:SS format
        drawnow limitrate; % Use limitrate to improve performance
        
        % Calculate the average time step in seconds
        timeDiffs = diff(timestampBuffer); % Calculate differences between consecutive timestamps
        avg_time_step = mean(seconds(timeDiffs)); % Convert duration array to seconds and then calculate the mean
        disp(['Average time step (seconds): ', num2str(avg_time_step)]);
    end
end

function closeFigure(fig, dataTimer, plotTimer, device)
    global isRunning;
    isRunning = false; % Signal to stop data acquisition

    stop(dataTimer); % Stop the data acquisition timer
    delete(dataTimer); % Delete the timer object

    stop(plotTimer); % Stop the plotting timer
    delete(plotTimer); % Delete the timer object

    % Properly close and delete the serial port object
    if ~isempty(device) && isvalid(device)
        delete(device);
    end

    delete(fig); % Close the figure window
end

