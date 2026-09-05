% 重量数据 eVTOL 
function y = init_massdata
% 原始参数

y.mass = 7.0; %质量


y.Ix   =   1.149;     %惯量
y.Iy   =   0.545;    
y.Iz   =   1.396;  
    
y.Ixy   =   0.0 ;   
y.Iyz   =   0 ;  
y.Ixz   =   0.133;   

y.Inertial = [
y.Ix	-y.Ixy	-y.Ixz
-y.Ixy  y.Iy    -y.Iyz
-y.Ixz  -y.Iyz  y.Iz  ];


