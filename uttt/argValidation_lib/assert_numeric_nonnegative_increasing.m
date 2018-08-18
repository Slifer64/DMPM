function assert_numeric_nonnegative_increasing(x)

 assert(isnumeric(x) && isempty(find(x<0)) && isempty(find(diff(x)<0)), 'Input must be positive scalar or a numeric vector with non-negative increasing values');


end
