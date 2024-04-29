% BYB_Recording_2024-03-06_13.37.09 - 2nd.csv	p5-actpot1.txt					p5-actpot4a.txt
% BYB_Recording_2024-03-06_13.37.09.wav		p5-actpot2.png					p5-actpot4b.csv
% BYB_Recording_2024-03-06_13.37.09_1st.csv	p5-actpot2.txt					p5-actpot4b.txt
% actionpotential2.bmp				p5-actpot3.csv					p5-actpot5.csv
% actionpotential2.txt				p5-actpot3.txt					p5-actpot5.png
% lockedopen1.csv					p5-actpot4.png					p5-actpot5.txt
% noninvasive1.csv				p5-actpot4.txt					p5-actpot5a.txt
% p5-actpot1.csv					p5-actpot4a.png

% Filtered_BYB_Recording_2024-03-06_13.37.09 - 2nd.csv	Filtered_noninvasive1.csv				Filtered_p5-actpot4b.csv
% Filtered_BYB_Recording_2024-03-06_13.37.09_1st.csv	Filtered_p5-actpot1.csv					Filtered_p5-actpot5.csv
% Filtered_lockedopen1.csv				Filtered_p5-actpot3.csv


port = '/dev/cu.usbmodem101'; % Update with your actual port
device = serialport(port, 9600);
mV_TO_UINT16_CONST=2^16/3410;
AP_AMP_CONST=300;

% Path to the CSV file
csvFilePath = 'example.csv';
%csvFilePath = './Filtered Action Potential Data/Filtered_noninvasive1.csv'; % Update with the actual path to your CSV file

% Read data from the CSV file
data = readmatrix(csvFilePath, 'OutputType', 'double');
timeStamps = data(:, 1); % Assuming the first column contains time stamps
sig_mV = data(:, 2)*1000; % Assuming the second column contains sine wave values
sineWave= 1300+sig_mV;%*AP_AMP_CONST;

% Convert the sineWave values and time intervals to a suitable format
timeIntervals = diff(timeStamps);
timeIntervals(end+1) = mean(timeIntervals); % Add an average value for the last sample
timeIntervals_ms = uint16(timeIntervals * 1000); % Convert to milliseconds

% Combine values and intervals into a single array for transmission
dataToSend = zeros(2 * length(sineWave), 1, 'uint16');
dataToSend(1:2:end) = uint16(sineWave * mV_TO_UINT16_CONST); % Values
dataToSend(2:2:end) = timeIntervals_ms; % Time intervals

% Send the data length first
write(device, uint16(length(dataToSend)), 'uint16');
pause(0.1); % Give the Seeeduino time to process

length(dataToSend)

% Send the data
for i = 1:length(dataToSend)
    write(device, dataToSend(i), 'uint16');
    pause(0.005); % Short pause to avoid overwhelming the serial buffer
end

clear device;