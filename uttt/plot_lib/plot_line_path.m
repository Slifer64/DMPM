function plot_line_path(y_data,yd_data,y_label,yd_label,lineWidth,markerSize)

fontsize = 14;

if (nargin < 3), y_label = 'y'; end
if (nargin < 4), yd_label = 'y_d'; end
if (nargin < 5), lineWidth = 2; end
if (nargin < 6), markerSize = 10; end

D = size(y_data,1);

if (D == 2)
    figure;
    hold on;
    plot(y_data(1,:),y_data(2,:),'b',yd_data(1,:),yd_data(2,:),'g');
    plot(yd_data(1,1), yd_data(2,1),'mo','Markersize',markerSize, 'LineWidth',lineWidth);
    plot(yd_data(1,end), yd_data(2,end),'rx','Markersize',markerSize, 'LineWidth',lineWidth);
    legend({y_label, yd_label, 'start', 'end'}, 'Interpreter','latex', 'fontsize',fontsize);
    axis equal;
    hold off;
elseif (D == 3)
    figure;
    hold on;
    plot3(y_data(1,:),y_data(2,:),y_data(3,:),'b',yd_data(1,:),yd_data(2,:),yd_data(3,:),'g');
    plot3(yd_data(1,1), yd_data(2,1),yd_data(3,1),'mo','Markersize',markerSize, 'LineWidth',lineWidth);
    plot3(yd_data(1,end), yd_data(2,end),yd_data(3,end),'rx','Markersize',markerSize, 'LineWidth',lineWidth);
    legend({y_label, yd_label, 'start', 'end'}, 'Interpreter','latex', 'fontsize',fontsize);
    axis equal;
    hold off;
else
   error('Unsopported dimensionality of data D = %i',D); 
end

end

