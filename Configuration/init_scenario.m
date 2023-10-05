function [scenario_settings] = init_scenario()

%%%%%%%%%%%%%%%%%%%%%%
%%%% Define paths %%%%
%%%%%%%%%%%%%%%%%%%%%%

% Current directory
current_folder = pwd;

% Input path
scenario_settings.input_folder = fullfile(current_folder, 'Data/');

% Output path
scenario_settings.output_folder = fullfile(current_folder, '..' ,'Output/');

% Viterbi script location
scenario_settings.viterbi_path = fullfile(current_folder, 'viterbi.py');

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Bellhop settings %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set Bellhop global variables and paths
global bathy BHOP_folder BHOP_title 
BHOP_title = 'tempbellhop1';
BHOP_folder = 'tmp_bhop';

% Load bathymetry scenario
load( strcat (scenario_settings.input_folder, 'bathymetry_SD.mat'));

% Set bathymetry parameters
bathy_lon_max = -117.3520;
bathy_lat_min = 33.08;
bathy_lon_min = -117.4264;
bathy_lat_max = 33.15;
npoints = 251;
[X,Y] = meshgrid( linspace(bathy_lon_min,bathy_lon_max,npoints) , linspace(bathy_lat_min,bathy_lat_max,npoints) );
bathy = SanDiegoBathymetry(X,Y);
maxDepth = -min(min(bathy));

scenario_settings.maxDepth   = maxDepth;
scenario_settings.bathymetry = SanDiegoBathymetry;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Transmitter settings %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Pulses per second (Pulse repetition frequency, number of pulses per second) [Hz]
PRF = 1;

% Total transmission time [s]
total_time = 50;

% Total number of pulses
num_pulses = total_time*PRF;

% Temporal reference
timeaxis = 0:1/PRF:total_time-1;

scenario_settings.PRF        = PRF;
scenario_settings.total_time = total_time;
scenario_settings.num_pulses = num_pulses;
scenario_settings.timeaxis   = timeaxis;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Target settings %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

% Draw initial position of the transmitter/receiver
pos_TX = [-117.3992, 33.0924, -120];
pos_RX = [-117.3995, 33.0928, -120];

% Movement of the target
% How much the object moves at each pulse
lon_shift = 0.000001;   % [lon]
lat_shift = 0.000001;   % [lat]
dep_shift = 0.1;        % [m]

% Speed of the target amongst two transmissions
d = computeDistanceTXRX(pos_TX, pos_RX);
speed = (d/(1/PRF));

scenario_settings.pos_TX      = pos_TX;
scenario_settings.pos_RX_init = pos_RX;
scenario_settings.lon_shift   = lon_shift;
scenario_settings.lat_shift   = lat_shift;
scenario_settings.dep_shift   = dep_shift;
scenario_settings.speed       = speed;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Waveform settings %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 'chirp', 'biomimicking', 'airgun'
waveform_type = 'biomimicking'; 

% Desired SNR
SNRdB = 10;

scenario_settings.SNRdB = SNRdB;
scenario_settings.waveform_type = waveform_type;

%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Global settings %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

% Speed of sound [m/s]
c = 1520;

% Loss factor due to reflection
loss_factor = 0.1;

scenario_settings.c           = c;
scenario_settings.loss_factor = loss_factor;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Emission matrix settings %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Threshold to cut emission matrix in case it is too large
threshold = .8e4;

% Number of random targets calculations
num_iterations = 10;

% Variance of the random movement of the target
var_depRX = 20;

% Maximum shift from initial position of the target 
max_shift = 1e-5;

scenario_settings.num_iterations       = num_iterations;
scenario_settings.var_depRX            = var_depRX;
scenario_settings.max_shift            = max_shift;
scenario_settings.threshold            = threshold;

%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Output options %%%%
%%%%%%%%%%%%%%%%%%%%%%%%

% Option to compute emission matrix
scenario_settings.compute_emission_matrix = false;

% Option to store emission matrix
scenario_settings.save_emission_matrix = false;

% Option to run Viterbi
scenario_settings.run_viterbi = true;

% Option to store TD matrix
scenario_settings.save_results = true;

% Option to visualize results
scenario_settings.plot_results = true;


end