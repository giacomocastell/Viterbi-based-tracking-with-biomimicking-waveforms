% Parameters:
%   - title
%   - maxdepth [m]
%   - TXdep [m]
%   - RXdist [km]
%   - RXdep [m]
function create_env_bellhop ( opt3, maxdepth, bathy, TXdep, RXdist, RXdep )

global SSP BHOP_title BHOP_folder

freq = 12000;

% Bathymetry processing
ss = exist(BHOP_folder,'dir');
if isempty(ss)
    mkdir(BHOP_folder);
end
fp = fopen([BHOP_folder '/' BHOP_title '.bty'],'w');
fprintf(fp, '%s\n', '''L''');
fprintf(fp, '%d\n', size(bathy,1));
for ii = 1:size(bathy,1)
    fprintf(fp, '%.4g %.4g\n', bathy(ii,1), bathy(ii,2) );
end
fclose(fp);


parameters = struct(...
    'freq', freq, ...
    'OPTIONS1', 'CVWT', ...
    'depth_max', maxdepth, ...
    'ssp', SSP, ...
    'OPTIONS2', 'A*', ...
    'bottom', struct( 'cp_bottom', 1549, 'cs_bottom', 219.106, ...
        'density_bottom', 1.624, 'alpha_bottom', [0.668 1.3] ), ...
    'nsources', 1, ...
    'source_depth', TXdep, ... % [m]
    'nreceivers_vertical', 1, ...
    'receivers_depth', RXdep, ... % [m]
    'nreceivers_horizontal', 1, ...
    'receivers_range', RXdist, ... % [km]
    'OPTIONS3', opt3, ...
    'nrays', 0, ...
    'launching_angles', [ -65  65 ], ...
    'depth_box', maxdepth*1.01, ... % [m]
    'range_box', RXdist * 1.01 ... % [km] 
);

f = fopen([BHOP_folder '/' BHOP_title '.env'], 'w');

fprintf(f, '''%s''  ', BHOP_title);
fprintf(f, '!!! TITLE \n');

fprintf(f, '%g  ', parameters.freq);
fprintf(f, '!!! FREQUENCY (Hertz) \n');

fprintf(f, '1  ');
fprintf(f, '!!! NMEDIA (always 1 here) \n');

fprintf(f, '''%s''  ', parameters.OPTIONS1);
fprintf(f, '!!! OPTIONS1 flags (interpolation, surface type, bottom attenuation units, Thorp flag, surface shape) \n');

fprintf(f, '0 0.0 %g  ', parameters.depth_max);
fprintf(f, '!!! NMESH (not used), SIGMA_S (not used), MAX DEPTH \n');

for ii = 1:size(parameters.ssp,1)
    fprintf(f, '%12.4f %12.4f /\n', parameters.ssp(ii,:));
end
% fprintf(f, '!!!!!!!!!!!! SSP (depth,value) points starting from lowest depth !!!!!!!!!!!!\n');

%1549 219.106 1.624 0.668 1.3  /  ! CLAY * 0.4 + SILT * 0.6 BOTTOM TYPE
fprintf(f, '''%s'' 0.0  ', parameters.OPTIONS2);
fprintf(f, '!!! OPTIONS2 flags (type of media below water, bottom shape) \n');

fprintf(f, '%g %d %g %g %g', parameters.depth_max, parameters.bottom.cp_bottom, parameters.bottom.cs_bottom, parameters.bottom.density_bottom);
fprintf(f, '%g  ', parameters.bottom.alpha_bottom);
fprintf(f, '!!! Parameters of acoustic half-space (Max depth, CP_bottom, CS_bottom, density_bottom, alpha_bottom) \n');

fprintf(f, '%d  ', parameters.nsources);
fprintf(f, '!!! Number of sources \n');

fprintf(f, '%d /  ', parameters.source_depth);
fprintf(f, '!!! Source min and max depth \n');

fprintf(f, '%d  ', parameters.nreceivers_vertical);
fprintf(f, '!!! Number of receivers along vertical direction \n');

fprintf(f, '%g  ', parameters.receivers_depth);
fprintf(f, ' /  ');
fprintf(f, '!!! Receiver depth (or Receivers'' MIN and MAX depth) in [m]  \n');

fprintf(f, '%d  ',parameters.nreceivers_horizontal);
fprintf(f, '!!! Number of receivers along horizontal direction \n');

fprintf(f, '%g  ', parameters.receivers_range);
fprintf(f, ' /  ');
fprintf(f, '!!! Receiver range (or Receivers'' MIN and MAX range) in [km] \n ');

fprintf(f, '''%s''  ', parameters.OPTIONS3);
fprintf(f, '!!! OPTIONS3 flags (output type, pressure computation approx, beam pattern, point/cartesian source, receiver positioning) \n');

fprintf(f, '%d  ', parameters.nrays);
fprintf(f, '!!! Number of simulated beams (0 for auto) \n');

fprintf(f, '%g  %g /  ', parameters.launching_angles);
fprintf(f, '!!! Beam launching angles (min, max) \n');

fprintf(f, '0.0 %g %g  ', parameters.depth_box, parameters.range_box);
fprintf(f, '!!! Ray calculation STEP (resolution, 0 for auto) (m), ZBOX (m), RBOX (km) \n');

fclose(f);









