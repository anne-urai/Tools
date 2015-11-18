function out = zipvects(in1, in2)
% 'zips' two vectors

% put in the same shape
in1 = in1(:);
in2 = in2(:);

n1 = length(in1);
n2 = length(in2);

% these have to be the same size
assert(isequal(n1, n2), 'inputs are not the same length');

% turn everything into cells
if iscell(in1) || iscell(in2),
    
    if ~iscell(in1),
        if isnumeric(in1),
            in1 = num2cell(in1);
            in1 = in1(:);
        end
    end
    
     if ~iscell(in2),
        if isnumeric(in2),
            in2 = num2cell(in2);
            in2 = in2(:);
        end
     end
     
     % prepare the output
     out = {};
     for i = 1:n1,
         out = cat(1, out, in1{i});
         out = cat(1, out, in2{i});
     end

end

if isnumeric(in1) && isnumeric(in2),
    
    % prepare the output
    out = [];
    for i = 1:n1,
        out = cat(1, out, in1(i));
        out = cat(1, out, in2(i));
    end
end


end