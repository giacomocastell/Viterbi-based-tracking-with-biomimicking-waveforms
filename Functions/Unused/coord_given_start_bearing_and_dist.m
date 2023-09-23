function [newlon, newlat] = coord_given_start_bearing_and_dist( lon, lat, dist, bearing )

newlon = lon + dist * sind(bearing) / cosd(lat) / 111111;
newlat = lat + dist * cosd(bearing) / 111111;

