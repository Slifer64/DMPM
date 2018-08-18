function save_processed_demos(filename,demos,T,V)

demos = cell(length(T),1);

for i=1:length(T)
    demos{i} = Data(:,index(i):index(i+1)-1);
    if (~isempty(find(T{i}<0)))
        warning('Error: T{%d} has negative time values: (index, time_val)\n',i);
        [find(T{i}<0)' T{i}(find(T{i}<0))']
    end
    if (length(T{i}) ~= size(demos{i},2))
        error('length(T{%d})=%d != size(demos{%d},2)=%d\n',i,length(T{i}),i,size(demos{i},2));
    end
end

save(filename, 'demos', 'T', 'Q');

end