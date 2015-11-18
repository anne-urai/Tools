function [y] = fun_constr(beta1,CL,pm,binom,prc_cor,x,nTrials)
% cost function with constraints

% if ~issorted(beta1(:,1)) || ~issorted(beta1(:,2)) || beta1(4,2)/beta1(1,2)>2 || beta1(1,2)<beta1(4,2)/2
%     y=10e10;
%     return;
% end

for i = 1 : 4
    y(i,:)=double(-sum(log(binom(i,:))+...
        (prc_cor(i,:).*nTrials(i,:)).*log(CL(i)+(1-2*CL(i)-pm)*(1-exp(-(x/beta1(i,1)).^beta1(i,2))))+...
        ((1-prc_cor(i,:)).*nTrials(i,:)).*log(1-(CL(i)+(1-2*CL(i)-pm)*(1-exp(-(x/beta1(i,1)).^beta1(i,2)))))));
end

if ~isreal(y)
    y=10e10;
    return;
end

if any(isinf(y)) || any(isinf(y))
    y=10e10;
    return;
end

y = sum(y);


% for i = 1 : 4
% y(i,:)=double(-sum(log(binom(i,:))+...
%     (prc_cor(i,:).*nTrials(i,:)).*log(CL(i)+(1-2*CL(i)-pm)*(1-exp(-(x/beta1(i,1)).^beta1(i,2))))+...
%     ((1-prc_cor(i,:)).*nTrials(i,:)).*log(1-(CL(i)+(1-2*CL(i)-pm)*(1-exp(-(x/beta1(i,1)).^beta1(i,2)))))));
% end
%
% if ~isreal(y)
%     y=10e10;
%     return;
% end
%
% if any(isinf(y)) || any(isinf(y))
%    y=10e10;
%    return;
% end
%
% y = sum(y);
%
%

