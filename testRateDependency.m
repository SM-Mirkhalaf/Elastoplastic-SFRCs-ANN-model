function testRateDependency(net, strain, stress,...
    a_11, a_22, a_33, a_12, a_13, a_23, v, txt)
    r = [-32 -16 -8 -4 -2 0 2 4 8 16 32 64 128];
    
    % COMPUTE
    l = length(r);
    MeRE = zeros(6,l);
    MaRE = zeros(6,l);
    steps = zeros(1,l);
    for i = 1:l
        [Me,Ma,L]=modelValidator(net, strain, stress, r(i), a_11, a_22,...
        a_33, a_12, a_13, a_23, v);
        MeRE(:,i) = Me;
        MaRE(:,i) = Ma;
        steps(i) = L;
    end
    
    % ---PLOT ERROR---
    figure(1);
    set(gcf,'Position', [100, 100, 1200, 600])
    sgtitle(txt,'interpreter','latex','fontsize',15);
    for i = 1:4
        subplot(2,2,i);
        hold on;
        plot(log10(steps),MeRE(1,:),'xb','MarkerSize',10);
        plot(log10(steps),MeRE(2,:),'sr','MarkerSize',10);
        plot(log10(steps),MeRE(3,:),'^g','MarkerSize',10);
        ax = gca;
        ax.GridLineStyle = '-';
        ax.GridColor = 'k';
        ax.GridAlpha = 1; 
        grid on;
        set(gca,'TickLabelInterpreter', 'latex','fontsize',15);
        set(gca,'YTick',0:0.2:3);
        xlabel('log$_{10}$(steps)','interpreter','latex','fontsize',15);
        if i<3
            ylabel('MeRE','interpreter','latex','fontsize',15);
        else
            ylabel('MaRE','interpreter','latex','fontsize',15);
        end
        if i == 1 | i == 3
            legend('$\sigma_{11}$','$\sigma_{22}$','$\sigma_{33}$',...
                'Interpreter','latex','Location','north');
        else
            legend('$\sigma_{12}$','$\sigma_{23}$','$\sigma_{13}$',...
                'Interpreter','latex','Location','north');
        end
    end
end