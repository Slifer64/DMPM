function plot_psi_kernels_and_psiWeightedSum(x_data,Psi_data, f_data, c, w)

lineWidth = 2;
fontsize = 14;

N_kernels = size(Psi_data,1);
figure;
subplot(2,1,1);
hold on;
for i=1:N_kernels
    plot((x_data),(Psi_data(i,:)));
    axis tight;
end
title('Psi kernels','Interpreter','latex','fontsize',fontsize);
set(gca,'Xdir','reverse');
hold off;
subplot(2,1,2);
hold on;
plot((x_data),(f_data),'LineWidth',lineWidth,'Color',[0 1 0]);
bar(c,w);
title('Weighted summation','Interpreter','latex','fontsize',fontsize);
set(gca,'Xdir','reverse');
xlim([0 1]);
axis tight;
hold off;

end