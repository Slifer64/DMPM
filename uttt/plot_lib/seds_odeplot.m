function status = seds_odeplot(t,s,flag)

	global figH sp1H sp2H animeLineH

	if (strcmpi(flag,'init'))
		figH = figure('Name','seds odeplot','NumberTitle','off');
		set(groot,'CurrentFigure',figH); % Set this figure as the current one.
		sp1H = subplot(2,1,1); % Create and activate subplot 1.
		set(sp1H,'Parent',figH);
		xlim(t)
		sp2H = subplot(2,1,2); % Create and activate subplot 2.
		set(sp2H,'Parent',figH);
		xlim(t)
		
		% Create the animated lines. Initially these lines will have as parent
		% the current active supblot, that is subplot 2. We overwrite that
		% later on.
		animeLineH = [animatedline; animatedline; animatedline; animatedline; animatedline; animatedline];
		animeLineH(1).Color = [0 0 1]; % blue
		animeLineH(2).Color = [0 1 0]; % green
		animeLineH(3).Color = [1 0 0]; % red
		animeLineH(4).Color = [0 1 1]; % white blue
		animeLineH(5).Color = [1 0 1]; % magenta
		animeLineH(6).Color = [0.2 0.5 0.4];
		
		% Assign the first 3 lines to the 1st subplot and the last 3 lines to
		% the 2nd subplot
		set(animeLineH(1:3),'Parent',sp1H);
		set(animeLineH(4:6),'Parent',sp2H);

		pos_quat = s;
		X = [pos_quat(1:3); pos_quat(5:7)];

		% Activate sp1 so that the legend command 'legend('e_x','e_y','e_z');' will assign 
		% the legend to this subplot. The animeLines are already assigned so if we were to 
		% omit the kernel of sp1, the lines would be still plotted in the right subplot.
		subplot(sp1H) 
		for k=1:3
			addpoints(animeLineH(k),t(1),X(k));
		end
		title('position errors');
		legend('e_x','e_y','e_z');
		
		% Activate sp2 so that the legend command 'legend('e0_1','e0_2','e0_3');' will assign 
		% the legend to this subplot. The animeLines are already assigned so if we were to 
		% omit the kernel of sp1, the lines would be still plotted in the right subplot.
		subplot(sp2H)
		for k=4:6
			addpoints(animeLineH(k),t(1),X(k));
		end
		title('orientation errors');
		legend('e0_1','e0_2','e0_3');
		
		drawnow;
	elseif (isempty(flag))
		for i=1:length(t)
			s_i = s(:,i);
			pos_quat = s_i;
			X = [pos_quat(1:3); pos_quat(5:7)];

			% Even if another figure is the current figure, these lines will be
			% plotted in the right subplots, namely in their parents
			for k=1:3
				addpoints(animeLineH(k),t(1),X(k));
			end
			for k=4:6
				addpoints(animeLineH(k),t(1),X(k));
			end
		end
		drawnow;
	elseif (strcmpi(flag,'done'))
		clear figH sp1H sp2H animeLineH
	end

	status = 0;

end
