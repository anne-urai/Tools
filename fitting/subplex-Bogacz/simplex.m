function [minx, fminx, num_eval, flag, last_prt] =  ...
	simplex(func,nx,scalev,ss_dim,setorder,minx,num_eval,...
		pass,last_prt,call_string,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10)
%
% SIMPLEX - simplex implements the Nelder-Mead simplex method to minimize
%       func on a subspace.  It is intended for use as a routine for the
%	subplex code and not intended for general use.  It may be invoked
%	indirectly through SUBPLEX using the METHOD option

%
%	original FORTRAN code for this implementation by:
%				 Tom Rowan
%				 Mathematical Sciences Section
%				 Oak Ridge National Laboratory
%				 rowan@msr.epm.ornl.gov
%	matlab version
%	coded by Bruce Lowekamp
%		 Mathematical Sciences Section
%		 Oak Ridge National Laboratory
%		 bruce@msr.epm.ornl.gov
%
%	based off an algorithm by J.A.Nelder and R.Mead
%		"A Simplex Method for Function Minimization",
%		Computer Journal, 7:308-13,1965.
%

% INPUT
%	func - name of function to optimize
%	nx - number of parameters for func
%	scalev - vector of stepsize magnitudes for the function's x
%	ss_dim - dimension of subspace being optimized by simplex
%	setorder - permutation of x
%	max_eval - maximum number of function evaluations to be performed
%	minx - minimum x so far
%	fminx - func evaluated at minx
%	num_eval - number of evaluations so far
%	do_print - flag on whether to print periodic updates
%	fxstop - value of f(x) to stop at
%	greek letters - constants for NMS
%	last_prt - the number of evaluations at which periodic printing was 
%		last done
%	call_string - parameters to be added on to call func
% OUTPUT
%	minx - the new minx, obtained by optimization
%	fminx - minx evaluated
%	num_eval - old num_eval plus calls for this time
%	flag - returns status based on reason for exiting
%		-1: max_eval exceeded
%		 0: tolerance reached
%		 1: limit of machine precision
%		 2: reached fstop
	TRUE = (1==1);
	FALSE = (1==0);
	alpha =	pass(1);
	beta = pass(2);
	gamma =	pass(3);
	delta =	pass(4);
	psi = pass(5);
	do_print = pass(6);
	fx_stop = pass(7);
	max_eval = pass(8);
    
%
%	initialize x so we can overlay the simplex for it
        xoverlay(nx) = 0;
	xoverlay(setorder)=ones(1,ss_dim);
	usex = minx .* (~xoverlay);
	simp_xvals(nx) = 0;
%
	numpoints = ss_dim +1;
%	create the initial simplx_sets
	tempvec(1:ss_dim) = minx(setorder(1:ss_dim));
	tempvec = rot90(tempvec,3);
	simplx_sets = tempvec;
	for i = 2:ss_dim
		simplx_sets = [simplx_sets tempvec];
	end
	simplx_sets = simplx_sets + diag(scalev(setorder));
%	test for coincident points
	if (any((diag(simplx_sets)+rot90(scalev(setorder),3)) == ...
		(diag(simplx_sets))))
		flag = 1;

        usex = minx;                      %added by R. Bogacz to avoid error: "Output arguments not assigned"
        eval (['fminx = ', call_string]); %added by R. Bogacz to avoid error: "Output arguments not assigned"

        return
	end
	simplx_sets = [tempvec simplx_sets];
%
% 	begin evaluating the function for the new simplx_sets
%
	for i = 1:numpoints
		simp_xvals(setorder) = simplx_sets(:,i);
		eval(['fxset(i)=',call_string]);
		num_eval = num_eval+1;
	end
%
%	calculate the 2 max and 1 min parameters for simplx_sets
%
	[tempvec, indices] = sort(fxset);
	ind_low = indices(1);
	ind_hi = indices(numpoints);
	ind_sec = indices(ss_dim);
%
%	calculate the point at which to stop this and go back to subplex
	tolerance = psi.^2 * sum((simplx_sets(:,ind_hi)-...
			simplx_sets(:,ind_low)).^2);
%
%
%
%	main loop
%
%
	cont = TRUE;
	while (cont)
	   centroid = rot90(sum(rot90(simplx_sets(:,[[1:(ind_hi-1)]...
				[(ind_hi+1):numpoints]]))) * (1.0/ss_dim),3);
%
%	   reflect
%
	   new_point = centroid+alpha*(centroid-simplx_sets(:,ind_hi));
	   coinc_test = (all(new_point == centroid) | all(new_point==...
		simplx_sets(:,ind_hi)));
	   if(~coinc_test)
	      simp_xvals(setorder) = new_point;
	      eval(['new_fx=',call_string]);
	      num_eval=num_eval+1;
	      if (new_fx < fxset(ind_low))
%
%	         expand
%
	         simplx_sets(:,ind_hi)=centroid-gamma*(centroid-new_point);
		 coinc_test = (all(simplx_sets(:,ind_hi)==centroid)|...
			all(simplx_sets(:,ind_hi)==new_point));
		 if (~coinc_test)
		     simp_xvals(setorder) = simplx_sets(:,ind_hi);
		     eval(['exp_fx=',call_string]);
		     num_eval = num_eval+1;
		     if (exp_fx < new_fx)
		        fxset(ind_hi) = exp_fx;
		     else
		        simplx_sets(:,ind_hi) = new_point;
		        fxset(ind_hi) = new_fx;
	 	     end
		 end
              elseif (new_fx < fxset(ind_sec))
%
%	         accept reflected points
%
	         simplx_sets(:,ind_hi) = new_point;
	         fxset(ind_hi) = new_fx;
	      else
%
%	         contract
%
	         if (new_fx > fxset(ind_hi))
		    new_point = centroid-beta*...
			(centroid-simplx_sets(:,ind_hi));
		    coinc_test =(all(new_point==centroid)|...
			   all(new_point==simplx_sets(:,ind_hi)));
	         else
		    tempvec=new_point;
		    new_point = centroid-beta*(centroid-tempvec);
		    coinc_test = (all(new_point==centroid)|...
			   all(new_point==tempvec));
	         end
	         if (~coinc_test)
		    simp_xvals(setorder)=new_point;
		    eval(['contr_fx=',call_string]);
		    num_eval=num_eval+1;
		    if (contr_fx < min(new_fx,fxset(ind_hi)))
		       simplx_sets(:,ind_hi) = new_point;
		       fxset(ind_hi) = contr_fx;
		    else
%
%   		       shrink simplex
%
		       coinc_test = FALSE;
		       if (ind_low > 1)
			       index = 1;
		       else
			       index = 2;
		       end
		       while ((index <=numpoints) & ~coinc_test)
			  if (index ~= ind_low)
			     tempvec = simplx_sets(:,index);
		             simplx_sets(:,index) = simplx_sets(:,ind_low)-...
				   delta* (simplx_sets(:,ind_low)-tempvec);
		             coinc_test =(all(simplx_sets(:,index)==...
				   	   simplx_sets(:,ind_low))|...
				      all(simplx_sets(:,index)==tempvec));
		             if (~coinc_test)
			        simp_xvals(setorder)=simplx_sets(:,index);
			        eval(['fxset(index)=',call_string]);
			        num_eval= num_eval+1;
		             end
			  end
			     index = index + 1;
	               end
                    end
                 end % contract if
	      end % if-elseif-else from reflect
	   end % reflect if
%
%	calculate the 2 max and 1 min parameters for simplex
%
	old_hi = ind_hi;
	old_sec = ind_sec;
	old_low = ind_low;
	[tempvec, indices] = sort(fxset);
	if (nx == 1)
	     	ind_low = indices(1);
	     	ind_hi = indices(2);
	     	ind_sec = indices(1);
	else
		new_low = indices(1);
		new_hi = indices(numpoints);
		new_sec = indices(ss_dim);
		if (fxset(new_hi)>fxset(old_hi))
			ind_hi = new_hi;
			if(fxset(new_sec)>fxset(old_hi))
				ind_sec = new_sec;
			else
				if (old_hi ~= new_hi)
					ind_sec = old_hi;
				elseif (fxset(new_sec) > fxset(old_sec))
					ind_sec = new_sec;
				else
					ind_sec = old_sec;
				end
			end
		else
			ind_hi = old_hi;
			if(fxset(new_hi)>fxset(old_sec))
				if (old_hi ~= new_hi)
					ind_sec = new_hi;
				elseif(fxset(new_sec) > fxset(old_sec))
					ind_sec = new_sec;
				else
					ind_sec = old_sec;
				end
			else
				ind_sec = old_sec;
			end
		end
		if (fxset(new_low) < fxset(old_low))
			ind_low = new_low;
		else
			ind_low = old_low;
		end;
	end
%
%	   output some intermediate values	   
%
	   if (do_print)
	      if (round(num_eval/do_print) > last_prt)
		     status = [fxset(ind_low) fxset(ind_hi) ...
				(sum(scalev(setorder))/ss_dim)];
		     clc;
		     disp('Update')
		     format short;
		     disp ('Number Evaluations')
		     num_eval
		     format short e;
		     disp ('Current Low    Current High   Average Step');
		     status
		     last_prt = round(num_eval/do_print);
	      end
	   end

%
%	   check for termination
%
	   if (num_eval > max_eval)
	      flag = (-1);
	      cont = FALSE;
	   elseif (coinc_test | sum((simplx_sets(:,ind_hi)-...
			simplx_sets(:,ind_low)).^2)<tolerance)

	      flag = 0;
	      cont = FALSE;
	   elseif (fx_stop ~= 0)
		if (fxset(ind_low) < fx_stop)
			flag = 2;
			cont = FALSE;
		end
	   end
	end % main while
%
%	end of simplex, return best point
%
	simp_xvals(setorder)=simplx_sets(:,ind_low);
	minx = usex+simp_xvals;
	fminx = fxset(ind_low);
	return
%	end
