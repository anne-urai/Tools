function txt = pval2stars(pval)

for p = 1:length(pval),
    
if pval(p) < 1e-3
    txt{p} = '***';
elseif pval(p) < 1e-2
    txt{p} = '**';
elseif pval(p) < 0.05
    txt{p} = '*';
else
    % this should be smaller
    txt{p} = 'n.s.';
end

end