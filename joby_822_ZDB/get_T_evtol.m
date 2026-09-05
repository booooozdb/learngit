
function [T_plr, P_plr, rpm_plr, eta_plr] = get_T_evtol(h, VTAS, dt)

% 固定桨距螺旋桨推力/功率计算 (APC 12x8E)
% 输入:
%   h    - 飞行高度 [m]
%   VTAS - 真空速 [m/s]
%   dt   - 油门 [0~1]
% 输出:
%   T_plr   - 单桨推力 [N]
%   P_plr   - 单桨功率 [W]
%   rpm_plr - 螺旋桨转速 [RPM]
%   eta_plr - 螺旋桨效率 [-]

global Prop

% 油门→转速映射 (线性: dt*RPM_max)
% RPM_max 对应电机2814 KV510在6S电池下的最大转速
rpm_max = 11322;
rpm_plr = dt * rpm_max;

% 大气参数
[~, ~, ~, rho] = atmosisa(h);
rps = rpm_plr / 60;

% 前进比 (避免除零)
if rps > 0 && Prop.D > 0
    J = VTAS / (rps * Prop.D);
else
    J = 0;
end

% 检查RPM是否在数据范围内，超出则钳制
rpm_query = max(min(rpm_plr, max(Prop.rpm_grid)), min(Prop.rpm_grid));

% 处理J超出数据范围:
%   J < 0: 钳制到0 (悬停/低速工况)
%   J > J_max: 桨处于风车/无推力状态, CT→0, CP平滑过渡
if J > max(Prop.J)
    % J过大时，推力系数接近零或为负(风车状态)
    % 使用最后一个有效J点外推, CT钳制为≥0
    CT = 0;
    CP = interpolate(Prop.J, Prop.rpm_grid, Prop.CP, max(Prop.J), rpm_query);
elseif J < 0
    J = 0;
    CP = interpolate(Prop.J, Prop.rpm_grid, Prop.CP, J, rpm_query);
    CT = interpolate(Prop.J, Prop.rpm_grid, Prop.CT, J, rpm_query);
else
    CP = interpolate(Prop.J, Prop.rpm_grid, Prop.CP, J, rpm_query);
    CT = interpolate(Prop.J, Prop.rpm_grid, Prop.CT, J, rpm_query);
end

% 计算推力和功率
P_plr = CP * rho * rps^3 * (Prop.D)^5;
T_plr = CT * rho * rps^2 * (Prop.D)^4;

% 效率
if CP > 1e-10
    eta_plr = J * CT / CP;
else
    eta_plr = 0;
end

end
