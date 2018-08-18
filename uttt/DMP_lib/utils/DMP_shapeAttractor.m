%% Returns the shape attractor of the DMP.
%  @param[in] x: The phase variable.
%  @param[in] y0: initial position.
%  @param[in] g: Goal position.
%  @param[out] shape_attr: The shape_attr of the DMP.
function shape_attr = DMP_shapeAttractor(dmp, x, y0, g)

f = dmp.forcingTerm(x);
f_scale = dmp.forcingTermScaling(y0, g);
shape_attr = f * f_scale;

end