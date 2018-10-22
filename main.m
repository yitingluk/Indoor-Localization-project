close all
clc
clear all

%% load data 
data=load('EE4C03_indoor_loc.mat');
Beacon_frequency=data.Beacon_frequency;
Sampling_frequency=data.Sampling_frequency;
X_true=data.X_true;
Y_true=data.Y_true;
mic_loc=data.mic_loc;
recording_time_samples_mic=data.recording_time_samples_mic;
reference_beacon=data.reference_beacon;
soundspeed=data.soundspeed;

%% mic_loc visualization
x_loc=mic_loc(:,1);
y_loc=mic_loc(:,2);
z_loc=mic_loc(:,3);
figure(1)
stem3(x_loc,y_loc,z_loc)
xlabel('x[cm]');
ylabel('y[cm]');
zlabel('z[cm]');
title('Microphone Location');

%% reference beacon visualization
delta_time=1/Sampling_frequency;
n_samples=length(reference_beacon);
reference_time=(0:n_samples-1)*delta_time*1000;
figure(2)
plot(reference_time, reference_beacon);
title('Reference Beacon');
xlabel('time(ms)');
ylabel('amplitude');
grid on

%% recording visualization
n_samples=size(recording_time_samples_mic,1);
len_samples=size(recording_time_samples_mic,2);
recording_time=(0:len_samples-1)*delta_time;
n_mic=size(recording_time_samples_mic,3);
figure(3)
for i=1:n_mic
    subplot(n_mic,1,i)
    plot(recording_time,recording_time_samples_mic(1,:,i))
    title(['received signal (microphone' num2str(i) ')']);
    xlabel('time[s]');
    ylabel('amplitude');
end

%% estimation of time delay
% optimum filter: digital Wiener filter
% x(n)=g(n)*d(n)+v(n)
% solution: w=Rx^(-1)*rdx
d=zeros(4800,1);
d(1:500)=reference_beacon;
d=[d;d];
for i=1:n_mic
    for j=1:n_samples
        x=recording_time_samples_mic(j,:,i);
        Rx=xcorr(x,x);
        Rx=Rx(9600:end);
        Rx=toeplitz(Rx);
        rdx=xcorr(x,d);
        rdx=rdx(9600:end);
        w(i,j,:)=Rx^(-1)*rdx';
        ww=reshape(w(i,j,:),[len_samples,1]);
%         figure
%         plot(recording_time,abs(ww));
    end
end

%% calculate TDOA

%% estimation of location

%% outlier removal