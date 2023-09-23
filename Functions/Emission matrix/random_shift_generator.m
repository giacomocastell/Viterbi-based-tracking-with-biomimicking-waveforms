%%%%
%%%% Returns random shift when computing emission matrix
%%%%

function [pos_RX_init,lon_shift,lat_shift,dep_shift] = random_shift_generator(scenario_settings)

bathymetry = scenario_settings.bathymetry;
var_depRX  = scenario_settings.var_depRX;
depth_RX   = scenario_settings.pos_RX_init(3);
pos_TX     = scenario_settings.pos_TX;
max_shift  = scenario_settings.max_shift;

% Draw receiver position at random
upleft_rx_node_limit = [pos_TX(1) + max_shift * pos_TX(1) , pos_TX(2) + max_shift * pos_TX(2) ];
lowright_rx_node_limit = [pos_TX(1) - max_shift * pos_TX(1), pos_TX(2) + max_shift * pos_TX(2)];

posRX_lon = rand(1,1)*(upleft_rx_node_limit(1)-lowright_rx_node_limit(1)) + lowright_rx_node_limit(1);
posRX_lat = rand(1,1)*(upleft_rx_node_limit(2)-lowright_rx_node_limit(2)) + lowright_rx_node_limit(2);
posRX_dep = max(depth_RX+(rand-0.5)*var_depRX, 0.8*bathymetry(posRX_lon,posRX_lat));

pos_RX_init = [posRX_lon, posRX_lat, posRX_dep];
lat_shift = rand(1,1)*10^-5 * (2 * randi([0, 1]) - 1);
lon_shift = rand(1,1)*10^-5 * (2 * randi([0, 1]) - 1);
dep_shift = rand(1,1)*10^-5 * (2 * randi([0, 1]) - 1);

end