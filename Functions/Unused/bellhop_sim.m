% bellhop_sim
% Author: Paolo Casari
% Date: 31/03/2017

function bellhop_sim( num_RX_nodes )
 
global bathy SSP BHOP_folder BHOP_title BHOP_exec N_rand_TX_pos_Rx N_rand_TX_pos_Fake

drawplot = true;

nominal_depRX = -120;
var_depRX = 20;

bathy_offset = 25; % [m]
bathy_rand = 2.5; % random +/- value [m]

nominal_dep_legit = -150;

% Oscillation parameter
oscill_rad = 15; % [m]

N_rand_TX_pos_Rx = 1;
N_rand_TX_pos_Fake = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


BHOP_title = 'tempbellhop1';

BHOP_folder = [pwd() '/' 'tmp_bhop'];

load('bathymetry_SD.mat');


bathy_lon_max = -117.3520;
bathy_lat_min = 33.08;
bathy_lon_min = -117.4264;
bathy_lat_max = 33.15;

npoints = 251;
[X,Y] = meshgrid( linspace(bathy_lon_min,bathy_lon_max,npoints) , linspace(bathy_lat_min,bathy_lat_max,npoints) );
bathy = SanDiegoBathymetry(X,Y);
maxDepth = -min(min(bathy)); 

% Nominal initial positions for the legit and fake transmitters
nominal_pos_TX = [-117.3892, 33.0920, nominal_dep_legit];

% Set position and depth of the receivers
upleft_rx_node_limit = [-117.4055 , 33.1395 ];
lowright_rx_node_limit = [ -117.3875, 33.1000 ];

% Check distances
if 1
    fprintf( 'Upper side length: %.2f km\n', ...
        haversine( [upleft_rx_node_limit(1),upleft_rx_node_limit(2)] , [lowright_rx_node_limit(1),upleft_rx_node_limit(2)] ) );
    fprintf( 'Right side length: %.2f km\n', ...
        haversine( [lowright_rx_node_limit(1),upleft_rx_node_limit(2)] , [lowright_rx_node_limit(1),lowright_rx_node_limit(2)] ) );
    fprintf( 'Bottom side length: %.2f km\n', ...
        haversine( [upleft_rx_node_limit(1),lowright_rx_node_limit(2)] , [lowright_rx_node_limit(1),lowright_rx_node_limit(2)] ) );
    fprintf( 'Left side length: %.2f km\n', ...
        haversine( [upleft_rx_node_limit(1),lowright_rx_node_limit(2)] , [upleft_rx_node_limit(1),upleft_rx_node_limit(2)] ) )
end

% Draw receiver positions at random
list_posRX_lon = zeros(num_RX_nodes,1);
list_posRX_lat = zeros(num_RX_nodes,1);
list_posRX_dep = zeros(num_RX_nodes,1);

list_posRX_lon = rand(4,1)*(upleft_rx_node_limit(1)-lowright_rx_node_limit(1)) + lowright_rx_node_limit(1);
list_posRX_lat = rand(4,1)*(upleft_rx_node_limit(2)-lowright_rx_node_limit(2)) + lowright_rx_node_limit(2);
for iRx = 1 : num_RX_nodes
    list_posRX_dep(iRx) = max(nominal_depRX+(rand-0.5)*var_depRX, 0.8*SanDiegoBathymetry(list_posRX_lon(iRx),list_posRX_lat(iRx)));
end


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
    % Alice (red diamond) and Eve (black cross)
    aliceH = plot3(nominal_pos_TX(1), nominal_pos_TX(2), nominal_pos_TX(3),'dr','MarkerSize',10,'LineWidth',1,'MarkerFaceColor','Red');
    % Plot limits of receiver area
    plot3([upleft_rx_node_limit(1) upleft_rx_node_limit(1)],[upleft_rx_node_limit(2) lowright_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
    plot3([upleft_rx_node_limit(1) lowright_rx_node_limit(1)],[lowright_rx_node_limit(2) lowright_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
    plot3([lowright_rx_node_limit(1) lowright_rx_node_limit(1)],[lowright_rx_node_limit(2) upleft_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
    plot3([lowright_rx_node_limit(1) upleft_rx_node_limit(1)],[upleft_rx_node_limit(2) upleft_rx_node_limit(2)],[0 0],'-','Color','White','LineWidth',2);
    % Receivers
    %%%%%% Convenient coordinates for plotting purposes
    list_posRX_lon = [-117.3897 -117.4009 -117.3975 -117.4012];
    list_posRX_lat = [33.1274   33.1316   33.1084   33.1189];
    list_posRX_dep = [-129.7761 -128.2985 -112.7795 -118.6749];
    tNodeColor = myBlue; 
    for iRx = 1 : length(list_posRX_lon)
        rxH = plot3(list_posRX_lon(iRx),list_posRX_lat(iRx),list_posRX_dep(iRx),'o','Color','White','MarkerFaceColor',tNodeColor,'MarkerSize',8,'LineWidth',1);
    end
    legh = legend( [aliceH, rxH] , 'Alice', 'Receiver' );
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






Arrivals_Rx = cell(N_rand_TX_pos_Rx, length(list_posRX_lon));

fprintf('------------------------ START of simulation ------------------------\n');

begin_sim_time = clock;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Receiver node simulation cycle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if 1
    fprintf('\n-----Receivers-----\n');
    for itrial = 1 : N_rand_TX_pos_Rx
        
        % Extract a random position for the TX
        rand_pos_TX = zeros(1,2);
        [rand_pos_TX(1), rand_pos_TX(2)] = coord_given_start_bearing_and_dist(nominal_pos_TX(1), nominal_pos_TX(2), rand*oscill_rad, rand*360 );
        pos_TX = [ rand_pos_TX(1:2) , nominal_pos_TX(3) ];
        
        % pos_TX = nominal_pos_TX;
        
        fprintf('**** Step: %d of %d\n', itrial, N_rand_TX_pos_Rx);
        fprintf('--- pos_TX (lon,lat,dep) = [%.7g %.7g %.7g]\n', pos_TX(1), pos_TX(2), pos_TX(3));
        
        for ii = 1:length(list_posRX_lon)
            
            fprintf('- Receiver %d of %d\n', ii, length(list_posRX_lon));
            
            % Compose full location for current RX
            pos_RX = [list_posRX_lon(ii), list_posRX_lat(ii), list_posRX_dep(ii)];
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Computation of receiver node channel with correct bathymetry %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            % Compute projection of TX and RX on ocean bottom
            proj_TX_bottom = [pos_TX(1:2), SanDiegoBathymetry(pos_TX(1),pos_TX(2))];
            proj_RX_bottom = [pos_RX(1:2), SanDiegoBathymetry(pos_RX(1),pos_RX(2))];
            % Set of bathymetry locations points among TX and RX
            nbathypoints = 50;
            lon_lat_line_TXl_RX = kron(pos_TX(1:2),ones(nbathypoints+1,1)) + kron( 0:nbathypoints, (pos_RX(1:2)-pos_TX(1:2))'./nbathypoints)';
            bathy_points_TXl_RX = SanDiegoBathymetry(lon_lat_line_TXl_RX(:,1), lon_lat_line_TXl_RX(:,2));
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
            %%% TX <---> RX arrival computation
            % Create .env file for computing arrival times and history
            create_env_bellhop( 'AB', ceil(maxDepth), bathy_scenario_TXl_RX_bellhop, -pos_TX(3), dist_TXl_RX, -pos_RX(3));
            % Actually run bellhop
            currdir = pwd;
            cd(BHOP_folder)
            tic
            system( [BHOP_exec ' ' BHOP_title ] );
            telap = toc;
            cd(currdir);
            fprintf('done TX<->RX arr. (CORRECT bathymetry) in %.4g s... ', telap);
            
            % Arrival reading and processing
            [Arr_tmp, ~] = read_arrivals_asc([BHOP_folder '/' BHOP_title '.arr']);
            % Trim useless entries
            thresh_power_ratio = 1e-3;
            maxArrLegitPow = max(abs(Arr_tmp.A))^2;
            iarr = (abs(Arr_tmp.A).^2 / maxArrLegitPow > thresh_power_ratio);
            Arr_tmp.A = Arr_tmp.A(iarr);
            Arr_tmp.delay = Arr_tmp.delay(iarr);
            Arr_tmp.SrcAngle = Arr_tmp.SrcAngle(iarr);
            Arr_tmp.RcvrAngle = Arr_tmp.RcvrAngle(iarr);
            Arr_tmp.NumTopBnc = Arr_tmp.NumTopBnc(iarr);
            Arr_tmp.NumBotBnc = Arr_tmp.NumBotBnc(iarr);
            
            % Sort for increasing delay
            [Arr_tmp.delay, iarr] = sort(Arr_tmp.delay(Arr_tmp.delay>0), 'ascend');
            Arr_tmp.A = Arr_tmp.A(iarr);
            Arr_tmp.SrcAngle = Arr_tmp.SrcAngle(iarr);
            Arr_tmp.RcvrAngle = Arr_tmp.RcvrAngle(iarr);
            Arr_tmp.NumTopBnc = Arr_tmp.NumTopBnc(iarr);
            Arr_tmp.NumBotBnc = Arr_tmp.NumBotBnc(iarr);
            fprintf('\n');
            
            % Collect statistics about legit links (3rd dim index = 1)
            % Dim1 = monte-carlo run index - Dim2 = receiver
            Arrivals_Rx{itrial,ii} = Arr_tmp;
            
            if drawplot
                % Amplitude-delay profile
                figure(2); clf
                set(gcf,'Position',[680   629   560   289]);
                set(gca,'Position',[0.1100    0.1434    0.8350    0.7816]);
                stem(Arr_tmp.delay, abs(Arr_tmp.A).^2);
                xlabel('Arrival delay [s]');
                ylabel('Arrival power');
                set(gca, 'YScale','Log');
                drawnow;
                
                % Ray plot
                figure(3); clf;
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

                cd(currdir)
                drawnow;
            end
        end
    end
end


fprintf('------------------------ END of simulation ------------------------\n\n\n');








