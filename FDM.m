%% =========================================================
% 3-Channel FDM Communication System
% Clean and Organized MATLAB Implementation
% =========================================================

clear; clc; close all;

%% =========================================================
% 1. SYSTEM PARAMETERS
% =========================================================

fs = 200e3;                 % Sampling frequency
t = 0:1/fs:0.005;           % Time vector (5 ms)

%% =========================================================
% 2. BASEBAND SIGNALS
% =========================================================

f1 = 1e3;
f2 = 2e3;
f3 = 3e3;

x1 = 1.00*sin(2*pi*f1*t);
x2 = 0.75*sin(2*pi*f2*t);
x3 = 0.50*sin(2*pi*f3*t);

%% =========================================================
% 3. CARRIER FREQUENCIES
% =========================================================

fc1 = 20e3;
fc2 = 40e3;
fc3 = 55e3;

%% =========================================================
% 4. MODULATION (FDM MULTIPLEXING)
% =========================================================

s1 = x1 .* cos(2*pi*fc1*t);
s2 = x2 .* cos(2*pi*fc2*t);
s3 = x3 .* cos(2*pi*fc3*t);

% Combined FDM signal
s = s1 + s2 + s3;

%% =========================================================
% 5. BANDPASS FILTERS FOR CHANNEL SEPARATION
% =========================================================

bw1 = 6e3;
bw2 = 10e3;
bw3 = 12e3;

[b1,a1] = butter(6,[(fc1-bw1/2)/(fs/2) (fc1+bw1/2)/(fs/2)],'bandpass');
[b2,a2] = butter(6,[(fc2-bw2/2)/(fs/2) (fc2+bw2/2)/(fs/2)],'bandpass');
[b3,a3] = butter(6,[(fc3-bw3/2)/(fs/2) (fc3+bw3/2)/(fs/2)],'bandpass');

% Low-pass filter for baseband recovery
[b_lpf,a_lpf] = butter(6,5e3/(fs/2),'low');

%% =========================================================
% 6. DEMULTIPLEXING PROCESS
% =========================================================

% Channel 1
ch1 = filtfilt(b1,a1,s);
d1 = ch1 .* 2 .* cos(2*pi*fc1*t);
x1_rec = filtfilt(b_lpf,a_lpf,d1);

% Channel 2
ch2 = filtfilt(b2,a2,s);
d2 = ch2 .* 2 .* cos(2*pi*fc2*t);
x2_rec = filtfilt(b_lpf,a_lpf,d2);

% Channel 3
ch3 = filtfilt(b3,a3,s);
d3 = ch3 .* 2 .* cos(2*pi*fc3*t);
x3_rec = filtfilt(b_lpf,a_lpf,d3);

%% =========================================================
% 7. TIME DOMAIN (Original vs Recovered)
% =========================================================

figure

subplot(3,2,1)
plot(t*1000,x1,'b','LineWidth',1.5)
title('Signal 1 - Original')
xlabel('Time (ms)')
ylabel('Amplitude')
grid on

subplot(3,2,2)
plot(t*1000,x1_rec,'r','LineWidth',1.5)
title('Signal 1 - Recovered')
xlabel('Time (ms)')
ylabel('Amplitude')
grid on

subplot(3,2,3)
plot(t*1000,x2,'b','LineWidth',1.5)
title('Signal 2 - Original')
xlabel('Time (ms)')
ylabel('Amplitude')
grid on

subplot(3,2,4)
plot(t*1000,x2_rec,'r','LineWidth',1.5)
title('Signal 2 - Recovered')
xlabel('Time (ms)')
ylabel('Amplitude')
grid on

subplot(3,2,5)
plot(t*1000,x3,'b','LineWidth',1.5)
title('Signal 3 - Original')
xlabel('Time (ms)')
ylabel('Amplitude')
grid on

subplot(3,2,6)
plot(t*1000,x3_rec,'r','LineWidth',1.5)
title('Signal 3 - Recovered')
xlabel('Time (ms)')
ylabel('Amplitude')
grid on


%% =========================================================
% 8. FREQUENCY DOMAIN ANALYSIS (Amplitude Corrected)
% =========================================================

nfft = 4096;

S  = fft(s,nfft);
X1 = fft(x1_rec,nfft);
X2 = fft(x2_rec,nfft);
X3 = fft(x3_rec,nfft);

f = fs*(0:nfft/2)/nfft;   % Single sided frequency axis

% Single sided magnitude
S_mag  = abs(S(1:nfft/2+1))/nfft;
X1_mag = abs(X1(1:nfft/2+1))/nfft;
X2_mag = abs(X2(1:nfft/2+1))/nfft;
X3_mag = abs(X3(1:nfft/2+1))/nfft;

% Correct amplitude
S_mag(2:end-1)  = 2*S_mag(2:end-1);
X1_mag(2:end-1) = 2*X1_mag(2:end-1);
X2_mag(2:end-1) = 2*X2_mag(2:end-1);
X3_mag(2:end-1) = 2*X3_mag(2:end-1);

figure

plot(f/1000,S_mag,'k','LineWidth',1.8)
hold on
plot(f/1000,X1_mag,'r','LineWidth',1.2)
plot(f/1000,X2_mag,'g','LineWidth',1.2)
plot(f/1000,X3_mag,'b','LineWidth',1.2)

xlim([0 80])

title('Frequency Spectrum of FDM System')
xlabel('Frequency (kHz)')
ylabel('Amplitude')

legend('FDM Signal','Recovered S1','Recovered S2','Recovered S3')

grid on