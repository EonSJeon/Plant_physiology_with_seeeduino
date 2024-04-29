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


% Constants
AP_AMP_CONST = 300;
OFFSET = 1300;
mV_TO_UINT16_CONST = 2^16 / 3410;

% Comment out the device setup as this requires the actual hardware to test
port = '/dev/cu.usbmodem101'; % Update with your actual port
device = serialport(port, 9600);

% CSV file path
csvFilePath = 'rect_wave.csv'; % Example path, adjust as needed

% Note: The `clear device` statement is commented out because it would disconnect
% the serial device. You might want to manage device connections differently.
% clear device

% Main function to play data from CSV on a serial device
function play(fileName, device, delayConst)
    % Validate delay constant
    if (delayConst <= 0 || delayConst > 1)
        error('Delay constant must be between 0 and 1 (exclusive).');
    end

    % Load data from the CSV file
    data = readmatrix(fileName, 'OutputType', 'double');
    
    % Calculate wait intervals based on timestamps
    timeStamps = data(:, 1);
    timeDifferences = diff(timeStamps);
    averageSamplingInterval = mean(timeDifferences);
    waitInterval = averageSamplingInterval * delayConst;

    % Prepare data for communication
    raw_data = data(:, 2); % Assuming the second column contains the raw values
    formattedData = formatDataComm(raw_data);

    % Iterate over the formatted data and write each value to the device
    for i = 1:length(formattedData)
        % Assuming 'device' and 'write' are defined and working with your setup
        % write(device, formattedData(i), 'uint16');
        
        % Wait before sending the next value
        if i < length(formattedData)
            pause(waitInterval);
        end
    end
end

% Function to format data for communication
function formatted = formatDataComm(data)
    % Convert data to millivolts, then adjust based on conditions
    data_mV = data;
    
    if (max(data_mV) - min(data_mV) < 100)
        data_mV = data_mV * AP_AMP_CONST;
    end
    
    if (any(data_mV < 0))
        data_mV = data_mV + OFFSET;
    end
    
    % Convert to uint16 for communication
    formatted = uint16(data_mV * mV_TO_UINT16_CONST);
end
