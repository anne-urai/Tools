function mergedTbl = tableAppend(tbl1, tbl2)
% mergedTbl = tableAppend(tbl1, tbl2)
% tbl1      - Main table to which tbl2 will be appended. This table will be
%             unmodified.
% tbl2      - Table that is being appended. Only the variables that are present
%             in tbl1 will be conserved.
%
% mergedTbl ~ Merged table where the variables of tbl1 are conserved and any
%             matching variables from tbl2 are appended and filled on
%             the missing variables with NaN if variable is numerical or 'NA' 
%             if it's a string.
%             
% IMPORTANT: The input order of tbl1 and tbl2 matters! 
%
% gP 4/2/2014

variableNames1 = tbl1.Properties.VariableNames;
variableNames2 = tbl2.Properties.VariableNames;

tbl2Nrows = height(tbl2);
tbl1Nvars = width(tbl1);

ixChar = cellfun(@ischar, table2cell(tbl1(1,:)));

tbl2Cell = cell(tbl2Nrows, tbl1Nvars);  % Convert tbl2 to cell with same size as tbl1
tbl2Cell(:, ~ixChar) = {NaN};          	% Fill numeric variables with NaN 
tbl2Cell(:, ixChar) = {'NA'};           % Fill string variables with 'NA'

for var2i=variableNames2,
    
    iVar1 = find( strcmpi(var2i, variableNames1) );
    
    if isempty(iVar1)           % If variable in tbl2 doesn't match any in tbl1
        continue
    end
    
    for r = 1:size(tbl2{:,var2i}, 1),
        tbl2Cell{r,iVar1} = tbl2{r,var2i};
    end
end
    
tbl2 = cell2table(tbl2Cell);
tbl2.Properties.VariableNames = variableNames1;

mergedTbl = [tbl1; tbl2];


