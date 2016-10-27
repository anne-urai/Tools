function out = permtest(a,b,tail,nrand)
% paired or one-sample permutation test

if ~exist('b', 'var'),      b = zeros(size(a)); end
if ~exist('nrand', 'var'),  nrand = 10000; end
if ~exist('tail', 'var'),   tail = 0; end

a = a(:);
b = b(:);
if numel(b) == 1, b = b*ones(size(a)); end % expand b

% if there are nans, ignore
if any(isnan(a)) || any(isnan(b)),
    validIdx = ~isnan(a) & ~isnan(b);
    a = a(validIdx);
    b = b(validIdx);
end

% compute the means of the intact data
meana = mean(a);
meanb = mean(b);

triala = zeros(1, nrand);
trialb = triala;
alldat = [a b];
shufdat = alldat;

for irand = 1:nrand,
    
    % create a shuffling vector
    for i = 1:length(a),
        shufdat(i, :) = alldat(i, randperm(size(shufdat,2)));
    end
    
    triala(irand) = mean(shufdat(:, 1));
    trialb(irand) = mean(shufdat(:, 2));
    
end

% based on the tail, compute our pvalue
switch tail
    case 0
        out = length(find(abs(triala-trialb) >= abs(meana-meanb)))/nrand;
    case {-1,1}
        out = length(find(tail*(triala-trialb) >= tail*(meana-meanb)))/nrand;
end

end

