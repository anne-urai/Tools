function [xbest, fx, num_eval, info]=...
    subplex(func,x,opt1,blank,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
% SUBPLEX -
%  	SUBPLEX uses the subplex method to solve unconstrained
% 	optimization problems.  The method is well suited for
% 	optimizing objective functions that are noisy or are
% 	discontinuous at the solution.  SUBPLEX performs a
%	minimization.
%		To aid in porting between FMINS and SUBPLEX, the
%	arguments have been made identical, with some exceptions.
%	The standard calling form of:
%		XBEST=SUBPLEX('FUNC',STARTX)
%	is supported, as is a more extensive set of return parameters:
%		[XBEST,FXBEST,NUM_EVAL,INFO]=SUBPLEX('FUNC',STARTX)
%	The OPTIONS argument is also supported, as is the additional
%	argument form, available as:
%		SUBPLEX('FUNC',STARTX,OPTIONS) and
%		SUBPLEX('FUNC',STARTX,OPTIONS,[],P1{,P2{...}})
%			({} specifies optional parameters)
%	Of course, both output options are supported with either of these.
%		For more help on arguments see subplex_options
%		For more information, see about_subplex

%
%	algorithm design and
%	original fortran code by:	Tom Rowan
%					Mathematical Sciences Section
%					Oak Ridge National Laboratory
%					rowan@msr.epm.ornl.gov
%	matlab version
%	coded by:	Bruce Lowekamp
%			Mathematical Sciences Section
%			Oak Ridge National Laboratory
%			bruce@msr.epm.ornl.gov
%
%
eval_string = ' ';
call_string = '[cur_x,cur_fx,num_eval,fflag,last_prt]=simplex(func,nx,step_size,ss_dimen,order(whichx:(whichx+ss_dimen-1)),cur_x, num_eval, pass, last_prt,eval_string';
if (nargin < 2)
    disp ('Error, I expected at least 2 parameters')
    info = -2;
    return
end
%
%  Check input parameters
%
if (~(isstr(func)))
    error ('FUNC must be passed as a string')
end

[row,col] = size(x);
if ((row > 1) | (col < 1))
    disp ('X must be a vector')
    info = -2
    return
end
startx = x;
nx = col;

if (nargin > 2)
    [row,col]=size(opt1);
    [do_print,tolerance,fx_stop,max_eval,method,scale]=...
        do_options(opt1,nx);
    if (nargin > 3)
        if (~isempty(blank))
            disp ('I expected [] after OPTIONS')
            info = -2
            return
        end
        if (nargin < 5)
            disp ('I expected at least one passed parameter')
            info = -2
            return
        end
        for count = 5:nargin
            eval_string = [eval_string,',p',num2str(count-4)];
            call_string = [call_string,',p',num2str(count-4)];
        end
    end
else
    opt1(18) = 0;
    [do_print,tolerance,fx_stop,max_eval,method,scale]=...
        do_options(opt1,nx);
end
call_string = [call_string,');'];
%
% Theoretically, all of the input is correct and we are ready to begin
%

%	First, we set up some basic constants
alpha = 1.0;
beta = 0.5;
gamma = 2.0;
delta = 0.5;
psi = 0.25;
omega = .1;
TRUE = (1==1);
FALSE = (1==0);

%	These next two variables specify a range of subspace dimensions.
%	They must satisfy 1 .le. subspc_min .le subspc_max .le. n, and
%	so that nx can be expressed as a sum of positive integers, whose
%	elements are in the range [subspc_min,subspc_max]
%
%	These parameters are varied to produce different methods.
%	conventional subplex
if (method == 0)
    subspc_min = min(2, nx);
    subspc_max = min(5,nx);
else
    %	N-M simplex
    subspc_min = nx;
    subspc_max = nx;
    if (method == 1)
        %		plain N-M
        psi = eps;
    end
    %		(else with restarts)
end
%
reverse = (nx:-1:1);
%
%	Now that we have our constants, let's do some basic initialization
%	check for convergence
if (any((startx + scale)==startx))
    info = -2;
    return
end
%	turn scale into a vector
step_size = ones(1,nx)*scale;
delta_x = step_size;
%	initialize the permutation order
order = (1:nx);
%	get an initial point for func
cur_fx = eval([func,'(startx', eval_string,')']);
eval_string = [func,'((usex+simp_xvals)',eval_string,');'];
num_eval = 1;
cur_x = startx;
pass =[alpha,beta,gamma,delta,psi,do_print,fx_stop,max_eval];
%
%	MAIN LOOP******************************
%		Note that this is not exactly the way the original
%		fortran was set up.  Certain elements have been moved
%		further down in the calling sequence to eliminate the
%		need for static memory allocation and other things
%		have been reorganized to eliminate the need for goto's
tflag = FALSE;
last_prt = 0;

while (~(tflag))
    delta_x = abs(delta_x);
    [tempvec,order] = sort(delta_x);
    order = order(reverse);
    [num_subspaces, subsp_dims] =...
        partitionx(nx, order, delta_x,subspc_min, subspc_max);
    % 		This code is used when the recursive version is desired
    %		delta_x = delta_x(order);
    %		subsp_dims = partitionx(nx, delta_x,subspc_min, subspc_max);
    %		[dummy,num_subspaces] = size(subsp_dims);
    %
    delta_x = cur_x;
    %
    %		simplex loop
    %
    cur_ssnum = 1;
    whichx = 1;
    ss_dimen = 0;
    tflag = FALSE;
    while ((cur_ssnum <= num_subspaces) & (tflag == FALSE))
        whichx = ss_dimen + whichx;
        ss_dimen = subsp_dims(cur_ssnum);
        
        eval (call_string);
        if (fflag)
            tflag = TRUE;
            info = fflag;
        end
        cur_ssnum = cur_ssnum + 1;
    end
    %
    %		we exited either because we optimized all of the subspaces
    %		or simplex returned a flag for some reason.
    
    %		Now we need to see if tolerance is satisfied
    delta_x = cur_x - delta_x;
    if (~(tflag))
        step = 0;
        expr_value = TRUE;
        while ((step < nx) & expr_value)
            step = step + 1;
            expr_value = (max(abs(delta_x(step)),...
                abs(step_size(step))*psi)/...
                max(abs(cur_x(step)),1)) <= tolerance;
        end
        
        if (~expr_value)
            % 				in this case, we rescale a little, then go back
            %				to simplex
            if (num_subspaces > 1)
                step_factor = min(max(sum(abs(delta_x))/...
                    sum(abs(step_size)),omega), 1.0/omega);
            else
                step_factor = psi;
            end
            
            step_size = step_size * step_factor;
            %
            %				reorient simplex
            %
            step_size = abs(step_size).*...
                (-2*(delta_x <= 0)+ones(1,nx));
        else
            %			tolerance is satisfied
            tflag = TRUE;
            info = 0;
        end
    end
end


xbest = cur_x;
fx = cur_fx;
return
%	end

