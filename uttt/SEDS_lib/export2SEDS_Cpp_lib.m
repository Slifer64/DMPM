function out = export2SEDS_Cpp_lib(name,Priors,Mu,Sigma)

    dlmwrite(name, size(Mu),'Delimiter',' ','precision','%i');
    dlmwrite(name, Priors,'newline','pc','-append','Delimiter',' ','precision','%.16f');
    dlmwrite(name, reshape(Mu,1,[]),'newline','pc','-append','Delimiter',' ','precision','%.16f');
    for i=1:size(Mu,2)
        dlmwrite(name, reshape(Sigma(:,:,i),1,[]),'newline','pc','-append','Delimiter',' ','precision','%.16f');
    end
    out = true;

end