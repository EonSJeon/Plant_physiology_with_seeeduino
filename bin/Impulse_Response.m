%% The Impulse Response Program
% This script will wait for one data collection event from the arduino and
% then save the data as a csv

%% Connect to the seeduino device. Make sure you upload the correct program to the seeeduino first
clear

serialInfo = serialportlist("available");
disp("Available Serial Ports:");
disp(serialInfo);

%port = '/dev/cu.usbmodem101'; % Assuming the device is the first one,
%using mac
device = serialport("COM7", 9600); %assuming first port
configureTerminator(device, "CR/LF");

% Initialize global variables for sharing data and timestamps between callbacks
global dataMatrix data_string;
dataMatrix=[];
data_string="";
global isRunning;
isRunning = true;

%% Start recording the data coming in from the seeeduino


% Initialize plot
fig = figure;
subplot(2,1,2)
h = plot(NaN,NaN); % Create an empty plot
hold on;
grid on;
xlabel('Time');
ylabel('Data Value');
title('Real-time Data from Seeeduino');
hold off
subplot(2,1,1)
i= plot(NaN,NaN);
hold on;
grid on;
xlabel('Time');
ylabel('Data Value');
title('Real-time Data input to Seeeduino');



% Data acquisition timer setup
dataTimer = timer;
dataTimer.Period = 0.01; % Fast enough for most real-time applications
dataTimer.ExecutionMode = 'fixedRate';
dataTimer.TimerFcn = @(myTimerObj, thisEvent) update_data(device);

% Plotting timer setup
plotTimer = timer;
plotTimer.Period = 1; % Plot update interval in seconds
plotTimer.ExecutionMode = 'fixedRate';
plotTimer.TimerFcn = @(myTimerObj, thisEvent) updatePlot(h,i);



%% Loop to read data
write(device,0,"uint8");
pause(0.01);
flush(device);

% Start timers
start(dataTimer);
start(plotTimer);

while(1)
end

%% UPDATE FUNCTIONS
function update_data(device)
    global dataMatrix data_string;
    if(device.NumBytesAvailable>0)
        try
            string1 =read(device,device.NumBytesAvailable,"string");
            string=extractBetween(string1,";",";");
            matrix=double(split(string,","));
            if(size(matrix,2)~=3)
                matrix=transpose(matrix);
            end
            dataMatrix= [dataMatrix;matrix];
        catch error
            disp(["Error writing arrays: ",error.message, error.cause])
        end
    end
end
% function update_data(device)
%     global outputDataBuffer timestampBuffer inputDataBuffer;
%     data = device.readline();
%     if(data=="start")
%         start_index=length(timestampBuffer);
%     end
%     if(data=="end")
%         end_index=length(timestampBuffer);
%     end
%     values=data.split(",");
% 
% 
%     if(length(values)<3)
%        return;
%     end
% 
%     time=str2double(values(1));
%     numericValueO = str2double(values(2));
%     numericValueI = str2double(values(3));
% 
%     outputDataBuffer = [outputDataBuffer, numericValueO];
%     inputDataBuffer = [inputDataBuffer,numericValueI];
%     % Capture and append timestamp
%     timestampBuffer = [timestampBuffer, time];
% 
% end

function updatePlot(h,i)
    global dataMatrix;
    if ~isempty(dataMatrix)
        % Update plot data
        set(h, 'YData', dataMatrix(:,2), 'XData', dataMatrix(:,1)); % Directly use elapsedSeconds
        drawnow limitrate; % Improve performance
    end
    if ~isempty(dataMatrix)
        % Update plot data
        set(i, 'YData', dataMatrix(:,3), 'XData', dataMatrix(:,1)); % Directly use elapsedSeconds
        drawnow limitrate; % Improve performance
    end
end
