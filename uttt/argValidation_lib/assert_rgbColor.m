function assert_rgbColor(x)

 valid_color_ranges = true;
 for i=1:length(x)
	valid_color_ranges = valid_color_ranges && (0.0<=x(i)<=1.0);
 end

 assert(isnumeric(x) && length(x)==3 && valid_color_ranges, 'Input must be an rgb triplet with values in the range [0 1].');

end
