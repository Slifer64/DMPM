%% Returns the shape attractor gating factor.
%  @param[in] dmp: The dmp object.
%  @param[in] x: The phase variable.
function sAttrGat = DMP_shapeAttrGating(dmp, x)

    sAttrGat = dmp.shapeAttrGatingPtr.getOutput(x);
    sAttrGat(sAttrGat<0) = 0.0;

end