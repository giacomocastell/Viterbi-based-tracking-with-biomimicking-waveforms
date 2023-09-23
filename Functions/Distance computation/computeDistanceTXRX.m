%%%%
%%%% Compute distance from transmitter to receiver  [m]
%%%%

function dist = computeDistanceTXRX(pos_TX, pos_RX)

[x_TX,y_TX,~] = deg2utm(pos_TX(2),pos_TX(1));
[x_RX,y_RX,~] = deg2utm(pos_RX(2),pos_RX(1));
dist = sqrt((x_TX-x_RX)^2 + (y_TX-y_RX)^2 + (pos_TX(3)-pos_RX(3))^2);

end