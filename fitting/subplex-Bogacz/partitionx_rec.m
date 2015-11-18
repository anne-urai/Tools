function ss_dimen = partitionx(nx, deltax, subs_min,subs_max)
%
%	partition the space defined by deltax(order) into a group
%	of sets, such that subs_max <= k <= subs_max for all sets
%	of size k.  Where possible, pick combinations of points
%	which maximize a-b, where a is the norm of the new set /k and
%	b is the norm of the remainder over (nx-k).
%
%	This version is a recursive implementation of the algorithm.
%	It is implemented exactly as described in Tom Rowan's original
%	thesis and is clearer than the implementation used in partitionx.m
%	However, in the interests of attempting to provide identical results
%	between the FORTRAN and MATLAB implementations of this algorithm,
%	the direct translation of the FORTRAN was used because of
%	differences between the results the algorithm gives in the case of
%	ties.
%
	if (nx < 2*subs_min)
		ss_dimen = nx;
		return
	end
%
%	maximum size we can generate here
	max_size = min(nx, subs_max);
	best_dist = -1;
%
%	clear out the variable for keeping track of sizes
	dist_sz(1:max_size) = zeros(1,max_size);
%
%	now go through and calculate distances for most of the terms
	for size = subs_min:(max_size-1)
	    if (subs_min*ceil((nx-size)/subs_max)<=(nx-size))
		dist_sz = sum(deltax(1:size))/size - ...
			  sum(deltax(size+1:nx))/(nx-size);
		if (dist_sz > best_dist)
			best_dim = size;
			best_dist = dist_sz;
		end
	    end
	end
%
%	Handle special case when max_size = nx
%
	if (subs_min*ceil((nx-max_size)/subs_max)<=(nx-max_size))
	    if (max_size == nx)
		dist_sz = sum(deltax(1:max_size))/max_size;
	    else
		dist_sz = sum(deltax(1:max_size))/max_size - ...
			  sum(deltax(max_size+1:nx))/(nx-max_size);
	    end
	    if (dist_sz > best_dist)
		best_dim = max_size;
	    end
	end
	
%
	if (best_dim == nx)
		ss_dimen = best_dim;
        else
		ss_dimen = [best_dim (partitionx((nx-best_dim),...
				deltax(best_dim+1:nx),subs_min, ...
				subs_max))];
	end
	return
end	

