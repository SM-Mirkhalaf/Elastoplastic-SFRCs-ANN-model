load('gru500Net.mat')

a_11 = 0;
a_22 = 0;
a_33 = 0;
a_12 = 0;
a_13 = 0;
a_23 = 0;

v = 0.12;

r = 0;

labels = ['$\sigma_{11}$';'$\sigma_{22}$';'$\sigma_{33}$';...
    '$\sigma_{12}$';'$\sigma_{23}$';'$\sigma_{13}$'];


MeRE = zeros(6,15);
MaRE = zeros(6,15);
k=1;

for i = 1:3
    switch i
        case 1
            a_11 = 1;
            a_22 = 0;
            a_33 = 0;
        case 2
            a_11 = 0.5;
            a_22 = 0.5;
            a_33 = 0;
        case 3
            a_11 = 0.33;
            a_22 = 0.33;
            a_33 = 0.33;
    end
    for j = 1:5
        load(strcat(num2str(i),'D_cycletest',num2str(j),'_strain.mat'))
        load(strcat(num2str(i),'D_cycletest',num2str(j),'_stress.mat'))
        
        [Me, Ma] = modelValidator(net,...
            DefaultJobNameanalysis1, DefaultJobNameanalysis2,...
            r, a_11, a_22, a_33, a_12, a_13, a_23, v);
        
        MeRE(:,k) = Me;
        MaRE(:,k) = Ma;
        
        k = k +1;
    end
end

figure(1)
set(gcf,'Position', [100, 100, 1200, 600]);
sgtitle('MeRE as function of load cycles','interpreter','latex','fontsize',15);

figure(2)
set(gcf,'Position', [100, 100, 1200, 600]);
sgtitle('MaRE as function of load cycles','interpreter','latex','fontsize',15);
for p = 1:6
    figure(1)
    subplot(2,3,p)
    hold on
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 1;
    grid on;
    title(labels(p,:),'interpreter','latex','fontsize',15);
    plot(MeRE(p,1:5),'xk')
    plot(MeRE(p,6:10),'or')
    plot(MeRE(p,11:15),'b^')
    set(gca,'XTick',0:1:5);
    set(gca,'TickLabelInterpreter', 'latex','fontsize',15);
    xlabel('Cycles','interpreter','latex','fontsize',15);
    ylabel('MeRE','interpreter','latex','fontsize',15);
    legend('1D','2D','3D','Interpreter','latex','Location','best');
    
    figure(2)
    subplot(2,3,p)
    hold on
    ax = gca;
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 1;
    grid on;
    title(labels(p,:),'interpreter','latex','fontsize',15);
    plot(MaRE(p,1:5),'xk')
    plot(MaRE(p,6:10),'or')
    plot(MaRE(p,11:15),'b^')
    set(gca,'XTick',0:1:5);
    set(gca,'TickLabelInterpreter', 'latex','fontsize',15);
    xlabel('Cycles','interpreter','latex','fontsize',15);
    ylabel('MaRE','interpreter','latex','fontsize',15);
    legend('1D','2D','3D','Interpreter','latex','Location','best');
end

