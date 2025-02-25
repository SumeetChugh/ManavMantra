function [x,ok] = str2num(s)
%STR2NUM Convert character array or string scalar to numeric array
%   X = STR2NUM(S) converts a character array or string scalar  
%   representation of a matrix of numbers to a numeric matrix. For example,
%       
%        S = ['1 2'         str2num(S) => [1 2;3 4]
%             '3 4']
%
%   The numbers in S should be text representations of a numeric values.  
%   Each number may contain digits, a decimal point, a leading + or - sign, 
%   an 'e' or 'd' preceding a power of 10 scale factor, and an 'i' or 'j' for 
%   a complex unit.
%
%   If S does not represent a valid number or matrix, STR2NUM(S) returns 
%   the empty matrix.  [X,OK]=STR2NUM(S) returns OK=0 if the conversion fails.
%
%   CAUTION: STR2NUM uses EVAL to convert the input argument, so side
%   effects can occur if S contains calls to functions.  Use
%   STR2DOUBLE to avoid such side effects or when S contains a single
%   number.
%
%   Also spaces can be significant.  For instance, str2num('1+2i') and 
%   str2num('1 + 2i') produce x = 1+2i while str2num('1 +2i') produces
%   x = [1 2i].  These problems are also avoided when you use STR2DOUBLE.
%
%   See also STR2DOUBLE, NUM2STR, HEX2NUM, CHAR.

%   Copyright 1984-2016 The MathWorks, Inc.

if nargin > 0
    s = convertStringsToChars(s);
end

if ~ischar(s) || ~ismatrix(s)
   error(message('MATLAB:str2num:InvalidArgument'))
end

if isempty(s)
    x = [];
    ok=false;
    return
end

% Replace any char(0) characters with spaces
s(s==char(0)) = ' ';

[m,n] = size(s);
if m==1,
  [x,ok] = protected_conversion(['[' s ']']); % Always add brackets
else
    semi = ';';
    space = ' ';
    if ~any(any(s == '[' | s == ']')), % String does not contain brackets
        o = ones(m-1,1);
        s = [['[';space(o)] s [semi(o) space(o);' ]']]';
    elseif ~any(any(s(1:m-1,:) == semi)), % No ;'s in non-last rows
        s = [s,[semi(ones(m-1,1));space]]';
    else                               % Put ;'s where appropriate
        spost = space(ones(m,1));
        for i = 1:m-1,
            last = find(s(i,:) ~= space,1,'last');
            if s(i,n-last+1) ~= semi,
                spost(i) = semi;
            end
        end
        s = [s,spost]';
    end
    [x,ok] = protected_conversion(s);
end
if isnumeric(x)
    return
end
if ischar(x) || iscell(x)
   x = [];
   ok = false;
end

function [STR2NUM_VaR,ok] = protected_conversion(STR2NUM_StR)
% Try to convert the string into a number.  If this fails, return [] and ok=0
% Protects variables in STR2NUM from "variables" in s.

try
    STR2NUM_VaR = eval(STR2NUM_StR);
    ok = true;
catch exception %#ok
    STR2NUM_VaR = [];
    ok = false;
end
