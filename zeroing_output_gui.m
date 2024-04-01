function zeroing_output_gui(base_freq, freq)
    % Ensure freq does not violate Nyquist theorem
    MAX=2^16;
    port = '/dev/cu.usbmodem101'; % Update with your actual port
    device = serialport(port, 9600);
    if (freq > base_freq)
        error('Violate Nyquist thm.');
    end

    % Initialize delayConst with a starting value
    delayConst = 0.5;

    % Create the figure for GUI
    fig = figure('Name', 'Adjust Delay Constant', 'Position', [100, 100, 400, 200]);

    % Create the slider
    slider = uicontrol('Parent', fig, 'Style', 'slider', 'Position', [100, 50, 200, 20], ...
        'value', delayConst, 'min', 0, 'max', 1);
    addlistener(slider, 'Value', 'PostSet', @(s,e) updateDelayConst());

    % Label for the slider
    uicontrol('Parent', fig, 'Style', 'text', 'Position', [100, 75, 200, 20], ...
        'String', 'Delay Constant (0 to 1)');

    function updateDelayConst()
        delayConst = get(slider, 'Value');
        if (delayConst <= 0 || delayConst >= 1)
            error('Delay constant must be between 0 and 1 (exclusive).');
        end

        sendSignal(); % Call the function to send the signal with the updated delayConst
    end

    function sendSignal()
        interval = 1 / base_freq;
        waitInterval = interval * delayConst;
        period = 1 / freq;

        t = linspace(0, period, period * base_freq);
        data_1T = MAX * ((square(2 * pi * freq * t, 50) + 1) / 2);

        while ishandle(fig) % Run as long as the GUI is open
            for i = 1:length(data_1T)
                write(device, data_1T(i), 'uint16');

                if i < length(data_1T)
                    pause(waitInterval); % Pause adjusted by the slider
                end
            end
        end
    end

    % Initial call to start the process
    sendSignal();
end
