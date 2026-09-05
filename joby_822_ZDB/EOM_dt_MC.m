function y = EOM_dt_MC

% 多旋翼悬停配平计算
% 使用APC 12x8E固定桨距螺旋桨数据
% 对于悬停工况 (V≈0, J≈0) 直接使用静态推力系数求解转速

global General Mass Prop Motor

General = init_layoutdata;
Mass    = init_massdata;
Prop    = init_propeller_evtol_new;
Motor   = init_motor_evtol;

% === 1. 提取旋翼安装位置 ===

L1_x = General.pos_plr1(1);
L1_y = General.pos_plr1(2);

L2_x = General.pos_plr2(1);
L2_y = General.pos_plr2(2);

L3_x = General.pos_plr3(1);
L3_y = General.pos_plr3(2);

L4_x = General.pos_plr4(1);
L4_y = General.pos_plr4(2);

L5_x = General.pos_plr5(1);
L5_y = General.pos_plr5(2);

L6_x = General.pos_plr6(1);
L6_y = General.pos_plr6(2);

rotor_positions = [
    L1_x, L1_y;
    L2_x, L2_y;
    L3_x, L3_y;
    L4_x, L4_y;
    L5_x, L5_y;
    L6_x, L6_y  ];

% === 2. 力/力矩平衡求解推力分配 ===

W = Mass.mass * 9.8;

A = [
    ones(1, 6);                    % 总推力合力
    rotor_positions(:,1)';         % 俯仰力矩 (x坐标力臂)
    rotor_positions(:,2)'          % 滚转力矩 (y坐标力臂)
];

b = [W; 0; 0];                    % 配平目标: [总推力=重力, 俯仰=0, 滚转=0]

% 伪逆求解
T = pinv(A) * b;

% 检查解的有效性
if any(T < 0)
    warning('部分旋翼推力为负值，使用二次规划重新配平');
    T = solve_nonnegative_trim(A, b, W);
end

% === 3. 根据所需推力计算各旋翼转速 ===
% 悬停工况: V≈0, J≈0
% 推力公式: T = CT(J≈0, RPM) * rho * n² * D⁴
% 转速: n = sqrt(T / (CT * rho * D⁴))

rho = 1.225;        % 海平面空气密度 [kg/m³]
D   = Prop.D;       % 螺旋桨直径 [m]

for i = 1:6
    T_req = T(i);

    % CT在J=0处几乎不随RPM变化(~0.107-0.109), 取平均值初始估计
    CT_static = Prop.CT(1, :);
    CT0_mean  = mean(CT_static);

    % 初估转速
    n_rps = sqrt(T_req / (CT0_mean * rho * D^4));

    % 迭代修正 (CT在J=0处有微弱Reynolds效应)
    for iter = 1:5
        n_rpm = n_rps * 60;
        CT_iter = interpolate(Prop.J, Prop.rpm_grid, Prop.CT, 0, n_rpm);
        if CT_iter < 1e-6
            CT_iter = CT0_mean;
        end
        n_rps_new = sqrt(T_req / (CT_iter * rho * D^4));
        if abs(n_rps_new - n_rps) < 0.01
            break;
        end
        n_rps = n_rps_new;
    end

    n_rpm = n_rps * 60;

    % 查取工作点的CP
    CP_op = interpolate(Prop.J, Prop.rpm_grid, Prop.CP, 0, n_rpm);

    % 存储结果
    y.T(i)   = T_req;
    y.J(i)   = 0;                          % 悬停前进比≈0
    y.n(i)   = n_rpm;                      % 转速 [RPM]
    y.CP(i)  = CP_op;
    y.Q(i)   = CP_op / (2*pi) * rho * (n_rpm/60)^2 * D^5;  % 扭矩 [N·m]

    % 油门量 (根据电机模型反算)
    y.dt0(i) = 1/Motor.Ue * (Motor.KE * n_rpm + (Motor.Re + Motor.Rm) * (y.Q(i)/Motor.KT + Motor.Im0));
end

y.n0_1 = y.n(1);
y.n0_2 = y.n(2);
y.n0_3 = y.n(3);
y.n0_4 = y.n(4);
y.n0_5 = y.n(5);
y.n0_6 = y.n(6);

y.dt0_1 = y.dt0(1);
y.dt0_2 = y.dt0(2);
y.dt0_3 = y.dt0(3);
y.dt0_4 = y.dt0(4);
y.dt0_5 = y.dt0(5);
y.dt0_6 = y.dt0(6);

% === 4. 验证并显示配平结果 ===
moments = verify_trim_centered(T, rotor_positions);
display_trim_results_centered(T, moments, rotor_positions, W, y.n, y.dt0);

end


% === 辅助函数: 二次规划求非负推力 ===
function T_nonneg = solve_nonnegative_trim(A, b, W)

num_rotors = 6;

H = eye(num_rotors);
f = zeros(num_rotors, 1);

A_eq = A;
b_eq = b;
lb = zeros(num_rotors, 1);
ub = W * ones(num_rotors, 1);

options = optimoptions('quadprog', 'Display', 'none');
T_nonneg = quadprog(H, f, [], [], A_eq, b_eq, lb, ub, [], options);
end


% === 辅助函数: 验证配平结果 ===
function moments = verify_trim_centered(T, rotor_positions)

total_thrust = sum(T);
pitch_moment = sum(T .* rotor_positions(:,1));
roll_moment  = sum(T .* rotor_positions(:,2));

moments = [total_thrust, pitch_moment, roll_moment];
end


% === 辅助函数: 显示配平结果 ===
function display_trim_results_centered(T, moments, rotor_positions, W, n, dt0)

fprintf('=== 悬停配平结果 (坐标原点为重心) ===\n');

fprintf('\n旋翼推力分配:\n');
for i = 1:6
    fprintf('旋翼%d: 推力=%.2fN, 转速=%.0fRPM, 油门=%.3f, 位置=(%.2f, %.2f)m\n', ...
        i, T(i), n(i), dt0(i), rotor_positions(i,1), rotor_positions(i,2));
end

fprintf('\n平衡验证:\n');
fprintf('总推力: %.2f N (期望: %.2f N, 即%.2f kg)\n', moments(1), W, W/9.8);
fprintf('俯仰力矩: %.2e N·m (期望: 0)\n', moments(2));
fprintf('滚转力矩: %.2e N·m (期望: 0)\n', moments(3));

fprintf('\n配平误差:\n');
thrust_error = abs(moments(1) - W) / W * 100;
pitch_error  = abs(moments(2)) / W * 100;
roll_error   = abs(moments(3)) / W * 100;

fprintf('推力误差: %.3f%%\n', thrust_error);
fprintf('俯仰力矩误差: %.3f%%\n', pitch_error);
fprintf('滚转力矩误差: %.3f%%\n', roll_error);

if thrust_error < 1 && pitch_error < 1 && roll_error < 1
    fprintf('\n✅ 配平成功！误差在可接受范围内。\n');
else
    fprintf('\n⚠️ 配平误差较大，建议检查输入参数。\n');
end
end
