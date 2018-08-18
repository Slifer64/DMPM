function compare_demos_with_sim_results(demos,T,V,demos_sim,T_sim,V_sim)

% for i=1:length(demos_sim)
%     if (~isempty(find(isnan(demos_sim{i}))))
%         size(demos_sim{i})
%         isnan(demos_sim{i})
%         pause
%     end
% end

X = convert_pos_quat_to_sedsParams(demos);
X_sim = convert_pos_quat_to_sedsParams(demos_sim);



epsilon = 1e-30;
r = 0.6;
q = 1-r;

total_points = 0;
for i=1:length(T)
    total_points = total_points + length(T{i});
end



demos_sim2 = cell(size(demos_sim));
for i=1:length(demos_sim)
   for j=1:size(demos_sim{i},1)
       demos_sim2{i}(j,:) = interp1(T_sim{i},demos_sim{i}(j,:),T{i},'linear');
   end
end


pos_error = 0;
pos_n = 0;
orient_error = 0;
orient_n = 0;
error = 0;

for i=1:length(T)
    i
    X_pos = X{i}(1:3,:);
    X_pos_hat = X_sim{i}(1:3,1:4:end); 
    X_orient = demos{i}(3:6,:);
    X_orient_hat = demos_sim{i}(3:6,1:4:end);
    
%     figure
%     hold on;
%     plot3(X_pos(1,:),X_pos(2,:),X_pos(3,:));
%     plot3(X_pos_hat(1,:),X_pos_hat(2,:),X_pos_hat(3,:));
%     hold off;
%     pause;
%     close all;
    
    %pos_error = pos_error + dtw_pos_c(X_pos',X_pos_hat',min(floor(size(X_pos,2)/2),floor(size(X_pos_hat,2)/2)));
    pos_error = pos_error + dtw(X_pos',X_pos_hat',min(floor(size(X_pos,2)/2),floor(size(X_pos_hat,2)/2)),'pos');
    pos_n = pos_n + max(size(X_pos,2),size(X_pos_hat,2));
    orient_error = orient_error + dtw(X_orient',X_orient_hat',min(floor(size(X_orient,2)/2),floor(size(X_orient_hat,2)/2)),'orient');
    orient_n = orient_n + max(size(X_orient,2),size(X_orient_hat,2));
    for j=1:length(T{i})
        dx = demos{i}(1:end,j);
        dx_hat = demos_sim2{i}(1:end,j);
        %dx = demos{i}(d+1:end,j);
        %dx_hat = demos_sim{i}(d+1:end,j);
        if (norm(dx)==0 || norm(dx_hat)==0)
            total_points = total_points - 1;
            continue;
        end
%        temp = sqrt( r*(1-dx'*dx_hat/(norm(dx)*norm(dx_hat)+epsilon))^2 + q*(dx-dx_hat)'*(dx-dx_hat)/(norm(dx)*norm(dx_hat)+epsilon));
%         if (isnan(temp))
%             [i j]
%             dx
%             dx_hat
%             (1-dx'*dx_hat/(norm(dx)*norm(dx_hat)+epsilon))
%             (dx-dx_hat)'*(dx-dx_hat)/(norm(dx)*norm(dx_hat)+epsilon)
%             pause
%         end 
        error = error + sqrt( r*(1-dx'*dx_hat/(norm(dx)*norm(dx_hat)+epsilon))^2 + q*(dx-dx_hat)'*(dx-dx_hat)/(norm(dx)*norm(dx_hat)+epsilon));
    end
end

total_points
error = error/total_points
pos_n
pos_error = pos_error/pos_n
orient_n
orient_error = pos_error/pos_n

end


function X = convert_pos_quat_to_sedsParams(demos)

    X = cell(length(demos),1);
    for k=1:length(X)
        demos_k = demos{k};
        X_k = zeros(6,size(demos_k,2));
        for i=1:size(X_k,2)
            X_k(1:3,i) = demos_k(1:3,i);
            X_k(4:6,i) = demos_k(5:7,i); % e0 = nd*e - n*ed - cross(ed,e) = e for qd=[1 0 0 0]'
        end
        X{k} = X_k;
    end

end




