function CA_optimized = build_optimized_CA(rotor_positions, cg_position)
    % 使用优化方法计算权重，确保推力变化不产生额外力矩

 global General

 General =  init_layoutdata;
   

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

% 旋翼位置矩阵 (6x2)
  rotor_positions = [
        
   L1_x, L1_y;
   L2_x, L2_y;
   L3_x, L3_y;
   L4_x, L4_y;
   L5_x, L5_y;
   L6_x, L6_y  ];

  x_lever_arms = abs(rotor_positions(:,1));
    
        % 优化目标：总推力为6时，俯仰力矩为0
    Aeq = [
        ones(1,6);                          % 总推力约束：和为6
        rotor_positions(:,1)';           % 俯仰力矩约束：和为0
    ];
    beq = [6; 0];                           % 总推力约束改为6
    
    % 正确的目标函数：使权重与力臂的倒数尽量匹配
    desired_weights = 1 ./ x_lever_arms;
    desired_weights = desired_weights * (6 / sum(desired_weights));
    
    % 目标函数：最小化推力方差（使推力分布尽量均匀）
    H = eye(6);
    f = -2 * desired_weights;  % 修正目标函数
    
    % 约束：推力非负
    lb = zeros(6,1);
    ub = ones(6,1) * 2;                     % 上限适当放宽
    
    % 求解
    options = optimoptions('quadprog', 'Display', 'off');
    weights = quadprog(H, f, [], [], Aeq, beq, lb, ub, [], options);
    
    % 构建优化后的控制分配矩阵
    CA_optimized = [
        weights';                           % 优化后的总推力分配
        -rotor_positions(:,2)';          % 滚转力矩
         rotor_positions(:,1)';           % 俯仰力矩  
        [-1, 1, 1, -1, -1, 1]              % 偏航力矩
    ];
end