function [dprime, crit] = dprime(stim, resp)

% if there was only one stimulus class shown, this whole thing doesn't make
% sense
if length(unique(stim(~isnan(stim)))) == 1,
    dprime = NaN; crit = NaN;
    return;
end
    
% use only 2 identities, however this is coded
stim(stim~=1) = -1;
resp(resp~=1) = -1;

% compute proportions
Phit = length(find(stim ==  1 & resp == 1)) / length(find(stim == 1));
Pfa  = length(find(stim == -1 & resp == 1)) / length(find(stim == -1));

% correct for 100% or 0% values, will lead to Inf norminv output
if Phit > 0.999;     Phit = 0.999;
elseif Phit < 0.001; Phit = .001; end
if Pfa < 0.001;      Pfa = 0.001;
elseif Pfa > 0.999,  Pfa = 0.999; end

% compute dprime and criterion
dprime = norminv(Phit) - norminv(Pfa);
crit   = -.5 * (norminv(Phit) + norminv(Pfa));

end
