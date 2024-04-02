function serialPortSelector
    % Fetch available serial ports
    serialInfo = serialportlist("available");
    
    % Create a simple GUI for selecting a serial port
    fig = uifigure('Name', 'Serial Port Selector', 'Position', [100 100 300 150]);
    lbl = uilabel(fig, 'Position', [20 120 260 20], 'Text', 'Select a Serial Port:');
    dd = uidropdown(fig, 'Position', [20 90 260 20], 'Items', serialInfo, ...
        'ValueChangedFcn', @dropdownValueChanged);
    btn = uibutton(fig, 'Position', [100 20 100 30], 'Text', 'Connect', ...
        'ButtonPushedFcn', @(btn,event) connectSerialPort(dd.Value, fig));
end

function dropdownValueChanged(src, event)
    % Callback function for dropdown menu
    disp(['Selected port: ', src.Value]);
end

function connectSerialPort(port, fig)
    % Function to connect to the selected serial port and start data acquisition and plotting
    try
        device = serialport(port, 9600);
        configureTerminator(device, "CR/LF");
        disp(['Connected to ', port]);
        
        % After successful connection, start data acquisition and plotting
        initializeDataAcquisitionAndPlotting(device);
        
    catch ME
        % Handle errors, such as unable to connect to the port
        disp(['Error connecting to port ', port, ': ', ME.message]);
    end
end

function initializeDataAcquisitionAndPlotting(device)
    % Initialize global variables for sharing data and timestamps between callbacks
    global dataBuffer timestampBuffer;
    dataBuffer = [];
    timestampBuffer = [];
    
    global isRunning;
    isRunning = true;
    
    % Initialize plot
    fig = figure;
    h = plot(NaN, NaN); % Create an empty plot
    hold on;
    grid on;
    xlabel('Time');
    ylabel('Data Value');
    title('Real-time Data from Device');
    
    % Data acquisition timer
    dataTimer = timer;
    dataTimer.Period = 1e-4; % Fast enough to catch your data rate
    dataTimer.ExecutionMode = 'fixedRate';
    dataTimer.TimerFcn = @(myTimerObj, thisEvent) acquireData(myTimerObj, thisEvent, device);
    
    % Plotting timer
    plotTimer = timer;
    plotTimer.Period = 1; % Update the plot every second
    plotTimer.ExecutionMode = 'fixedRate';
    plotTimer.TimerFcn = @(myTimerObj, thisEvent) updatePlot(myTimerObj, thisEvent, h);
    
    % Set CloseRequestFcn for the figure
    fig.CloseRequestFcn = @(src, evnt)closeFigure(fig, dataTimer, plotTimer, device);
    
    % Start timers
    start(dataTimer);
    start(plotTimer);
end
