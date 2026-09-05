% 初始化飞行控制系统
function FCS = init_FCS
D2R = pi/180;
R2D = 180/pi;

FCS.de_min=-25*D2R;
FCS.de_max=25*D2R;

FCS.dt_min=0;
FCS.dt_max=1;
FCS.dt_rate = 0.7;

FCS.theta_min = -10 *D2R;
FCS.theta_max = 20 *D2R;

FCS.gamma_max = 10 *D2R;

FCS.V_min = 14;        % 8度迎角飞行
FCS.V_cruise = 22.76;   % 巡航速度
FCS.V_max = 28;        % -3度迎角飞行




