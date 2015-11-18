function mydeal(S)
% http://quentinhuys.com/pub/mydeal.m

A=fieldnames(S);
for k=1:length(A)
    assignin('caller',A{k},S.(A{k}));
end
end