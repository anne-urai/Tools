function scalar = linearprojection(trial, template)

% implement this function
% Ai = Ri * Ravg / norm(Ravg)^2 (eq. 2, De Gee et al. 2014)
%     pupil_scalars = np.array([ np.dot(template, data[i,time_start:time_end])/np.dot(template,template) for i in range(data.shape[0])])

% make sure we have col vects
if ~iscolumn(trial),        trial = trial';         end
if ~iscolumn(template),     template = template';   end

% project and get a scalar out
scalar = dot(template, trial) / dot(template, template);

end