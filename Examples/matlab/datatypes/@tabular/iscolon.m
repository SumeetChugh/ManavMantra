function tf = iscolon(indices)
%ISCOLON Check if a set of variable or indices is ':'.

%   Copyright 2012-2015 The MathWorks, Inc. 

% Check ischar first to reject 58 and {':'}.
tf = ischar(indices) && isscalar(indices) && indices == ':';
