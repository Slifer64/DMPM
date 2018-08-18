function [str_file] = position_interpolation(q,t,initial_key,key,valueKey,str_file)

%----------------Initial Position------------------------
str_file=regexprep(str_file,initial_key,sprintf([num2str(q(1,1)) ' ' num2str(q(2,1)) ' ' num2str(q(3,1))]));
%--------------------------------------------------------

TOTALTIME = t(end);
KeyForAll = t;
NorKeyForAll = KeyForAll/TOTALTIME;

%-------------Interpolate Desired Position-------------
str_file=regexprep(str_file,key,sprintf([ num2str(NorKeyForAll(1)) '#NextValue' ])    );
for i=2:length(KeyForAll)
    str_file=regexprep(str_file,'#NextValue',sprintf([', ' num2str(NorKeyForAll(i)) '#NextValue'  ]) );
end
str_file=regexprep(str_file,'#NextValue',' ');

str_file=regexprep(str_file,valueKey,sprintf([num2str(q(1,1)) ' ' num2str(q(2,1)) ' ' num2str(q(3,1)) '#NextValue'  ])    );
for i=2:length(KeyForAll)
    str_file=regexprep(str_file,'#NextValue',sprintf([' ,\n'  num2str(q(1,i)) ' ' num2str(q(2,i)) ' ' num2str(q(3,i)) '#NextValue'  ]) );
end
str_file=regexprep(str_file,'#NextValue',' ');
%--------------------------------------------------------

end
