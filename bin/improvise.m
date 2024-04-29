% Load the data from the CSV file
data = readtable('real_imp1.csv');

% Extract the columns into variables
Time = data.Time - min(data.Time);
Volt_In = data.Volt_In;
Volt_Out = data.Volt_Out;

% Create a figure for subplots
figure('Name', 'Impulse Response Plots', 'NumberTitle', 'off');

% Plot Time vs Volt_In in the upper subplot
subplot(2,1,2); % This means 2 rows, 1 column, 1st subplot
plot(Time, Volt_In, '-b'); % '-b' is for a solid blue line
title('Impulse Response');
xlabel('Time [ms]');
ylabel('Amplitude [mV]');
grid on;

% Plot Time vs Volt_Out in the lower subplot
subplot(2,1,1); % This means 2 rows, 1 column, 2nd subplot
plot(Time, Volt_Out, '-r'); % '-r' is for a solid red line
title('Impulse');
xlabel('Time [ms]');
ylabel('Amplitude [mV]');
grid on;

% Create a separate figure for combined plots
figure('Name', 'Combined Voltage Plot', 'NumberTitle', 'off');
plot(Time, Volt_In, '-b', 'DisplayName', 'Impulse Response'); % '-b' is for a solid blue line
hold on;
plot(Time, Volt_Out, '-r', 'DisplayName', 'Impulse'); % '-r' is for a solid red line
title('Impulse and Impulse Response');
xlabel('Time [ms]');
ylabel('Amplitude [mV]');
legend show;
grid on;