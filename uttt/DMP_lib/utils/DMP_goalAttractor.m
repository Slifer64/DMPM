%% Returns the goal attractor of the DMP.
%  @param[in] dmp: The DMP object.
%  @param[in] y: \a y state of the DMP.
%  @param[in] z: \a z state of the DMP.
%  @param[in] g: Goal position.
%  @param[out] goal_attr: The goal attractor of the DMP.
function goal_attr = DMP_goalAttractor(dmp, y, z, g)

goal_attr = dmp.a_z*(dmp.b_z*(g-y)-z);

end