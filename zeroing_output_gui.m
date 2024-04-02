function delayConst = zeroing_output_gui(base_freq, freq)
    % Ensure freq does not violate Nyquist theorem
    MAX = 2^16;
    port = '/dev/cu.usbmodem101'; % Update with your actual port
    device = serialport(port, 9600);
    if (freq > base_freq)
        error('Violate Nyquist thm.');
    end

    % Use a persistent variable for waitInterval to be able to update it in real-time
    persistent waitInterval
    delayConst = 0.88; % Initial delayConst value
    waitInterval = 1 / base_freq * delayConst; % Initialize waitInterval

    % Create the figure for GUI
    fig = figure('Name', 'Adjust Delay Constant', 'Position', [100, 100, 400, 200]);

    % Ensure 'fig' is recognized as a figure handle
    if ~ishandle(fig) || ~strcmp(get(fig, 'Type'), 'figure')
        error('Failed to create figure properly.');
    end

    % Create the slider
    slider = uicontrol('Parent', fig, 'Style', 'slider', 'Position', [100, 50, 200, 20], ...
        'value', delayConst, 'min', 0.5, 'max', 1, 'SliderStep', [0.01 0.1]);
    addlistener(slider, 'ContinuousValueChange', @(src, evt) updateDelayConst(src, evt));

    % Label for the slider
    uicontrol('Parent', fig, 'Style', 'text', 'Position', [100, 75, 200, 20], ...
        'String', 'Delay Constant (0.5 to 1)');

    % Listener for slider changes to update delayConst and waitInterval in real-time
    function updateDelayConst(src, ~)
        delayConst = get(src, 'Value');
        waitInterval = 1 / base_freq * delayConst;
    end

    % Start the signaling process
    sendSignal();

    function sendSignal()
        period = 1 / freq;
        t = linspace(0, period, period * base_freq);
        data_1T = MAX * ((square(2 * pi * freq * t, 50) + 1) / 2);

        i = 1;
        while ishandle(fig)
            write(device, data_1T(i), 'uint16');
            pause(waitInterval);
            i = i + 1;
            if i > length(data_1T)
                i = 1;
            end
        end
    end


    % Return the last value of delayConst after the GUI has been closed
end
