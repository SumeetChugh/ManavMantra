function q = unitquantizer(varargin)
%UNITQUANTIZER   Constructor for UNITQUANTIZER object
%   Q = UNITQUANTIZER(...) constructs a UNITQUANTIZER object, which is
%   the same as a QUANTIZER object in all respects except that its
%   QUANTIZE method quantizes numbers within eps(q) of 1 to exactly
%   1. See QUANTIZER for parameters.
%
%   Example:
%     u = unitquantizer([4 3]);
%     quantize(u,1)
%
%     q = quantizer([4 3]);
%     quantize(q,1)
%
%   See also QUANTIZER, QUANTIZER/UNITQUANTIZE.

%   Thomas A. Bryan, 11 August 1999
%   Copyright 1999-2010 The MathWorks, Inc.

% Built-in UDD constructor
q = embedded.unitquantizer;

if nargin > 0
  setquantizer(q,varargin{:});
end

