%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Ʒ�ʼ���������������ɻ�������ƽ��״̬
% ����trimlonfm_prop_1D��������ƽ��
% ����h0, mass, chi0,gamma0,alpha0, lat_in, ������״̬����(V0,dt0)
% 
% �޸ļ�¼:



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [alpha0, dt0, dl0, dr0] = EOM_get_alf_dt_de_prop_evtol(h_in,mach_in, mass_in,gamma_in,latitude_in)
D2R = pi/180;
R2D = 180/pi;
% global General mMass aLon aLat aDyn aDei aDeo aDai aDao aDsi aDso aDri aDro

%----------���״̬---------
h0 = h_in;  %�߶�(m)
mach0 = mach_in;
mass = mass_in;   %����(kg)
gamma0 = gamma_in;  %������(rad)
latitude0 =latitude_in;
%% ����trimlonfm.m�������ƽ����

% �ж����ĳ�ʼ״̬
%��ʼֵ
alpha0 = 0*D2R;
dt0 = 0.6;  % 巡航J需在APC数据范围内: V=22.76m/s, n_min=V/(Jmax*D)=5460RPM, dt_min=0.48
dl0 = 0*D2R;
dr0 = 0*D2R;



%������Է���
% --- �滻��ʼ ---
X = [alpha0, dt0, dl0, dr0];   % ���̽�ĳ�ʼֵ������ֵ��
Con = [h0, mach0, mass, gamma0, latitude0]; % ����״̬
tol_y = 1e-2;

% ���������������߽磺ӭ��(-10~15��)������(0.05~1.0)����Vβ(-20~20��)����Vβ(-20~20��)
lb = [-10*D2R, 0.40, -20*D2R, -20*D2R]; % dt下限0.40→n=4529RPM→J<0.9 
ub = [15*D2R,  1.0,   20*D2R,  20*D2R];

% ʹ�ô��߽�Լ���� lsqnonlin ��� fsolve
options = optimoptions('lsqnonlin', 'FunctionTolerance', tol_y, 'Display', 'off');
[X, resnorm, Y, exitflag] = lsqnonlin(@(X) trimlonfm_prop_3D(X,Con), X, lb, ub, options);

% �жϽ����ȷ��: ������� abs() ȡ����ֵ�жϣ�����
if ( abs(Y(1))>tol_y || abs(Y(2))>tol_y  || abs(Y(3))>tol_y || abs(Y(4))>tol_y ) 
    disp(['�в� Y = ', num2str(Y)]);
    error('��ƽʧ�ܣ��в�����޷�������������ʵ�⣡����');
end
% --- �滻���� ---

%�ش���ƽֵ
alpha0 = X(1);
dt0 = X(2);
dl0 = X(3);
dr0 = X(4);

%% ===== 巡航配平结果详细显示 =====
global General Prop aLon aDl aDr

[~, a_sound, ~, rho] = atmosisa(h0);
g = gravitywgs84(h0, latitude0);
U = mach0 * a_sound;
QS = 0.5 * rho * U^2 * General.Sw;
QSCA = QS * General.MAC;

% 螺旋桨
[T_plr, P_plr, rpm_plr, eta_plr] = get_T_evtol(h0, U, dt0);
T_total = T_plr * General.n_plr;

% 气动力
CL_basic = interpolate(aLon.alpha, aLon.CL, alpha0);
CD_basic = interpolate(aLon.alpha, aLon.CD, alpha0);
Cm_basic = interpolate(aLon.alpha, aLon.Cm, alpha0);

dCL = interpolate(aDl.alpha, aDl.CLDl, alpha0)*dl0 + interpolate(aDr.alpha, aDr.CLDr, alpha0)*dr0;
dCD = interpolate(aDl.alpha, aDl.CDDl, alpha0)*dl0 + interpolate(aDr.alpha, aDr.CDDr, alpha0)*dr0;
dCm = interpolate(aDl.alpha, aDl.CmDl, alpha0)*dl0 + interpolate(aDr.alpha, aDr.CmDr, alpha0)*dr0;

CL = CL_basic + dCL;
CD = CD_basic + dCD;
Cm = Cm_basic + dCm;

M_T_1 = T_plr * General.pos_plr1(3,1);
M_T_2 = T_plr * General.pos_plr3(3,1);
M_T_3 = T_plr * General.pos_plr5(3,1);
M_T_total = 2 * (M_T_1 + M_T_2 + M_T_3);

L = CL * QS;
D = CD * QS;
G = mass * g;
M_aero = Cm * QSCA;
M_total = M_aero + M_T_total;

theta = gamma0 + alpha0;
J_cruise = U / (rpm_plr/60 * Prop.D);

fprintf('\n=== 固定翼巡航配平结果 ===\n');
fprintf('\n飞行状态:\n');
fprintf('  高度: %.0f m, 速度: %.2f m/s (Mach %.3f)\n', h0, U, mach0);
fprintf('  质量: %.2f kg, 重力: %.2f N\n', mass, G);
fprintf('  动压: %.1f Pa, 迎角: %.2f°\n', QS/General.Sw*2, alpha0*R2D);

fprintf('\n配平变量:\n');
fprintf('  油门: %.3f → 转速: %.0f RPM\n', dt0, rpm_plr);
fprintf('  前进比 J: %.3f\n', J_cruise);
fprintf('  左V尾偏转: %.2f°, 右V尾偏转: %.2f°\n', dl0*R2D, dr0*R2D);

fprintf('\n气动力:\n');
fprintf('  升力: %.2f N (CL=%.4f), 阻力: %.2f N (CD=%.4f)\n', L, CL, D, CD);
fprintf('  升阻比 L/D: %.2f\n', L/max(D,1e-10));
fprintf('  气动俯仰力矩: %.3f N·m, 推力俯仰力矩: %.3f N·m\n', M_aero, M_T_total);

fprintf('\n螺旋桨:\n');
fprintf('  单桨推力: %.2f N, 6桨总推力: %.2f N\n', T_plr, T_total);
fprintf('  单桨功率: %.1f W, 6桨总功率: %.1f W\n', P_plr, P_plr*General.n_plr);
fprintf('  螺旋桨效率: %.1f%%\n', eta_plr*100);

fprintf('\n力平衡验证:\n');
X_res = T_total - D*cos(alpha0) + L*sin(alpha0) - G*sin(theta);
Z_res = 0 - D*sin(alpha0) - L*cos(alpha0) + G*cos(theta);
fprintf('  X方向残差: %.3e N (期望0)\n', X_res);
fprintf('  Z方向残差: %.3e N (期望0)\n', Z_res);
fprintf('  俯仰力矩残差: %.3e N·m (期望0)\n', M_total);

if abs(X_res) < 0.1 && abs(Z_res) < 0.1 && abs(M_total) < 0.5
    fprintf('\n✅ 巡航配平成功！\n');
else
    fprintf('\n⚠️ 巡航配平残差偏大\n');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   �����������Է��̣�3D��
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function FM = trimlonfm_prop_3D(X, Con)


global General Prop aLon aDl aDr
alpha = X(1);
dt = X(2);
dl0 = X(3);
dr0 = X(4);   %��ƽ�㣬����Vβƫ�����

h0 = Con(1);
mach0 = Con(2);
mass = Con(3);
gamma0 = Con(4);
latitude0 = Con(5);
%U_batt = Con(6);

%% example:
% ma=0.62;
% h=15000;
% gamma=0;
% mass=4000;
% alpha=0.034350985018905
% de=-0.010898303584496
% dt=0.465960603329478

%% ��������
[~,a,~,rho] = atmosisa(h0);
g = gravitywgs84(h0,latitude0);

U = mach0*a;
QS = 0.5 * rho * U^2 * General.Sw;
QSCA = QS * General.MAC;


%% ��⽰������
%[P,P_plr,T_plr,rpm,eta_plr]=get_MotorPlr_charactor(Motor,Prop, h0,U,dt,U_batt);   % ������
[T_plr,P_plr,rpm,eta_plr] = get_T_evtol(h0,U,dt);

T_in_b = (T_plr * General.n_plr)*[1,0,0]';

%% �����������
% ��Ϊ�������޺ẽ��������������������������Կ��Խ������

% ������������
CL_basic = interpolate(aLon.alpha, aLon.CL, alpha);
CD_basic = interpolate(aLon.alpha, aLon.CD, alpha);
Cm_basic = interpolate(aLon.alpha, aLon.Cm, alpha);


% ������ƫת�������������
% dCL_de = interpolate(aDe.de, aDe.alpha, aDe.dCL, de,alpha);
% dCD_de = interpolate(aDe.de, aDe.alpha, aDe.dCD, de,alpha);
% dCm_de = interpolate(aDe.de, aDe.alpha, aDe.dCm, de,alpha);

% dCL_de = aDe.CLDe * de;
% dCD_de = aDe.CDDe * de;
% dCm_de = aDe.CmDe * de;
CL_dl = interpolate(aDl.alpha, aDl.CLDl, alpha);
CD_dl = interpolate(aDl.alpha, aDl.CDDl, alpha);
Cm_dl = interpolate(aDl.alpha, aDl.CmDl, alpha);
CY_dl = interpolate(aDl.alpha, aDl.CYDl, alpha);  %���ϡ�����=0��ʹ��4�����̽�4��δ֪��������������Vβƫ����ͬ
dCL_dl = CL_dl * dl0;
dCD_dl = CD_dl * dl0;
dCm_dl = Cm_dl * dl0;
dCY_dl = CY_dl * dl0;

CL_dr = interpolate(aDr.alpha, aDr.CLDr, alpha);
CD_dr = interpolate(aDr.alpha, aDr.CDDr, alpha);
Cm_dr = interpolate(aDr.alpha, aDr.CmDr, alpha);
CY_dr = interpolate(aDr.alpha, aDr.CYDr, alpha);
dCL_dr = CL_dr * dr0;
dCD_dr = CD_dr * dr0;
dCm_dr = Cm_dr * dr0;
dCY_dr = CY_dr * dr0;


% if de<25/57.3
%     de1=de;
% else
%     de1=25/57.3;
% end
% 
% dCL_de = aDe.CLDe * de1;
% dCD_de = aDe.CDDe * de1;
% dCm_de = aDe.CmDe * de1;

% ��ƽβ���������ƽ��������
% K_de=9;
% dCD_de = dCL_de/K_de;


%% ����������
% ���������涼��
CL = CL_basic + dCL_dl + dCL_dr;
CD = CD_basic + dCD_dl + dCD_dr;
Cm = Cm_basic + dCm_dl + dCm_dr;
CY = dCY_dl + dCY_dr;

%M_thrust = cross(General.pos_plr1, T_in_b);
%M_thrust = zeros(3,1);
M_T_1 = T_plr * General.pos_plr1(3,1);
M_T_2 = T_plr * General.pos_plr3(3,1);
M_T_3 = T_plr  *General.pos_plr5(3,1);
M_T = 2 * (M_T_1 + M_T_2 + M_T_3);


L = CL * QS;
D = CD * QS;
M = Cm * QSCA + M_T;
Y = CY * QS;
G = mass * g;

theta = gamma0 + alpha;

FM(1) = T_in_b(1,1)-D*cos(alpha)+L*sin(alpha)-G*sin(theta);
FM(2) = T_in_b(3,1)-D*sin(alpha)-L*cos(alpha)+G*cos(theta);
FM(3) = M;
FM(4) = Y;

%% ��ʾ��������Ľ��
X;
FM;
% disp(num2str([alpha.*180/pi,de.*180/pi,dt,rpm]));
% disp([D,L/D]);
if abs(FM)<1 
    theend=0;
end

theend=0;








