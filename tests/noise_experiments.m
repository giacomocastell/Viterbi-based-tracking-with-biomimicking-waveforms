clc;
clear;

global bathy BHOP_folder BHOP_title 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define scenario
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

drawplot=1;

depth_RX = -120;
var_depRX = 20;

bathy_offset = 25; % [m]
bathy_rand = 2.5; % random +/- value [m]

depth_TX = -120;

% Oscillation parameter
oscill_rad = 15; % [m]

BHOP_title = 'tempbellhop1';

BHOP_folder = [pwd() '/' 'tmp_bhop'];

load('bathymetry_SD.mat');

bathy_lon_max = -117.4720;
bathy_lat_min = 33.09;
bathy_lon_min = -117.5464;
bathy_lat_max = 33.16;

npoints = 251;
[X,Y] = meshgrid( linspace(bathy_lon_min,bathy_lon_max,npoints) , linspace(bathy_lat_min,bathy_lat_max,npoints) );
bathy = SanDiegoBathymetry(X,Y);
maxDepth = -min(min(bathy)); 

% Position of the transmitter
pos_TX = [-117.5352, 33.1120, depth_TX];

% Set position and depth of the receiver
upleft_rx_node_limit = [-117.5055 , 33.0395 ];
lowright_rx_node_limit = [ -117.4875, 33.2000 ];

% Draw receiver position at random

posRX_lon = rand(1,1)*(upleft_rx_node_limit(1)-lowright_rx_node_limit(1)) + lowright_rx_node_limit(1);
posRX_lat = rand(1,1)*(upleft_rx_node_limit(2)-lowright_rx_node_limit(2)) + lowright_rx_node_limit(2);
posRX_dep = max(depth_RX+(rand-0.5)*var_depRX, 0.8*SanDiegoBathymetry(posRX_lon,posRX_lat));

% Activate if want to select random position 
% pos_RX = [posRX_lon, posRX_lat, depth_RX];
pos_RX = [-117.5086, 33.1008, depth_RX];

% Extract a random position for the TX
% rand_pos_TX = zeros(1,2);
% [rand_pos_TX(1), rand_pos_TX(2)] = coord_given_start_bearing_and_dist(pos_TX(1), pos_TX(2), rand*oscill_rad, rand*360 );
% pos_TX = [ rand_pos_TX(1:2) , pos_TX(3) ];


% Draw map of area

if drawplot
    myOrange = [255, 136, 0]/255;
    myBlue = [0, 46, 255]/255;
    
    figure(1); clf;
    % Area map
    mesh(X,Y,SanDiegoBathymetry(X,Y)); colorbar;
    set(gcf,'Position',[680   493   637   471]);
    set(gca,'Position',[0.1621    0.1179    0.6681    0.8071]);
    set(gca,'View',[0 90]);
    xlim([bathy_lon_min, bathy_lon_max]);
    ylim([bathy_lat_min, bathy_lat_max]);
    hold on;
    
    txH = plot3(pos_TX(1), pos_TX(2), pos_TX(3),'dr','MarkerSize',10,'LineWidth',1,'MarkerFaceColor',myOrange);
    % Plot limits of receiver area
%     plot3([upleft_rx_node_limit(1) upleft_rx_node_limit(1)],[upleft_rx_node_limit(2) lowright_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
%     plot3([upleft_rx_node_limit(1) lowright_rx_node_limit(1)],[lowright_rx_node_limit(2) lowright_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
%     plot3([lowright_rx_node_limit(1) lowright_rx_node_limit(1)],[lowright_rx_node_limit(2) upleft_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
%     plot3([lowright_rx_node_limit(1) upleft_rx_node_limit(1)],[upleft_rx_node_limit(2) upleft_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
    
    % Receiver
    %%%%%% Convenient coordinates for plotting purposes
    rxH = plot3(pos_RX(1),pos_RX(2),pos_RX(3),'o','Color','White','MarkerFaceColor',myBlue,'MarkerSize',8,'LineWidth',1);

    legh = legend( [txH, rxH] , 'Transmitter', 'Receiver' );
    set(legh, 'EdgeColor', 'White', 'Box','Off');
    xlabel('Longitude [deg]');
    ylabel('Latitude [deg]');
    set(gca,'FontSize',14);
    set(gca,'XTick',[-117.4200 -117.4000 -117.3800 -117.3600]);
    set(gca,'XTickLabels',{'-117.42'; '-117.40'; '-117.38'; '-117.36'});
    set(get(gca,'XLabel'),'FontSize',16);
    set(get(gca,'YLabel'),'FontSize',16);
    annotation('Textbox',[0.82 0.92 0.2 0.07],'String','Depth [m]','FontSize',get(legh,'FontSize'),'EdgeColor','none')
    
end

fprintf('--- pos_TX (lon,lat,dep) = [%.7g %.7g %.7g]\n', pos_TX(1), pos_TX(2), pos_TX(3));
fprintf('--- pos_RX (lon,lat,dep) = [%.7g %.7g %.7g]\n', pos_RX(1), pos_RX(2), pos_RX(3));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate signal transmission and reception
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Inputs:
% position of transmitter and receiver, max depth, bathimetry file and
% boolean to draw, eventually, rays and arrivals
% Output: arrivals

Arr = bellhop_simulation(pos_TX, pos_RX, maxDepth, SanDiegoBathymetry);

% myChannel = [Arr' Arr.A.'];
% Delay(iT,iNode,jNode) = computeDelayFromChannel( myChannel );
% Delay(iT,jNode,3) = Delay(iT,iNode,jNode);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Compute channel impulse response
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Define transmitted signal
%%
biomimicking = 0;                     % Set to 1 if want to transmit bimimimicked signal, 0 if a chirp
A = 10e7;                             % Amplitude of the signal

if biomimicking
    [x,t,tau,fs] = biomimicked_signal_generation;
    f1 = 10e3;                        % To tune if use a new waveform  
    f2 = 15e3;                        % To tune if use a new waveform
    x = A*x;
else
    tau = 10e-3;                        % Duration of the pulse (10ms)
    fs = 100e3;                         % Sampling frequency (100kHz)
    t = 0:1/fs:tau-1/fs;                % Time axis
    f1 = 18e3;                          % Start frequency (18kHz)
    f2 = 34e3;                          % End frequency (34kHz)
    x = A*chirp(t,f1,tau,f2)';
end    

pref = 1e-6;                        % Reference rms for water [uPa] 

fprintf("Transmitted Sound Level: %.2f [dB re uPa]\n",20*log10(rms(x)/pref));

% Inputs: input signal and its time axis, sampling frequency, arrivals
% Outputs: impulse response and output signal, together with relative time axis

[h,t_h,y,t_y] = compute_impulse_response(x,t,fs,Arr,2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Process and visualize received signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compute spectrum of transmitted and received signals
xfft = fft(x,length(x));
freq_x = fs*(0:length(x)/2-1)/length(x);

yfft = fft(y, length(y));
freq_y = fs*(0:length(y)/2-1)/length(y);

% Extract received power
prx=rms(y);
y_SL = 20*log10(prx/pref); 

fprintf("Received Sound Level: %.2f [dB re uPa] \n",y_SL);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Introduce noise model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s=0;                                                % Ship parameter [0 to 1]
w=0;                                                % Wind speed [m/s]

kHz_normalization_factor = 1000;                    % Normalize into kHz
freq_y = freq_y/kHz_normalization_factor;

Nt = 17-30*log10(freq_y);
Ns = 40+20*(s-0.5)+26*log10(freq_y)-60*log10(freq_y+0.03);
Nw = 50+7.5*sqrt(w)+20*log10(freq_y)-40*log10(freq_y+0.4);
Nth = -15+20*log10(freq_y);
noise = sqrt(10.^(Nt/10) + 10.^(Ns/10) + 10.^(Nw/10) + 10.^(Nth/10)); % Square root of PSD
NdB=10*log10(noise.^2);                                               % PSD in dB

% Compute average power within the interval of interest (set to kHz)
guard = 5e3/kHz_normalization_factor;                                 % Guard band
f1kHz = f1/kHz_normalization_factor;
f2kHz = f2/kHz_normalization_factor;

% Noise power in the frequency interval
n_SL = sum(NdB(f1kHz-guard:f2kHz+guard))/length(NdB(f1kHz-guard:f2kHz+guard));
% Signal to noise ratio at the receiver
SNR = y_SL-n_SL; 

fprintf("SNR at the receiver: %.2f [dB re uPa] \n\n",SNR);

onesided_yfft = yfft(2:floor(length(y)/2));

% Plot spectrum
if drawplot
    figure;
    subplot(311);
    plot(freq_x*10^-3, mag2db(abs(xfft(1:floor(length(x)/2)))/(max(abs(xfft(1:floor(length(x)/2)))))));
    xlabel('Frequency [kHz]');
    ylabel('Magnitude [dB]');
    title('Normalized transmitted signal spectrum');
    subplot(312);
    plot(freq_y, mag2db(abs(yfft(1:floor(length(y)/2)))/(max(abs(yfft(1:floor(length(y)/2)))))));
    xlabel('Frequency [kHz]');
    ylabel('Magnitude [dB]');
    title('Normalized received signal spectrum');
    subplot(313)
    plot(freq_y(2:end), mag2db(abs(onesided_yfft+noise(2:end))/(max(abs(onesided_yfft+noise(2:end))))));
    xlabel('Frequency [kHz]');
    ylabel('Magnitude [dB]');
    title('Normalized received noisy signal spectrum');
end
