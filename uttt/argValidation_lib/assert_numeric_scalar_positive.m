function assert_numeric_scalar_positive(x)

 assert(isnumeric(x) && isscalar(x) && (x > 0), 'Value must be positive, scalar, and numeric.');

end
