% Define the folder containing your CSV files
folderPath = './Action Potential Data/';

% Directory for saving figures and filtered data
figuresDir = './Filtered Action Potential Data/';
if ~exist(figuresDir, 'dir')
    mkdir(figuresDir);
end

% List all CSV files in the folder
csvFiles = dir(fullfile(folderPath, '*.csv'));

% Loop through each file
for k = 1:length(csvFiles)
    fullPath = fullfile(folderPath, csvFiles(k).name);
    
    % Read the CSV file, skipping the first two header rows
    data = readtable(fullPath, 'HeaderLines', 2);
    
    % Extract time and voltage data
    time = data.Var1; % Assuming the first column is time
    voltage = data.Var2; % Assuming the second column is voltage
    
    % Check if the time and voltage are not empty
    if ~isempty(time) && ~isempty(voltage)
        % Assuming time is uniformly spaced, calculate sampling frequency
        Fs = 1/mean(diff(time)); % This calculates the mean sampling interval and then takes its reciprocal
        
        % Determine the appropriate cutoff frequency
        nyquistFreq = Fs / 2;
        cutoffFreq = min(30, nyquistFreq * 0.95); % Use 95% of Nyquist to ensure stability
        
        % Design a low-pass filter with the determined cutoff frequency
        d = designfilt('lowpassfir', 'FilterOrder', 100, ...
                       'CutoffFrequency', cutoffFreq, 'SampleRate', Fs);
        
        % Apply the filter
        filteredVoltage = filtfilt(d, voltage);
        
        % Create a table with the time and filtered voltage
        filteredData = table(time, filteredVoltage, 'VariableNames', {'Time', 'FilteredVoltage'});
        
        % Construct the filename for the filtered data
        filteredFileName = sprintf('Filtered_%s', csvFiles(k).name);
        
        % Full path for saving the filtered data CSV
        filteredFilePath = fullfile(figuresDir, filteredFileName);
        
        % Save the filtered data as a CSV file
        writetable(filteredData, filteredFilePath);
        
    else
        fprintf('Skipping %s due to missing data.\n', csvFiles(k).name);
    end
end

% Note: Ensure the folderPath and figuresDir are correctly set to the paths where your CSV files are located and where you want to save the filtered data.
