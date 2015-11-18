function[do_print,tolerance,fx_stop,max_eval,method,scale]=...
	do_options(options,nx)
	DEF_PRINT = 0;
	DEF_TOL = 1e-4;
	DEF_FXSTOP = 0;
	DEF_MEVAL = 100*nx;
	DEF_METHOD = 0;
	DEF_STEP = 0.1;
%
	[row,col] = size(options);
	if (col < 18)
		options(18) = 0;
	end
%
	if (options(1) < 1)
		do_print = DEF_PRINT;
	else
		do_print = options(1);
	end
%
	if (options(2) == 0)
		tolerance = DEF_TOL;
	else
		tolerance = options(2);
	end
%
	if (options(5) == 0)
		method = DEF_METHOD;
	else
		method = options(5);
	end
%
	if (options(8) == 0)
		fx_stop = DEF_FXSTOP;
	else
		fx_stop = options(8);
	end
%
	if (options(14) == 0)
		max_eval = DEF_MEVAL;
	else
		max_eval = options(14);
	end
%
	if (options(18) == 0)
		scale = DEF_STEP;
	else
		scale = options(18);
	end
	return
%end
