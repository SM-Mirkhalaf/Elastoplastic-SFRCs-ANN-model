function [MeRE,MaRE,L]=modelValidator(net,...
   strain,stress,r,a_11,a_22,a_33, a_12,a_13,a_23,v,n,txt)

    strain = strain';
    stress = stress'/10^6;
    % INTERPOLATE OR EXTRAPOLATE!?
    if r > 0
        L = length(strain);
        STRAIN = zeros(6,L*r);
        STRESS = zeros(6,L*r);
        t = linspace(0,1,L);
        s = linspace(0,1,L*r);
        for i = 1:6
            STRAIN(i,:) = interp1(t,strain(i,:),s);
            STRESS(i,:) = interp1(t,stress(i,:),s);
        end
        strain = STRAIN;
        stress = STRESS;
    elseif r < 0
        strain = strain(:,1:-r:end);
        stress = stress(:,1:-r:end);
    else
        % DO NOTHING!
    end
    
    L = length(strain);
    % INSERT ORIENTATION TENSOR AND VOLUME FRACTION!
    strain = [repmat(a_11,1,L);repmat(a_22,1,L);repmat(a_33,1,L);...
        repmat(a_12,1,L);repmat(a_13,1,L);repmat(a_23,1,L);...
        repmat(v,1,L); strain];
    
    % DO PREDICTION!
    tic
    pred = predict(net,strain);
    toc
    error = pred-stress;
    
    % COMPUTE ERRORS!
    MeRE = sqrt(sum(error.^2,2)/L)/25;
    MaRE = max(abs(error),[],2)/25;
    
    if nargin == 13
        % INFORMATION FOR PRETTY PLOTS!
        switch n
            case 1
                eps = strcat('$\varepsilon_{11}\ $','[-]');
                sig = strcat('$\sigma_{11}\ $','[MPa]');
            case 2
                eps = strcat('$\varepsilon_{22}\ $','[-]');
                sig = strcat('$\sigma_{22}\ $','[MPa]');
            case 3
                eps = strcat('$\varepsilon_{33}\ $','[-]');
                sig = strcat('$\sigma_{33}\ $','[MPa]');
            case 4
                eps = strcat('$2\varepsilon_{12}\ $','[-]');
                sig = strcat('$\sigma_{12}\ $','[MPa]');
            case 5
                eps = strcat('$2\varepsilon_{23}\ $','[-]');
                sig = strcat('$\sigma_{23}\ $','[MPa]');
            case 6
                eps = strcat('$2\varepsilon_{13}\ $','[-])');
                sig = strcat('$\sigma_{13}\ $','[MPa]');
        end

        % PLOT!
        figure(3);
        hold on;
        plot(strain(7+n,:),pred(n,:),'--r','LineWidth',2);
        plot(strain(7+n,:),stress(n,:),'-b','LineWidth',1);
        
        ax = gca;
        ax.GridLineStyle = '-';
        ax.GridColor = 'k';
        ax.GridAlpha = 1; 
        grid on;

        set(gca,'TickLabelInterpreter', 'latex','fontsize',15);
        title(txt,'interpreter','latex','fontsize',15);
        xlabel(eps,'interpreter','latex','fontsize',15);
        ylabel(sig,'interpreter','latex','fontsize',15);
        legend('Network','DIGIMAT','Interpreter','latex',...
            'Location','southeast');
        
        figure(4);
        set(gcf,'Position', [100, 100, 1200, 600])
        sgtitle(txt,'interpreter','latex','fontsize',15);
        
        labels = ['$\sigma_{11}$';'$\sigma_{22}$';'$\sigma_{33}$';...
            '$\sigma_{12}$';'$\sigma_{23}$';'$\sigma_{13}$'];
        for i = 1:6
            subplot(2,3,i);
            hold on;
            plot(pred(i,:),'--r','LineWidth',2);
            plot(stress(i,:),'-b','LineWidth',1);
            ax = gca;
            ax.GridLineStyle = '-';
            ax.GridColor = 'k';
            ax.GridAlpha = 1; 
            grid on;
            set(gca,'TickLabelInterpreter', 'latex','fontsize',15);
            xlabel('Step [-]','interpreter','latex','fontsize',15);
            ylabel(strcat(labels(i,:),' [MPa]'),...
                'interpreter','latex','fontsize',15);
            legend('Network','DIGIMAT',...
                'Interpreter','latex','Location','best');
        end
end