function fullresidual = projectout(vector, whattoprojectout)
% projects one vector out of the other
% Anne Urai, 2015

% make sure everything is the same size
vector = vector(:); whattoprojectout = whattoprojectout(:);

% ignore nans
idx2use = (~isnan(vector));
idx2use(find(isnan(whattoprojectout))) = 0;

prj = whattoprojectout(idx2use)/norm(whattoprojectout(idx2use)); % take the norm of vector you want to project out

% project out the reference vector
residual = vector(idx2use) - (vector(idx2use)'*prj)*prj; % subtract dot product, and that's it

% in case there were NaNs, return those in the output
fullresidual = nan(size(vector));
fullresidual(idx2use) = residual;

if all(isnan(fullresidual))
    fullresidual = vector;
    fullresidual(idx2use) = residual;
end
    
end