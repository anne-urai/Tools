function [bestpar, bestval, bestat, step, delay, p] = ...
  fitparam (model, startpar, goalstat, typestat, randiter, optiter, tuneiter, nosession, statweight, parange) 

% function [bestpar, bestval, bestat, step, delay, p] = ...
%   fitparam (model, startpar, goalstat, typestat, randiter, optiter, tuneiter, nosession, statweight, parange)
%
% Fitting parameters of a connectionist model
% Required inputs:
%  model - string containing a name of Matlab function implementing the connectionist model, 
%          it should get as input the vector of parameters and return the values of statistics, i.e.
%          function statistics = model (parameters)
%  startpar - starting values of parameters
%  goalstat - the values of the statistics you want to achieve
%  typestat - vector of the same length as goalstat describing types of the statistics,
%             for each statistics should have one of the following values:
%             1 - if the statistics should match exactly (e.g. error rate)
%             2 - if the statistics should be matched by regression (e.g. reaction time)
%             3 - if the statistics should be matched by regression without intercept
%                 (e.g. difference between (or standard deviation of) reaction times)
% Optional inputs:
%  randiter - when = 0 -> the provided parameters are used as starting point for optimization
%             when > 0 -> number of itearions of random search for starting point (range of search space
%             is [0, 2*startpar], i.e. around the starting point; default = 0 
%  optiter - number of optimization iterations; default = 70
%  tuneiter - number of tuning iterations; default = 50
%  nosession - number of session of repeatition of the whole process; default = 1
%   Be careful with changing these parameters - they should depend on how fast is your function model,
%   i.e. function model will be called: nosession * (randiter + optiter + tuneiter + 20) times
%  statweight - vector describing how big emphasis should be made on each statistic during optimization
%               default: ones (1, length (goalstat))
%  parange - allowed range of parameters, matrix containing 2 columns with length = no of parameters
%	     the first column contains minimal, the second maximal values of params; default = no contraints
% Outputs:
%  bestpar - best sets of parameters found during each session
%  bestval - error for the corresponding set of parameters
%  bestat - values of the statistics for the corresponding set of parameters
%  step, delay - slopes and intercepts of RT regression: experimental RTs relates to model RTs as:
%                realRT = step * modelRT + delay
%  p - significance of difference between model and experimental statistics
% Since the optimization may take long time, every run the outputs are written to a file: bestmy.mat
%
% To see more details on the optimization procedure, see http://www.math.princeton.edu/~rbogacz/autofit
% To see an example of using the function, type: fitparam example
%
% Rafal Bogacz, Princeton University, August 2002

if nargin == 1 & strcmp (model, 'example')
 disp ('Let us consider the most simple and naive connectionist model of deciding between 2 stimuli');
 disp ('which is implemented in attached Matlab file: twodecision.m');
 disp ('This script implements a very simple model having just 2 processing units and 2 inputs:')
 disp (' Processing units:     A   B');
 disp ('                       |\ /|');
 disp ('                       | X |');
 disp ('                       |/ \|');
 disp (' Inputs:               A   B');
 disp ('The model (and function twodecision) has three parameters:');
 disp (' param(1) = weight of connections between inputs and correct outputs');
 disp (' param(2) = weight of connections between inputs and incorrect outputs');
 disp (' param(3) = magnitude of noise');
 disp ('Function twodecision runs model 1000 times and calculates the following statistics:');
 disp (' error rate');
 disp (' mean reaction time for correct');
 disp (' standard deviation of reaction times for correct');
 disp (' mean reaction time for incorrect');
 disp (' standard deviation of reaction times for incorrect');
 disp ('Assume that we want to fit the following values of the statistics:');
 disp ('ER=10%, RTcorrect=280ms, stdevRTcorrect= 70ms, RTincorrect=300ms, stdevRTincorrect= 70ms');
 disp ('Lets start the optimization from all the parameters equal to 0.1');
 disp ('To run just a single optimization session, type:');
 disp ('[par, val] = fitparam (''twodecision'', [0.1 0.1 0.1], [0.1 280 70 300 70], [1 2 3 2 3])');
 disp ('To do an extensive search with 100 sessions, type:');
 disp ('[par, val] = fitparam (''twodecision'', [0.1 0.1 0.1], [0.1 280 70 300 70], [1 2 3 2 3], 50, 70, 50, 100)');

elseif nargin < 4
 disp ('Too few input parameters.');
 disp ('To see help, type: help fitparam');

elseif ~ischar (model)
 disp ('The first parameter should be a string containing name of Matlab function with connectionist model');
 disp ('e.g. if the name of a function is: mymodel, type: fitparam (''mymodel'', ...');
 disp ('To see help, type: help fitparam');

elseif exist (model) < 2 | exist (model) > 6
 disp (['Cannot find Matlab function "' model '" describing connectionist model']);
 disp ('To see help, type: help fitparam');

else
 % checking required parameters
 if size (startpar, 1) > 1
  startpar = startpar';
 end
 if size (goalstat, 1) > 1
  goalstat = goalstat';
 end
 if size (typestat, 1) > 1
  typestat = typestat';
 end

if size (startpar, 1) ~= 1
 disp ('The second parameter should be a vector');
 disp ('To see help, type: help fitparam');

elseif size (goalstat, 1) ~= 1
 disp ('The third parameter should be a vector');
 disp ('To see help, type: help fitparam');

elseif size (typestat, 1) ~= 1
 disp ('The fouth parameter should be a vector');
 disp ('To see help, type: help fitparam');
 
elseif length (goalstat) ~= length (typestat)
 disp ('The third and the fourth parameters should be the vectors of the same length');
 disp ('To see help, type: help fitparam');

elseif nargin >= 9 & length (statweight) ~= length (goalstat)
 disp ('The parameter statweight should be a vector of the same length as goalstat');
 disp ('To see help, type: help fitparam');

elseif nargin >= 10 & (size (parange, 1) ~= length (startpar) | size (parange, 2) ~= 2)
 disp ('The parameter parange should be a matrix of size: # parameters by 2');
 disp ('To see help, type: help fitparam');
 
elseif sum (startpar == 0) > 0 & nargin < 10
 disp ('One of the starting parameters is equal to 0');
 disp ('Please provide range for starting parameters by providing optional input parameter: prange');

elseif nargin >= 10 & sum (parange(:,1) >= parange(:,2)) > 0
 disp ('In parameter parange, the nimimum range must be lower than the maximum range');
 
else
 % setting unset parameters
 if nargin < 5
  randiter = 0;
 end
 if nargin < 6
  optiter = 70;
 end
 if nargin < 7
  tuneiter = 50;
 end
 if nargin < 8
  nosession = 1;
 end
 if nargin < 9
  statweight = ones (1, length (goalstat));
 end
 if nargin < 10
  parange = [];
 end
 
 % prepare output variables
 nopara = length (startpar);
 goalen = length (goalstat);
 bestpar = zeros (nosession, nopara);
 bestval = ones (nosession, 1) * 10000;
 bestat = zeros (nosession, goalen);

 % handling starting parameters equal to 0
 startscaled = ones (1, nopara);
 for i = 1:nopara
  if startpar(i) == 0
   startpar(i) = mean(parange(i,:));
   if startpar(i) == 0
    startpar(i) = (parange(i,1) + 3*parange(i,2)) / 4;
   end
   startscaled(i) = 0;
  end
 end
 
 % do the optimization
 for iter = 1:nosession

  disp (sprintf ('Starting optimization session number: %d', iter)); 

  if randiter == 0
   bestpar (iter,:) = startscaled;
  else
   disp ('Searching for starting point of optimization');
   for i = 1:randiter
    if isempty(parange)
     param = 2*rand (1, nopara) + 0.1;
    else
     minrange = max (parange(:,1)'./startpar, 0.1);
     maxrange = min (parange(:,2)'./startpar, 2.1);
     param = (maxrange-minrange) .* rand (1, nopara) + minrange;
    end
    erp = fiterror (param, model, startpar, goalstat, typestat, 0, 1, statweight, parange);
    if erp < bestval(iter) | i == 1
     bestpar(iter,:) = param;
     bestval(iter) = erp;
    end
   end
  end

  options = zeros(1, 18);
  options (5) = 1;
  if optiter > 0
   disp ('Optimizing parameters');
   options (14) = optiter;
   options (18) = 0.3;
   bestpar (iter,:) = subplex ('fiterror', bestpar(iter,:), options, [], ...
   			  model, startpar, goalstat, typestat, 0, 1, statweight, parange);
  end
  if tuneiter > 0
   disp ('Tuning parameters');
   [bval, d] = fiterror (bestpar(iter,:), model, startpar, goalstat, typestat, 0, 10, statweight, parange);
   bestval (iter) = bval;
   options (14) = tuneiter;
   options (18) = 0.15;
   bestpar (iter,:) = subplex ('fiterror', bestpar(iter,:), options, [], ...
  	 		 model, startpar, goalstat, typestat, d, 1, statweight, parange);
  end
  disp ('Finding the final value of the cost function');
  [bval, d, bstat, st, de] = ...
  	fiterror (bestpar(iter,:), model, startpar, goalstat, typestat, 0, 10, ones(1,goalen), parange);
  bestval (iter) = bval;
  bestat (iter,:) = bstat;
  step (iter) = st;
  delay(iter) = de;
  bestpar (iter,:) = bestpar (iter,:) .* startpar;
  p(iter) = 1 - costdist (bval * 9/11, goalen, 1);
  save ('bestmy', 'bestpar', 'bestval', 'bestat', 'step', 'delay', 'p');
 end
 
end
end