% 机场信息，采用ICAO命名方式
function Airport = init_airport(varargin)
if length(varargin)==1
    Airport.Name = varargin{1};
elseif length(varargin)==2
    Airport.Name = varargin{1};
    Airport.Runway = varargin{2};
end

% 夏威夷机场,PHNL，08R
if strcmp(Airport.Name,'PHNL') 
    Airport.Runway = '08R'; % 跑道名
    
    % 跑道起点
    Airport.Lat_deg = 21.30682;
    Airport.Lon_deg = -157.94587;
    Airport.Elevation_m = 1.0;

%     Airport.Course_deg = 90;
    Airport.Course_deg = 0;
    Airport.Distance_m = 3650;
    Airport.Width_m = 60;

    % 跑道坡度，[deg]
%     Airport.Slope_deg = atand(-0.05);    % 5%的坡度，对应2.86度的角度
    Airport.Slope_deg = atand(0.00);    % 5%的坡度，对应2.86度的角度
end

% 跑道终点的纬经高
R_earth = 6.371004e6;
R2D = 180/pi;
Airport.Runway_end_lat = Airport.Lat_deg + (Airport.Distance_m * cosd(Airport.Course_deg))/R_earth * R2D;
Airport.Runway_end_lon = Airport.Lon_deg + (Airport.Distance_m * sind(Airport.Course_deg))/(R_earth*cosd(Airport.Lat_deg)) * R2D;
Airport.Runway_end_alt = Airport.Elevation_m +  Airport.Distance_m * sind(Airport.Slope_deg);

    
    
