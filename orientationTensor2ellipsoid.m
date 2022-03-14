function orientationTensor2ellipsoid(a_11, a_22, a_33, a_12, a_13, a_23, num);
A = [a_11, a_12, a_13;
    a_12, a_22, a_23;
    a_13, a_23, a_33];

[v, lam] = eig(A);



%%

[X,Y,Z] = ellipsoid(0,0,0,lam(1,1),lam(2,2),lam(3,3),100);


ROT = v*[X(:) Y(:) Z(:)]';
X = reshape(ROT(1,:),size(X));
Y = reshape(ROT(2,:),size(Y));
Z = reshape(ROT(3,:),size(Z));


hold on


s1 = surf(X,Y,-ones(101),'FaceColor',[0 0 0]);
s2 = surf(Z+1,Y,zeros(101),'FaceColor',[0 0 0]);
s3 = surf(X,Z+1,zeros(101),'FaceColor',[0 0 0]);
rotate(s2,[0 -1 0], 90,[1,0,0])
rotate(s3,[1 0 0], 90,[0,1,0])
s4 = surf(X,Y,Z);

s1.EdgeColor = 'none';
s2.EdgeColor = 'none';
s3.EdgeColor = 'none';
s4.EdgeColor = 'none';

axis equal

ax = gca;
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 1; % maximum line opacity
grid on

xlim([-1 1])
ylim([-1 1])
zlim([-1 1])

xticks([-1 -0.5 0 0.5 1])
yticks([-1 -0.5 0 0.5 1])
zticks([-1 -0.5 0 0.5 1])

set(gca,'TickLabelInterpreter', 'latex','fontsize',15);
title(strcat('Sample$ \ $',num2str(num),':$\ $ Orientation tensor'),'interpreter','latex','fontsize',15)
xlabel('$\boldmath{e}_1$','interpreter','latex','fontsize',15)
ylabel('$\boldmath{e}_2$','interpreter','latex','fontsize',15)
zlabel('$\boldmath{e}_3$','interpreter','latex','fontsize',15)

view(-45,20)
camlight('headlight')

end