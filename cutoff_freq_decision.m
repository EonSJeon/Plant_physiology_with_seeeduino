% Define the folder containing your CSV files
folderPath = './Action Potential Data/';

% Directory for saving figures
figuresDir = './Action Potential Figures/';
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
        %filteredVoltage = filtfilt(d, voltage);
        filteredVoltage= voltage;
        
        % Plot the filtered data in the time domain
        figTimeDomain = figure;
        plot(time, filteredVoltage);
        title(['Time Domain for ', csvFiles(k).name]);
        xlabel('Time (s)');
        ylabel('Voltage (V)');
        
        % Save the time domain figure
        saveas(figTimeDomain, fullfile(figuresDir, [csvFiles(k).name(1:end-4), '_TimeDomain.jpg']), 'jpeg');
        
        % Perform FFT on the filtered voltage data
        Y = fft(filteredVoltage);
        
        % Calculate the number of points
        N = length(Y);
        
        % Calculate the frequency domain
        f = (0:N-1)*(Fs/N);
        
        % Take the magnitude of the FFT
        Y_magnitude = abs(Y);
        
        % Plot the magnitude of the FFT in a new figure
        figFreqDomain = figure;
        plot(f, Y_magnitude);
        title(['Magnitude of FFT for ', csvFiles(k).name]);
        xlim([0 80]);
        xlabel('Frequency (Hz)');
        ylabel('|Y(f)|');
        
        % Save the frequency domain figure
        saveas(figFreqDomain, fullfile(figuresDir, [csvFiles(k).name(1:end-4), '_FreqDomain.jpg']), 'jpeg');
    else
        fprintf('Skipping %s due to missing data.\n', csvFiles(k).name);
    end
end

% Note: Ensure the folderPath and figuresDir are correctly set to the paths where your CSV files are located and where you want to save the figures.
