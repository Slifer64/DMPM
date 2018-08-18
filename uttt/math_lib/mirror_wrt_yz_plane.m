function T = mirror_wrt_yz_plane(T)
	T(1,:) = -T(1,:);
	T(:,1) = -T(:,1);
end