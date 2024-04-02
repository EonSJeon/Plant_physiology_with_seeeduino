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
    % Function to connect to the selected serial port
    try
        device = serialport(port, 9600);
        configureTerminator(device, "CR/LF");
        disp(['Connected to ', port]);
        % Store the device object in the figure's UserData for access elsewhere
        fig.UserData.device = device;
    catch ME
        % Handle errors, such as unable to connect to the port
        disp(['Error connecting to port ', port, ': ', ME.message]);
    end
end
