% APC 12x8E 固定桨距螺旋桨初始化
% 数据来源: https://www.apcprop.com/files/PER3_12x8E.dat
% 12英寸直径, 8英寸螺距, 固定桨距定距桨
% 不考虑变桨距(theta_b), CT/CP 为前进比J和转速RPM的函数

function y = init_propeller_evtol_new

% ============================
% 1. 螺旋桨几何与物理参数
% ============================
prop.D  = 12 * 0.0254;       % 直径 [m] (12 inch → 0.3048 m)
prop.Ix = 2e-4;            % 转动惯量 [kg·m²]

% ============================
% 2. 工作转速参考值
% ============================
prop.rpm_cruise  = 6000;      % 巡航参考转速
prop.rpm_takeoff = 6000;      % 悬停/起飞参考转速

% ============================
% 3. 解析 APC PER3_12x8E.dat 数据文件
% ============================
% 使用本函数所在目录定位数据文件，避免工作目录不同导致的路径问题
func_dir = fileparts(mfilename('fullpath'));
dat_file = fullfile(func_dir, 'PER3_12x8E.dat');
if ~exist(dat_file, 'file')
    error('找不到APC螺旋桨数据文件: %s', dat_file);
end

fid = fopen(dat_file, 'r');
if fid < 0
    error('无法打开APC数据文件: %s', dat_file);
end

% 存储所有RPM下的原始数据
rpm_list = [];           % 各数据块的RPM值
raw_data = {};           % 每个cell存储一个RPM下的数据表

while ~feof(fid)
    line = strtrim(fgetl(fid));

    % 寻找 "PROP RPM = XXXX" 标识行
    if startsWith(line, 'PROP RPM')
        % 提取RPM值
        tokens = regexp(line, 'PROP RPM\s*=\s*(\d+)', 'tokens');
        if ~isempty(tokens)
            rpm_val = str2double(tokens{1}{1});

            % 跳过空行和表头行(共3行: 空行, 列名行, 单位行)
            fgetl(fid);  % 空行
            fgetl(fid);  % 列名: V  J  Pe  Ct  Cp  PWR  Torque  Thrust  ...
            fgetl(fid);  % 单位: (mph) (Adv_Ratio) ...

            % 读取数据行直到遇到空行或文件结束
            block_data = [];
            while ~feof(fid)
                pos = ftell(fid);
                data_line = strtrim(fgetl(fid));

                % 空行或新RPM块标志结束
                if isempty(data_line) || startsWith(data_line, 'PROP RPM')
                    % 回退到空行/新块前
                    if startsWith(data_line, 'PROP RPM')
                        fseek(fid, pos, 'bof');
                    end
                    break;
                end

                % 解析数据行
                nums = sscanf(data_line, '%f');
                if length(nums) >= 8
                    block_data = [block_data; nums(1:8)'];
                    % 列: 1=V(mph), 2=J, 3=Pe, 4=Ct, 5=Cp,
                    %      6=PWR(Hp), 7=Torque(In-Lbf), 8=Thrust(Lbf)
                end
            end

            if ~isempty(block_data)
                rpm_list = [rpm_list; rpm_val];
                raw_data{end+1} = block_data;
            end
        end
    end
end
fclose(fid);

fprintf('APC 12x8E数据解析完成: 共加载 %d 个转速点\n', length(rpm_list));

% ============================
% 4. 选取有效的RPM范围
% ============================
% 对于7kg/6旋翼机型，悬停约需6000-7000 RPM，巡航约7000-9000 RPM
% 选取 1000~11000 RPM 覆盖全部可能工况
rpm_min = 1000;
rpm_max = 11000;
valid_idx = (rpm_list >= rpm_min) & (rpm_list <= rpm_max);

prop.rpm_grid = rpm_list(valid_idx);         % RPM网格 [列向量]
n_rpm = length(prop.rpm_grid);

% ============================
% 5. 构建统一的前进比J网格
% ============================
% APC数据中J范围约0~0.8x（在有用推力范围内）
J_min = 0;
J_max = 0.82;          % 覆盖到J≈0.82(推力归零点附近)
n_J = 200;             % 精细化网格确保插值精度
prop.J = linspace(J_min, J_max, n_J)';   % 前进比网格 [列向量]

% ============================
% 6. 构建CT(J, RPM) 和 CP(J, RPM) 二维插值表
% ============================
prop.CT = zeros(n_J, n_rpm);    % CT矩阵: 行=J, 列=RPM
prop.CP = zeros(n_J, n_rpm);    % CP矩阵: 行=J, 列=RPM

for i = 1:n_rpm
    % 找到对应RPM的原始数据
    rpm_idx = find(rpm_list == prop.rpm_grid(i), 1);
    if isempty(rpm_idx)
        continue;
    end

    data_block = raw_data{rpm_idx};

    % 提取J, CT, CP列
    data_J  = data_block(:,2);   % advance ratio
    data_CT = data_block(:,4);   % thrust coefficient
    data_CP = data_block(:,5);   % power coefficient

    % 剔除CT≈0之后的数据(无意义推力区)
    % 找到CT从正值降到接近零的位置
    pos_ct_idx = find(data_CT > 0.001, 1, 'last');
    if ~isempty(pos_ct_idx) && pos_ct_idx < length(data_CT)
        data_J  = data_J(1:pos_ct_idx+1);
        data_CT = data_CT(1:pos_ct_idx+1);
        data_CP = data_CP(1:pos_ct_idx+1);
    end

    % 确保J单调递增
    [data_J, sort_idx] = unique(data_J);
    data_CT = data_CT(sort_idx);
    data_CP = data_CP(sort_idx);

    % 插值到统一J网格 (外推用nearest防止负值)
    if length(data_J) >= 2
        prop.CT(:,i) = interp1(data_J, data_CT, prop.J, 'linear', 'extrap');
        prop.CP(:,i) = interp1(data_J, data_CP, prop.J, 'linear', 'extrap');
    end

    % 将J=0处因外推可能为负的CT/CP钳制为非负
    prop.CT(:,i) = max(prop.CT(:,i), 0);
    prop.CP(:,i) = max(prop.CP(:,i), 0);
end

fprintf('CT/CP插值表构建完成: J网格=%d点, RPM网格=%d点(%d-%d RPM)\n', ...
    n_J, n_rpm, prop.rpm_grid(1), prop.rpm_grid(end));

% ============================
% 7. 输出关键工况验证信息
% ============================
% 悬停工况 (J≈0)
[~, j0_idx] = min(abs(prop.J));
[~, rpm_takeoff_idx] = min(abs(prop.rpm_grid - prop.rpm_takeoff));
CT_hover = prop.CT(j0_idx, rpm_takeoff_idx);
T_hover_per_rotor = CT_hover * 1.225 * (prop.rpm_takeoff/60)^2 * prop.D^4;
fprintf('悬停参考 (@%dRPM, J=0): CT=%.4f, 单桨推力=%.2f N, 6桨总推力=%.2f N\n', ...
    prop.rpm_takeoff, CT_hover, T_hover_per_rotor, T_hover_per_rotor*6);

% 巡航工况
[~, rpm_cruise_idx] = min(abs(prop.rpm_grid - prop.rpm_cruise));
V_cruise = 22.76;  % m/s
J_cruise = V_cruise / (prop.rpm_cruise/60 * prop.D);
if J_cruise <= J_max
    CT_cruise = interp1(prop.J, prop.CT(:, rpm_cruise_idx), J_cruise, 'linear', 0);
    CP_cruise = interp1(prop.J, prop.CP(:, rpm_cruise_idx), J_cruise, 'linear', 0);
    T_cruise_per_rotor = CT_cruise * 1.225 * (prop.rpm_cruise/60)^2 * prop.D^4;
    eta_cruise = J_cruise * CT_cruise / max(CP_cruise, 1e-10);
    fprintf('巡航参考 (@%dRPM, J=%.3f): CT=%.4f, CP=%.4f, 效率=%.2f%%, 单桨推力=%.2f N\n', ...
        prop.rpm_cruise, J_cruise, CT_cruise, CP_cruise, eta_cruise*100, T_cruise_per_rotor);
else
    fprintf('巡航参考: J=%.3f超出数据范围(最大J=%.3f), 请检查巡航工况\n', J_cruise, J_max);
end

y = prop;

end
