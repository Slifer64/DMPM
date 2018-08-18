function addpath_SEDS_lib(MAIN_PATH)

	addpath([MAIN_PATH '/SEDS_lib/']);
	
	% add dependencies from other libraries
	addpath_GMR_lib(MAIN_PATH);

end
