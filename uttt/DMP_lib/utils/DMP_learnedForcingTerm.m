%% Returns the learned forcing term.
%  @param[in] dmp: The dmp object.
%  @param[in] x: The phase variable.
%  @param[in] y0: initial position.
%  @param[in] g: Goal position.
%  @param[out] learnForcTerm: The learned forcing term.
function learnForcTerm = DMP_learnedForcingTerm(dmp, x, y0, g)

    learnForcTerm = dmp.shapeAttrGating(x) * dmp.forcingTerm(x) * dmp.forcingTermScaling(y0, g);

end