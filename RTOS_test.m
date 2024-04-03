function RTOS_test()
    % Define serial commands as global variables
    global START END READ WRITE device
    
    START= 0xAA; % 1 byte
    END  = 0xFF; % 1 byte
    READ = 0x11; % 1 byte
    WRITE= 0x22; % 1 byte
    
    % Initialize the serial device
    port = '/dev/cu.usbmodem101'; % Change this to your actual serial port
    device = serialport(port, 9600);
    
    % Create a UI figure
    fig = uifigure('Name', 'Serial Communication', 'Position', [100, 100, 200, 150]);
    
    % Set CloseRequestFcn for the figure
    fig.CloseRequestFcn = @cleanupOnClose;
    
    % Create READ button
    readBtn = uibutton(fig, 'push', ...
                       'Text', 'READ', ...
                       'Position', [50, 100, 100, 22], ...
                       'ButtonPushedFcn', @(readBtn, event) sendReadCmd());
    
    % Create WRITE button
    writeBtn = uibutton(fig, 'push', ...
                        'Text', 'WRITE', ...
                        'Position', [50, 60, 100, 22], ...
                        'ButtonPushedFcn', @(writeBtn, event) sendWriteCmd());
    
    % Create END button
    endBtn = uibutton(fig, 'push', ...
                      'Text', 'END', ...
                      'Position', [50, 20, 100, 22], ...
                      'ButtonPushedFcn', @(endBtn, event) sendEndCmd());
end

% Callback functions for buttons
function sendReadCmd()
    global START END READ device
    write(device, END, 'uint8');
    write(device, END, 'uint8');
    write(device, END, 'uint8');
    write(device, END, 'uint8');
    write(device, START, 'uint8');
    write(device, START, 'uint8');
    write(device, START, 'uint8');
    write(device, READ, 'uint8');
end

function sendWriteCmd()
    global START END WRITE device
    sendSignal(END,4);
    sendSignal(START,4);
    sendSignal(WRITE,1);
end

function sendEndCmd()
    global END device
    sendSignal(END, 4);
end

% Utility function to send signals
function sendSignal(signal, count)
    global device
    for i = 1:count
        write(device, signal, 'uint8');
    end
end

% Cleanup function called when the UI is closed
function cleanupOnClose(src, event)
    global device
    delete(device);
    clear global device;
    delete(src);
end
