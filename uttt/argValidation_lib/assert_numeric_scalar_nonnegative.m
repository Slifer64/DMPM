function assert_numeric_scalar_nonnegative(x)

 assert(isnumeric(x) && isscalar(x) && (x >= 0), 'Value must be nonnegative, scalar, and numeric.');

end
