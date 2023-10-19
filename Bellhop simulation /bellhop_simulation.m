%%%%
%%%% Actually run Bellhop - one way
%%%%
function [Arr_tmp] = bellhop_simulation(pos_TX, pos_RX, maxDepth, bathymetry)

global SSP BHOP_exec BHOP_folder BHOP_title 

% fprintf('------------------------ START of Bellhop simulation ------------------------\n');

drawplot = 0;

% Set of bathymetry locations points among TX and RX
nbathypoints = 50;
lon_lat_line_TXl_RX = kron(pos_TX(1:2),ones(nbathypoints+1,1)) + kron( 0:nbathypoints, (pos_RX(1:2)-pos_TX(1:2))'./nbathypoints)';
bathy_points_TXl_RX = bathymetry(lon_lat_line_TXl_RX(:,1), lon_lat_line_TXl_RX(:,2));
%%% Conversion of scenario to Bellhop
% Bathymetry (all distances in [km])
bathy_scenario_TXl_RX_bellhop = zeros(nbathypoints,2);
for jj = 1:nbathypoints
    bathy_scenario_TXl_RX_bellhop(jj,:) = [ haversine([pos_TX(2) pos_TX(1)] , fliplr(lon_lat_line_TXl_RX(jj,:))) , -bathy_points_TXl_RX(jj) ];
end
dist_TXl_RX = max(bathy_scenario_TXl_RX_bellhop(:,1));
% Surface profile (currently flat)
%
% Sound speed profile
if isempty(SSP)
    SSP = getSSP('san_diego_deep', ceil(maxDepth));
end
% Get Bellhop functions paths if not done yet
prepare_bellhop_path;
%%% TX <---% Compute projection of TX and RX on ocean bottom > RX arrival computation
% Create .env file for computing arrival times and history
create_env_bellhop( 'AB', ceil(maxDepth), bathy_scenario_TXl_RX_bellhop, -pos_TX(3), dist_TXl_RX, -pos_RX(3));
% Actually run bellhop
currdir = pwd;
cd(BHOP_folder)
tic
system( [BHOP_exec ' ' BHOP_title ] );
telap = toc;
cd(currdir);
% fprintf('done TX<->RX arr. (CORRECT bathymetry) in %.4g s... \n', telap);

% Arrival reading and processing
[Arr_tmp, ~] = read_arrivals_asc([BHOP_folder '/' BHOP_title '.arr']);

% Trim useless entries
thresh_power_ratio = 1e-3;
maxArrLegitPow = max(abs(Arr_tmp.A))^2;
maxBounces = 2;
maxAngle = 100;
% Cancel out non significant returns
iarr = (abs(Arr_tmp.A).^2 / maxArrLegitPow > thresh_power_ratio ...
    & Arr_tmp.NumTopBnc < maxBounces & Arr_tmp.NumBotBnc < maxBounces ...
    & Arr_tmp.RcvrAngle < maxAngle ...
    );
Arr_tmp.A = Arr_tmp.A(iarr);
Arr_tmp.delay = Arr_tmp.delay(iarr);
Arr_tmp.SrcAngle = Arr_tmp.SrcAngle(iarr);
Arr_tmp.RcvrAngle = Arr_tmp.RcvrAngle(iarr);
Arr_tmp.NumTopBnc = Arr_tmp.NumTopBnc(iarr); % Number of top bounces
Arr_tmp.NumBotBnc = Arr_tmp.NumBotBnc(iarr); % Number of bottom bounces

% Sort for increasing delay
% Arr_tmp.delay = sort(Arr_tmp.delay(Arr_tmp.delay>0), 'ascend');
[Arr_tmp.delay, iarr] = sort(Arr_tmp.delay(Arr_tmp.delay>0), 'ascend');
Arr_tmp.A = Arr_tmp.A(iarr);
Arr_tmp.SrcAngle = Arr_tmp.SrcAngle(iarr);
Arr_tmp.RcvrAngle = Arr_tmp.RcvrAngle(iarr);
Arr_tmp.NumTopBnc = Arr_tmp.NumTopBnc(iarr);
Arr_tmp.NumBotBnc = Arr_tmp.NumBotBnc(iarr);
% fprintf('\n');

% Collect statistics about legit links (3rd dim index = 1)
% Dim1 = monte-carlo run index - Dim2 = receiver

if drawplot
    % Amplitude-delay profile
    figure; clf
    set(gcf,'Position',[680   629   560   289]);
    set(gca,'Position',[0.1100    0.1434    0.8350    0.7816]);
    stem(Arr_tmp.delay, abs(Arr_tmp.A).^2);
    xlabel('Arrival delay [s]');
    ylabel('Arrival power');
    set(gca, 'YScale','Log');
    drawnow;

    % Ray plot
    figure(4); clf;
    set(gcf,'Position',[680   629   560   289]);
    set(gca,'Position',[0.1100    0.1434    0.8350    0.7816]);
    currdir = pwd;
    create_env_bellhop( 'EB', ceil(maxDepth), bathy_scenario_TXl_RX_bellhop, -pos_TX(3), dist_TXl_RX, -pos_RX(3));
    cd(BHOP_folder)
    system( [ BHOP_exec ' ' BHOP_title ] );
    plotray([BHOP_folder '/' BHOP_title]);
    plotbty([BHOP_folder '/' BHOP_title]);
    ylim([0 350]);
    title('');
    xlabel('Distance [m]');
    ylabel('Depth [m]');
%     
    cd(currdir)
    drawnow;
end

% fprintf('------------------------ END of Bellhop simulation ------------------------\n\n\n');

end