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
y
mV_TO_UINT16_CONST=2^16/3410;
AP_AMP_CONST=300;

% Path to the CSV file
csvFilePath = 'example.csv';
%csvFilePath = './Filtered Action Potential Data/Filtered_noninvasive1.csv'; % Update with the actual path to your CSV file

% Read data from the CSV file
data = readmatrix(csvFilePath, 'OutputType', 'double');
timeStamps = data(:, 1); % Assuming the first column contains time stamps
sig_mV = data(:, 2)*1000 % Assuming the second column contains sine wave values
sineWave= 1300+sig_mV;%*AP_AMP_CONST;
% Calculate the average sampling interval from the time stamps
timeDifferences = diff(timeStamps);
averageSamplingInterval = mean(timeDifferences);

% Convert the sampling interval to a sampling rate
sampleRate = 1 / averageSamplingInterval;

% Send sine wave samples
for i = 1:length(sineWave)
    value = uint16(sineWave(i)*mV_TO_UINT16_CONST);
    %disp(value);% Assuming values are ready for DAC
    write(device, value, 'uint16');
    
    % If it's not the last sample, wait for the next sample time
    % if i < length(sineWave)
    %     pause(timeDifferences(i)); % Wait until the next sample time
    % end
end

clear device
