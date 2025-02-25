function [sortCode,msg] = variableEditorSortCode(~,varName,tableVariableNames,direction)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to sort table rows. The direction input
% is true for ascending sorts, false otherwise.

%   Copyright 2011-2015 The MathWorks, Inc.

msg = '';
if iscell(tableVariableNames)
    tableVariableNameString = '{';
    for k=1:length(tableVariableNames)-1
        tableVariableNameString = [tableVariableNameString tableVariableNames{k} ',']; %#ok<AGROW>
    end
    tableVariableNamesString = [tableVariableNameString tableVariableNames{end} '}'];
else
    tableVariableNamesString = tableVariableNames;
end
if direction
    sortCode = [varName ' = sortrows(' varName ',' tableVariableNamesString ',''ascend'');'];
else
    sortCode = [varName ' = sortrows(' varName ',' tableVariableNamesString ',''descend'');'];
end



