function out = rocAnalysis(x,y,tail,nrand)
%
% function out = rocAnalysis(x,y,tail,nrand);
% x, y: vectors of observations from two conditions 
% tail = 0 (test i~=0.5), 1 (test i>0.5), -1 (test i<0.5);
% nrand: number of randomizations for permutation test

x = x(:);
y = y(:);
nx = length(x);
ny = length(y);
z = [x(:);y(:)];
c = sort(z);

% preallocate
det = nan(length(c), 2);
for ic = 1:length(c);
    det(ic, 1) = mean(x>c(ic));
    det(ic, 2) = mean(y>c(ic));
end

[t1,t2] = sort(det(:,1));
roc = [[0,0]; det(t2,:); [1,1]];
t1 = cumtrapz(roc(:,1),roc(:,2));

% output the indices
out.i = t1(end);
out.roc = roc;

% randomize
trialx = zeros(nrand);
trialy = trialx;
alldat = [x(:);y(:)];
for irand = 1:nrand
    if ~mod(irand,1000)
        fprintf('randomization: %d\n',irand)
    end
    [t1,ind] = sort(rand(nx+ny,1));
    ranx = z(ind(1:nx));
    rany = z(ind(nx+1:end));
    randc = sort([ranx(:);rany(:)]);
    
    % loop over different criteria
    randet = nan(length(randc), 2);
    for ic = 1:length(randc);
        % mean of logical is twice as fast as length(find)
        randet(ic,1) = mean(ranx>randc(ic));
        randet(ic,2) = mean(rany>randc(ic));
    end
    [t1,t2] = sort(randet(:,1));
    ranroc = [[0,0];randet(t2,:);[1,1]];
    t1 = cumtrapz(ranroc(:,1),ranroc(:,2));
    randi(irand) = t1(end);
end

% compute the p value
switch tail
    case 0
        out.p = length(find(abs(randi-0.5) >= abs(out.i-0.5)))/nrand;
    case {-1,1}
        out.p = length(find(tail*(randi-0.5) >= tail*(out.i-0.5)))/nrand;
end