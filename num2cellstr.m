function vect = num2cellstr(num)

% VECTOR INTO A CELL ARRAY OF STRINGS
vect = arrayfun(@num2str, num, 'Uniform', false)'
end
