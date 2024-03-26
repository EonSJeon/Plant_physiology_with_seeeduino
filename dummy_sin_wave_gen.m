
% Parameters
frequency = 50; % frequency of the sine wave in Hz
sampleRate = 9600; % sample rate in Hz
duration = 1; % duration of the signal in seconds

% Generate the time vector
t = linspace(0, duration, duration * sampleRate);

% Generate the sine wave
sinWave = sin(2 * pi * frequency * t)*2^16;

% Combine the time stamps and sine wave values
data = [t' sinWave'];

% Write to CSV file
csvwrite('example.csv', data);
