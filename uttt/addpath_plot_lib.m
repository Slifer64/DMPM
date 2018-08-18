function addpath_plot_lib(MAIN_PATH)

	addpath([MAIN_PATH '/plot_lib/']);
	
	% add dependencies from other libraries
    addpath_math_lib(MAIN_PATH);
    addpath_signalProcessing_lib(MAIN_PATH);
    addpath_argValidation_lib(MAIN_PATH);

end
