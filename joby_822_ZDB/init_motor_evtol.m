% eVTOL电机固有参数 
function y = init_motor_evtol

%电机
y.Ue = 24;         % 6S电池电压 [V]
y.Um0 = 24;        % 额定测试电压 [V]
y.Im0 = 0.78;      % 空载电流(估算值) [A]
y.Rm = 0.03;       % 电机内阻 [Ω] (2814 KV510)
y.N0 = 11322;      % 最大转速 [RPM]
y.KV0 = 510;       % KV值 [RPM/V]

y.KE = ( y.Um0 - y.Im0 * y.Rm ) / (y.KV0 * y.Um0);
y.KT = 9.55 * y.KE;


%电调
y.Re = 0.001;
y.eta_e = 0.98;