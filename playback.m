port = '/dev/cu.usbmodem101'; % Update with your actual port
s = serialport(port, 9600);

% Path to the CSV file
csvFilePath = 'example.csv'; % Update with the actual path to your CSV file

% Read data from the CSV file
data = readmatrix(csvFilePath, 'OutputType', 'double')
timeStamps = data(:, 1); % Assuming the first column contains time stamps
sineWave = data(:, 2); % Assuming the second column contains sine wave values

% Calculate the average sampling interval from the time stamps
timeDifferences = diff(timeStamps);
averageSamplingInterval = mean(timeDifferences);

% Convert the sampling interval to a sampling rate
sampleRate = 1 / averageSamplingInterval;

% Send sine wave samples
for i = 1:length(sineWave)
    value = uint16(sineWave(i)); % Assuming values are ready for DAC
    write(s, value, 'uint16');
    
    % If it's not the last sample, wait for the next sample time
    if i < length(sineWave)
        pause(timeDifferences(i)); % Wait until the next sample time
    end
end

clear s
