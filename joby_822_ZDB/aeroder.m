function d = aeroder(x,y,xc,method,Ts)
% 计算曲线在某一点xc的导数
% x,y: 表示一维曲线的横坐标和纵坐标
% xc:某一点横坐标值
% Ts:采样间隔，缺省值：0.001

if nargin<3
    disp('Too few parameters');
    return;
elseif  nargin<4
    method ='linear';
    Ts = 0.001;
elseif  nargin<5
    Ts = 0.001;    
end

% 插值
y1 = interp1(x,y,xc-Ts,method,'extrap');
y2 = interp1(x,y,xc+Ts,method,'extrap');

% 微分
d = (y2-y1)/(2*Ts);
