function plot_aerodata(show_on)
global aLon aLat aDyn aDl aDa aDr

plot_lon = show_on(1);
plot_lat = show_on(2);
plot_dyn = show_on(3);

R2D = 180/pi;

if plot_lon == 1
    % 纵向曲线
    figure(1);
    subplot(3,2,1);plot(aLon.alpha_deg,aLon.CL./aLon.CD,'*-');xlabel('\alpha (deg)');ylabel('L/D');grid on
    subplot(3,2,2);plot(aLon.alpha_deg,aLon.CL,'*-');xlabel('\alpha (deg)');ylabel('CL');grid on
    subplot(3,2,3);plot(aLon.alpha_deg,aLon.CD,'*-');xlabel('\alpha (deg)');ylabel('CD');grid on
    subplot(3,2,4);plot(aLon.alpha_deg,aLon.Cm,'*-');xlabel('\alpha (deg)');ylabel('Cm');grid on
    % subplot(3,2,5);plot(aLon.alpha*57.3,aeroder(aLon.CL,aLon.Cm,aLon.CL),'*-');xlabel('\alpha (deg)');ylabel('C_{mC_L}');grid on
    subplot(3,2,5);plot(aLon.CD,aLon.CL,'*-');xlabel('C_D');ylabel('C_L');grid on
    % aLon.CmCL=-[ aeroder(aLon.CL(:,1),aLon.Cm(:,1),aLon.CL(:,1)), aeroder(aLon.CL(:,2),aLon.Cm(:,2),aLon.CL(:,2)), aeroder(aLon.CL(:,3),aLon.Cm(:,3),aLon.CL(:,3)), aeroder(aLon.CL(:,4),aLon.Cm(:,4),aLon.CL(:,4)), aeroder(aLon.CL(:,5),aLon.Cm(:,5),aLon.CL(:,5))];
    % subplot(3,2,6);plot(aLon.CL,aLon.CmCL,'*-');xlabel('C_L');ylabel('C_m/C_L');grid on
    legend('show');
end

% % 纵向曲线（MY5不对称布局专用）
% figure(1);
% subplot(3,2,1);plot(aLon.alpha*R2D,aLon.CL,'*-');xlabel('\alpha (deg)');ylabel('CL');grid on
% subplot(3,2,2);plot(aLon.alpha*R2D,aLon.CD,'*-');xlabel('\alpha (deg)');ylabel('CD');grid on
% subplot(3,2,3);plot(aLon.alpha*R2D,aLon.Cm,'*-');xlabel('\alpha (deg)');ylabel('Cm');grid on
% subplot(3,2,4);plot(aLon.alpha*R2D,aLon.CY,'*-');xlabel('\alpha (deg)');ylabel('C_Y');grid on
% subplot(3,2,5);plot(aLon.alpha*R2D,aLon.Cl,'*-');xlabel('\alpha (deg)');ylabel('C_l');grid on
% subplot(3,2,6);plot(aLon.alpha*R2D,aLon.Cn,'*-');xlabel('\alpha (deg)');ylabel('C_n');grid on
% legend('show');

if plot_lat == 2
    % 横航向导数曲线
    figure(2);
    % subplot(2,2,1);plot(aLon.CL,aeroder(aLon.CL,aLon.Cm,aLon.CL),'*-');xlabel('C_L');ylabel('C_m');grid on
    subplot(2,2,1);plot(aLat.alpha*57.3,aLat.CYBeta(:,:,1),'*-');xlabel('\alpha (deg)');ylabel('C_{Y\beta}');grid on
    subplot(2,2,3);plot(aLat.alpha*57.3,aLat.ClBeta(:,:,1),'*-');xlabel('\alpha (deg)');ylabel('C_{l\beta}');grid on
    subplot(2,2,4);plot(aLat.alpha*57.3,aLat.CnBeta(:,:,1),'*-');xlabel('\alpha (deg)');ylabel('C_{n\beta}');grid on
    legend('show');
end

if plot_lat == 1
    % d横航向-beta-alpha曲线
    figure(4);
    subplot(2,3,1);plot(aLat.beta*57.3,aLat.CL(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{L}');grid on
    subplot(2,3,2);plot(aLat.beta*57.3,aLat.CD(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{D}');grid on
    subplot(2,3,3);plot(aLat.beta*57.3,aLat.Cm(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{m}');grid on
    subplot(2,3,4);plot(aLat.beta*57.3,aLat.CY(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{Y}');grid on
    subplot(2,3,5);plot(aLat.beta*57.3,aLat.Cl(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{l}');grid on
    subplot(2,3,6);plot(aLat.beta*57.3,aLat.Cn(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{n}');grid on
    legend('show');
end

% % 横航向-beta-alpha曲线
% figure(4);
% subplot(2,3,1);plot(aLat.beta*57.3,aLat.dCL(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{L}');grid on
% subplot(2,3,2);plot(aLat.beta*57.3,aLat.dCD(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{D}');grid on
% subplot(2,3,3);plot(aLat.beta*57.3,aLat.dCm(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{m}');grid on
% subplot(2,3,4);plot(aLat.beta*57.3,aLat.dCY(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{Y}');grid on
% subplot(2,3,5);plot(aLat.beta*57.3,aLat.dCl(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{l}');grid on
% subplot(2,3,6);plot(aLat.beta*57.3,aLat.dCn(:,:,1)','*-');xlabel('\beta (deg)');ylabel('C_{n}');grid on
% legend('show');
% % 横航向-alpha-beta曲线
% figure(3);
% subplot(2,2,1);plot(aLat.alpha*57.3,aLat.CY,'*-');xlabel('\alpha (deg)');ylabel('C_{Y}');grid on
% % subplot(2,2,2);plot(aLon.alpha*57.3,aLon.Cm,'*-');xlabel('\alpha (deg)');ylabel('C_m');grid on
% subplot(2,2,3);plot(aLat.alpha*57.3,aLat.Cl,'*-');xlabel('\alpha (deg)');ylabel('C_{l}');grid on
% subplot(2,2,4);plot(aLat.alpha*57.3,aLat.Cn,'*-');xlabel('\alpha (deg)');ylabel('C_{n}');grid on
% legend('show');
% 
% 
% % 升降舵-de-alpha曲线
% figure(5);
% subplot(2,2,1);plot(aDe.de*57.3,aDe.CL','*-');xlabel('\delta_e (deg)');ylabel('C_{L}');grid on
% subplot(2,2,2);plot(aDe.de*57.3,aDe.CD','*-');xlabel('\delta_e (deg)');ylabel('C_{D}');grid on
% subplot(2,2,3);plot(aDe.de*57.3,aDe.Cm','*-');xlabel('\delta_e (deg)');ylabel('C_{m}');grid on
% legend('show');
% % figure(5);
% % subplot(2,2,1);plot(aDe.de*57.3,aDe.dCL','*-');xlabel('\delta_e (deg)');ylabel('C_{L}');grid on
% % subplot(2,2,2);plot(aDe.de*57.3,aDe.dCD','*-');xlabel('\delta_e (deg)');ylabel('C_{D}');grid on
% % subplot(2,2,3);plot(aDe.de*57.3,aDe.dCm','*-');xlabel('\delta_e (deg)');ylabel('C_{m}');grid on
% % legend('show');


% % 方向舵-dr-lpha曲线
% % figure(6);
% % subplot(2,2,1);plot(aDr.de*57.3,aDr.CY','*-');xlabel('\delta_r (deg)');ylabel('C_{Y}');grid on
% % subplot(2,2,2);plot(aDr.de*57.3,aDr.Cl','*-');xlabel('\delta_r (deg)');ylabel('C_{l}');grid on
% % subplot(2,2,3);plot(aDr.de*57.3,aDr.Cn','*-');xlabel('\delta_r (deg)');ylabel('C_{n}');grid on
% % legend('show');
% figure(6);
% subplot(2,2,1);plot(aDr.dr*57.3,aDr.dCY','*-');xlabel('\delta_r (deg)');ylabel('C_{Y}');grid on
% subplot(2,2,2);plot(aDr.dr*57.3,aDr.dCl','*-');xlabel('\delta_r (deg)');ylabel('C_{l}');grid on
% subplot(2,2,3);plot(aDr.dr*57.3,aDr.dCn','*-');xlabel('\delta_r (deg)');ylabel('C_{n}');grid on
% legend('show');
