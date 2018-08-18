%% Returns the goal attractor gating factor.
%  @param[in] dmp: The dmp object.
%  @param[in] x: The phase variable.
function gAttrGat = DMP_goalAttrGating(dmp, x)

    gAttrGat = dmp.goalAttrGatingPtr.getOutput(x);
    gAttrGat(gAttrGat>1.0) = 1.0;

end