clear,clc;
%close all;

D2R = pi/180;
R2D = 180/pi;



global Airport General Mass Prop Motor aLon aLat aDyn aDl aDr aDa FCS dt0

SYS_ID = 1;
COMP_ID = 1;
SAMPLE_TIME = 0.01;

%% 读入原始数据
load('PAD.mat');
General = init_layoutdata;
Airport = init_airport('PHNL');    % 机场信息(ICAO)
Mass = init_massdata;  
Prop = init_propeller_evtol_new;
Motor = init_motor_evtol;
FCS = init_FCS;
[aLon, aLat, aDyn, aDl, aDr, aDa] = init_aerodata_evtol;


%% 设定基准状态
InitData.VehicleState = 'takeoff';  % takeoff 或 cruise

lat0_deg = 21.30682;
lon0_deg =  -157.94587;
mass = 7.0;

h_takeoff = Airport.Elevation_m;  
h_cru = 50;                     

TAS0_take0ff = 0.5;     %旋翼模式桨盘入流速度    用于计算前进比    
TAS0 = 22.76;                       
gamma0 = 0 * D2R;
psi0 = 0;



%EAS0(等效空速)
[~, ~, ~, rho_cru] = atmosisa(h_cru);
EAS2TAS = sqrt(1.225 / rho_cru);
EAS0 = TAS0 / EAS2TAS;

%%配平
%计算多旋翼悬停配平
fprintf('\n正在计算多旋翼悬停配平\n');
dt0 = EOM_dt_MC;

%计算固定翼巡航配平
fprintf('正在计算固定翼巡航配平\n');
[~,a_cru,~,~] = atmosisa(h_cru); %计算声速
mach_cru = TAS0 / a_cru;

[alpha_cru, dt_cru, dl_cru, dr_cru] = EOM_get_alf_dt_de_prop_evtol(h_cru, mach_cru, mass, gamma0, lat0_deg);

dtTrim    = dt_cru; 
deTrim    = dl_cru;      
thetaTrim = alpha_cru;   

if strcmp(InitData.VehicleState, 'takeoff')   
    %悬停
    h0 = h_takeoff;
    alpha0 = General.theta_TJ;  
    Vb_0 =  TAS0_take0ff * [0, 0, 1e-6];          
    Ve_0 =  TAS0_take0ff * [0, 0, 1e-6];
    InitData.LandingGearState = 1;   
    i0 = pi/2;                  
    
    InitData.dl = 0;
    InitData.dr = 0;
    InitData.da = 0;
    InitData.dt = dt0.dt0_1;    
    
else
    %巡航
    h0 = h_cru;
    alpha0 = alpha_cru;
    Vb_0 = TAS0 * [cos(alpha0), 0, sin(alpha0)];
    Ve_0 = TAS0 * [cos(psi0), sin(psi0), 0];
    InitData.LandingGearState = 0;
    i0 = 0;                     
    
    InitData.dl = dl_cru;
    InitData.dr = dr_cru;
    InitData.da = 0;
    InitData.dt = dt_cru;
end
    
InitData.LLA = [lat0_deg*D2R, lon0_deg*D2R, h0];
InitData.Xe = [0, 0, -h0];      
InitData.Vb = Vb_0;    
InitData.Euler = [0, alpha0, psi0];
InitData.Ve =  Ve_0;
InitData.pqr = [0,0,0];
InitData.mass0 = mass;
InitData.rpm = 6000;
InitData.i = i0;
InitData.alpha = alpha0;

InitData.lat_deg = lat0_deg;
InitData.lon_deg = lon0_deg;
InitData.h_runway = h0-General.pos_fgl(3)-0.055-0.4950;

fprintf('\n飞机初始化完成\n');
fprintf('当前初始模式: %s\n', InitData.VehicleState);






