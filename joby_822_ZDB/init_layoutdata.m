% eVTOL布局参数
% 包括：翼展、平均气动弦、机翼面积、发动机到重心距离、安装角
function y = init_layoutdata

% 飞机
y.b = 2;          % 翼展
y.MAC = 0.1905;   % 平均气动弦长                                                                   
y.Sw  = 0.381;     % 机翼面积
y.SM  = 0.1;       % 稳定裕度
y.CLa = 0.09913*180/pi;    % CLAlpha

%%%发动机
y.n_plr = 6;    % 桨的数量
%发动机到重心距离 
y.G0 = [-0.4, 0, -0.2]';                          %重心相对机头距离
% y.pos_plr1_0 = [ -0.600	  2.61	 -1.275 ]';        %桨的原始位置
% y.pos_plr2_0 = [ -2.100	  5.630	 -1.275 ]';
% y.pos_plr3_0 = [ -4.500	  2.150	 -2.141 ]';
% y.pos_plr4_0 = [ -4.500	 -2.150	 -2.141 ]';
% y.pos_plr5_0 = [ -2.100	 -5.630	 -1.275 ]';
% y.pos_plr6_0 = [ -0.600	 -2.61	 -1.275 ]';

% y.pos_plr1 = y.pos_plr1_0 - y.G0;          %桨相对重心位置        
% y.pos_plr2 = y.pos_plr2_0 - y.G0;
% y.pos_plr3 = y.pos_plr3_0 - y.G0;
% y.pos_plr4 = y.pos_plr4_0 - y.G0;
% y.pos_plr5 = y.pos_plr5_0 - y.G0;
% y.pos_plr6 = y.pos_plr6_0 - y.G0;

y.pos_plr1 = [ 0.32     0.45   -0.05]';          %桨相对重心位置        
y.pos_plr2 = [ 0      1.02   0]';
y.pos_plr3 = [-0.33   0.39   -0.3]';
y.pos_plr4 = [-0.33  -0.39   -0.3]';
y.pos_plr5 = [ 0     -1.02   0]';
y.pos_plr6 = [ 0.32  -0.45   -0.05]';

y.pos_plr1_0 = y.pos_plr1 + y.G0;        %桨的原始位置
y.pos_plr2_0 = y.pos_plr2 + y.G0;
y.pos_plr3_0 = y.pos_plr3 + y.G0;
y.pos_plr4_0 = y.pos_plr4 + y.G0;
y.pos_plr5_0 = y.pos_plr5 + y.G0;
y.pos_plr6_0 = y.pos_plr6 + y.G0;

%发动机安装角rotation
y.rot_plr1 = [0,0,0]';
y.rot_plr2 = [0,0,0]';
y.rot_plr3 = [0,0,0]';
y.rot_plr4 = [0,0,0]';
y.rot_plr5 = [0,0,0]';
y.rot_plr6 = [0,0,0]';


y.theta_TJ = 0;   %停机角



y.Apex = [0.04549,0,-0.05]'/5.7;  % 外翼对称面顶点在体轴的坐标

y.F2E = 0.05*y.MAC;    % 梁截面（翼型）焦点到刚心的距离占弦长的百分比，刚心在后为正
y.LE2F = 0.25*y.MAC;   % 梁截面（翼型）前缘到焦点的距离占弦长的百分比，焦点在后为正


y.pos_fg = ([0.3453,0,0.417]'+y.Apex)/5.7;  % 左前轮在体轴的坐标
y.pos_mgl = ([-0.1207,-0.709,0.417]'+y.Apex)/5.7;  % 左主轮在体轴的坐标
y.pos_mgr = ([-0.1207,0.709,0.417]'+y.Apex)/5.7;  % 右主轮在体轴的坐标
y.pos_fgl = ([0.3453,-0.709,0.5]'+y.Apex)/5.7;  % 左前轮在体轴的坐标
y.pos_mgl = ([-0.1207,-0.709,0.50]'+y.Apex)/5.7;  % 左主轮在体轴的坐标
y.pos_fgr = ([0.3453,0.709,0.5]'+y.Apex)/5.7;  % 右前轮在体轴的坐标
y.pos_mgr = ([-0.1207,0.709,0.50]'+y.Apex)/5.7;  % 右主轮在体轴的坐标
y.theta_TJ = atan((y.pos_mgl(3)-y.pos_fg(3))/(y.pos_mgl(1)-y.pos_fg(1)));     % 根据起落架坐标计算得到的停机角
disp(y.theta_TJ*57.3);
y.CD0_gear_taxi = -0.01;       % 轮子的滚动摩擦系数
y.CD0_gear_taxi = -0.1;       % 轮子的滚动摩擦系数
y.CD0_gear_taxi = -0.12;       % 轮子的滚动摩擦系数
y.CD0_gear_taxi = 0;       % 轮子的滚动摩擦系数

y.CD0_gear_brake = -0.3;       % 轮子的滑动摩擦系数（刹车）
y.CD0_gear_aero = 0.0035;       % 轮子的附加气动阻力系数

y.dzf0=0.05*0.5;    % 前轮压缩量，[m]
y.dzm0=0.05;    % 主轮压缩量，[m]
y.dz_cg0 = y.pos_fg(1,1)/(y.pos_fg(1,1)-y.pos_mgl(1,1))*(-y.dzf0+y.dzm0);


xf=y.pos_fg(1);
zf=y.pos_fg(3);
xm=y.pos_mgl(1);
zm=y.pos_mgl(3);
f = 0.035;
G=7*9.8; % 无人机重量, [N]
y.Kf=-G*((xm-zm*f)/((xf-zf*f)-(xm-zm*f))) / y.dzf0;
y.Km=G*((xf-zf*f)/((xf-zf*f)-(xm-zm*f))) / y.dzm0;
y.Cf=0.1*y.Kf;  % 前轮阻尼
y.Cm=0.1*y.Km;  % 主轮阻尼

y.Cf=0.1*y.Kf;  % 前轮阻尼
y.Cm=0.1*y.Km;  % 主轮阻尼

mm2in=1/25.4;
n2lbf=0.225;
delta=5*mm2in;    %[inch]
Dia=60*mm2in;  % [inch]
W=20*mm2in;    % [inch]
p=1.8;    % [psi]
pr=1.8;   % [psi]
Cc=1.2; % type of tyre
Ktheta = (1.2*(delta/Dia)-8.8*(delta/Dia)^2)*Cc*(p+0.44*pr)*W^2/n2lbf;
y.Kb=-Ktheta;
y.Kb=-0.01;
y.Kb=-0.22;

% % 无支撑力状态飞机重心到地面的距离
% % 二维的地轴转体轴DCM
% DCM_be=[ cos(y.theta_TJ)    -sin(y.theta_TJ)
%          sin(y.theta_TJ)    cos(y.theta_TJ)  ];
% y.pos_fg_in_e = DCM_be'* y.pos_fg([1,3],1);
% y.hrel_cg_free = y.pos_fg_in_e(2,1);



% theend=0;


