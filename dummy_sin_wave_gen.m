
% Parameters
frequency = 200; % frequency of the sine wave in Hz
sampleRate = 9600; % sample rate in Hz
duration = 10; % duration of the signal in seconds

% Generate the time vector
t = linspace(0, duration, duration * sampleRate);

% Generate the sine wave
sinWave = sin(2 * pi * frequency * t);

% Combine the time stamps and sine wave values
data = [t' sinWave'];

% Write to CSV file
csvwrite('example.csv', data);
