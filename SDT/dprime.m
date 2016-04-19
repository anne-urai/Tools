function [dprime, crit] = dprime(stim, resp)

% use only 2 identities, however this is coded
stim(stim~=1) = -1;
resp(resp~=1) = -1;

% compute proportions
Phit = length(find(stim ==  1 & resp == 1)) / length(find(stim == 1));
Pfa  = length(find(stim == -1 & resp == 1)) / length(find(stim == -1));

% correct for 100% or 0% values, will lead to Inf norminv output
if Phit == 1; Phit = .99;
elseif Phit == 0; Phit = .01; end
if Pfa == 0; Pfa = .01;
elseif Pfa == 1, Pfa = .99; end

% compute dprime and criterion
dprime = norminv(Phit) - norminv(Pfa);
crit   = -.5 * (norminv(Phit) + norminv(Pfa));

end