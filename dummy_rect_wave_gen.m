% Parameters
frequency = 100; % frequency of the square wave in Hz
sampleRate = 1000; % sample rate in Hz
duration = 30; % duration of the signal in seconds

% Generate the time vector
t = linspace(0, duration, duration * sampleRate);

% Generate the square wave
% The 'square' function generates a wave that oscillates between -1 and 1.
% The second argument to 'square' is the duty cycle, which we set to 50 for a standard square wave.
rectWave = square(2 * pi * frequency * t, 50);

% Combine the time stamps and square wave values
data = [t' rectWave'];

% Write to CSV file
csvwrite('rect_wave.csv', data);
