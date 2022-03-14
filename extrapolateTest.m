load('gru500Net.mat')

a_11 = 0.33;
a_22 = 0.33;
a_33 = 0.33;
a_12 = 0;
a_13 = 0;
a_23 = 0;

v = 0;

r = 0;


str1 = '';
str2 = '';

MeRE = zeros(6,27);
MaRE = zeros(6,27);
k=1;

for i = 1:3
    switch i
        case 1
            str2 = 'e5_';
        case 2
            str2 = 'e7-5_';
        case 3
            str2 = 'e10_';
    end
    for j = 1:9
        switch j
            case 1
                v = 0.001;
                str1 = '0-1_';
            case 2
                str1 = '2-5_';
                v = 0.025;
            case 3
                v = 0.05;
                str1 = '5_';
            case 4
                v = 0.075;
                str1 = '7-5_';
            case 5
                v = 0.1;
                str1 = '10_';
            case 6
                v = 0.125;
                str1 = '12-5_';
            case 7
                v = 0.15;
                str1 = '15_';
            case 8
                v = 0.175;
                str1 = '17-5_';
            case 9
                str1 = '20_';
                v = 0.2;
        end
        load(strcat('extrapolatetest_v',str1,str2,'strain.mat'))
        load(strcat('extrapolatetest_v',str1,str2,'stress.mat'))
        
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
sgtitle('Effect of Parameter Extrapolation on Error','interpreter',...
    'latex','fontsize',15);

X = [0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05 0.05;
    0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075 0.075;
    0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10 0.10];
Y = [0.001 0.025 0.05 0.075 0.10 0.125 0.15 0.175 0.2;
    0.001 0.025 0.05 0.075 0.10 0.125 0.15 0.175 0.2;
    0.001 0.025 0.05 0.075 0.10 0.125 0.15 0.175 0.2];

Z1 = [MeRE(1,1:9); MeRE(1,10:18); MeRE(1,19:27)];
Z2 = [MaRE(1,1:9); MaRE(1,10:18); MaRE(1,19:27)];

subplot(1,2,1)
stem3(X,Y,Z1,'b','LineWidth',2)
ax = gca;
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 1;
grid on;

set(gca,'XTick',0.05:0.025:0.1);
set(gca,'YTick',[0.001 0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2]);
set(gca,'TickLabelInterpreter', 'latex','fontsize',13);
xlabel('$\varepsilon_{\mathrm{M}}$ [-]','interpreter','latex',...
    'fontsize',15);
ylabel('$v_{\mathrm{F}}$ [-]','interpreter','latex','fontsize',15);
zlabel('MeRE','interpreter','latex','fontsize',15);

subplot(1,2,2)
stem3(X,Y,Z2,'b','LineWidth',2)
ax = gca;
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 1;
grid on;

set(gca,'XTick',0.05:0.025:0.1);
set(gca,'YTick',[0.001 0.025 0.05 0.075 0.1 0.125 0.15 0.175 0.2]);
set(gca,'ZTick',0:0.2:2);
set(gca,'TickLabelInterpreter', 'latex','fontsize',13);
xlabel('$\varepsilon_{\mathrm{M}}$ [-]','interpreter','latex',...
    'fontsize',15);
ylabel('$v_{\mathrm{F}}$ [-]','interpreter','latex','fontsize',15);
zlabel('MaRE','interpreter','latex','fontsize',15);