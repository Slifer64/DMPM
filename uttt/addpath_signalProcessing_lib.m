function addpath_signalProcessing_lib(MAIN_PATH)

	addpath([MAIN_PATH '/signalProcessing_lib/']);
	
	% add dependencies from other libraries
    addpath_math_lib(MAIN_PATH);

end
