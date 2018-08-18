function assert_cell_with_strings(x)

 assert( iscell(x) && (isempty(x) || sum(cellfun(@(y) ~ischar(y), x))==0 ), 'Input must be a cell array of strings.');


end
