% Step 1: Read the CSV file into a table
data = readtable('Filtered_p5-actpot5.csv');

% Step 2: Multiply the 'FilteredVoltage' column by -1000
data.FilteredVoltage = data.FilteredVoltage * 1000 * 25;
data.FilteredVoltage = data.FilteredVoltage + 900;
data.Time = data.Time * 1000;


% Step 3: Write the modified table back to the CSV file
writetable(data, 'Filtered_p5-actpot5_modified.csv');  % Saving as a new file for safety

% If you want to overwrite the original file, use:
% writetable(data, 'Filtered_noninvasive1.csv');




% % Correctly read the CSV file into a table
% % Read the CSV file into a table
% data = readtable('Filtered_noninvasive1_modified.csv');
% 
% ts_ms = data.Time; % Assuming the timestamps are in milliseconds
% vs = data.FilteredVoltage;
% 
% % Convert timestamps from milliseconds to seconds for interpolation
% ts = ts_ms / 1000;
% 
% % Resample data
% [ts1, vs1] = resampleData(ts, vs, 120);
% 
% ts1=ts1*1000;
% [ts1', vs1']
% 
% % Plot resampled data
% figure;
% plot(ts1, vs1);
% xlabel('Time (s)');
% ylabel('Voltage (V)');
% title('Resampled Data');
% 
% 
% function [resampledTs, resampledVoltages] = resampleData(originalTs, originalVoltages, Fs)
%     % Ensure unique timestamps
%     [originalTs, ia] = unique(originalTs);
%     originalVoltages = originalVoltages(ia);
% 
%     % Calculate the total duration of the data
%     startTime = originalTs(1);
%     endTime = originalTs(end);
% 
%     % Calculate the sampling interval based on the desired sampling frequency
%     Ts = 1 / Fs;  % Sampling period in seconds
% 
%     % Create a new time vector with the desired sampling frequency
%     resampledTs = startTime:Ts:endTime;
% 
%     % Ensure the last element matches the end time
%     if resampledTs(end) ~= endTime
%         resampledTs = [resampledTs endTime];
%     end
% 
%     % Interpolate the original voltage values at the new timestamps
%     resampledVoltages = interp1(originalTs, originalVoltages, resampledTs, 'linear');
% end
