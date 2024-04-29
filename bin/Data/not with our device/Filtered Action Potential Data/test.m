% Parameters
Fs = 1000; % Sampling frequency in Hz
Fc = 50;  % Cutoff frequency in Hz
N = 5;    % Filter order

% Design a Butterworth low-pass filter
[b, a] = butter(N, Fc/(Fs/2), 'low')

% Initialize filter states to zero
z = filtic(b, a, []);

% Suppose 'newData' is a new chunk of data you receive periodically
% Apply the filter to new chunks of data as they arrive
[filteredData, z] = filter(b, a, newData, z);

function app = RealTimeFilterApp
    % Initialize the application and UI
    app.fig = uifigure('Name', 'Real-Time Data Filtering');
    app.ax = uiaxes(app.fig, 'Position', [100, 100, 600, 400]);
    grid(app.ax, 'on');
    hold(app.ax, 'on');
    
    % Initialize filter
    Fs = 1000; % Example sampling frequency
    Fc = 50;   % Cutoff frequency
    N = 5;     % Filter order
    [app.b, app.a] = butter(N, Fc/(Fs/2), 'low');
    app.z = filtic(app.b, app.a, []);
    
    % Simulate real-time data acquisition and filtering
    app.timer = timer('ExecutionMode', 'fixedRate', 'Period', 1/Fs, 'TimerFcn', @(src, event)updateData(app));
    start(app.timer);
end

function updateData(app)
    % Simulate acquiring new data point
    newData = sin(2*pi*0.1*now) + 0.5*randn; % Sample data generation

    % Filter the data
    [filteredData, app.z] = filter(app.b, app.a, newData, app.z);
    
    % Update the plot
    plot(app.ax, now, filteredData, 'bo');
end

