function x = idwt(a,d,varargin)
%IDWT Single-level inverse discrete 1-D wavelet transform.
%   IDWT performs a single-level 1-D wavelet reconstruction
%   with respect to either a particular wavelet
%   ('wname', see WFILTERS for more information) or particular wavelet
%   reconstruction filters (Lo_R and Hi_R) that you specify.
%
%   X = IDWT(CA,CD,'wname') returns the single-level
%   reconstructed approximation coefficients vector X
%   based on approximation and detail coefficients
%   vectors CA and CD, and using the wavelet 'wname'.
%
%   X = IDWT(CA,CD,Lo_R,Hi_R) reconstructs as above,
%   using filters that you specify:
%   Lo_R is the reconstruction low-pass filter.
%   Hi_R is the reconstruction high-pass filter.
%   Lo_R and Hi_R must be the same length.
%
%   Let LA = length(CA) = length(CD) and LF the length
%   of the filters; then length(X) = LX where LX = 2*LA
%   if the DWT extension mode is set to periodization.
%   LX = 2*LA-LF+2 for the other extension modes.
%   For the different DWT extension modes, see DWTMODE. 
%
%   X = IDWT(CA,CD,'wname',L) or X = IDWT(CA,CD,Lo_R,Hi_R,L)
%   returns the length-L central portion of the result
%   obtained using IDWT(CA,CD,'wname'). L must be less than LX.
%
%   X = IDWT(...,'mode',MODE) computes the wavelet
%   reconstruction using the specified extension mode MODE.
%
%   X = IDWT(CA,[], ... ) returns the single-level
%   reconstructed approximation coefficients vector X
%   based on approximation coefficients vector CA.
%   
%   X = IDWT([],CD, ... ) returns the single-level
%   reconstructed detail coefficients vector X
%   based on detail coefficients vector CD.
% 
%   See also DWT, DWTMODE, UPWLEV.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Last Revision: 06-Feb-2011.
%   Copyright 1995-2015 The MathWorks, Inc.

% Check arguments.
narginchk(3,9)

if isempty(d)
    validateattributes(a,{'numeric'},{'vector','finite','real'},'idwt','CA');
elseif isempty(a)
    validateattributes(d,{'numeric'},{'vector','finite','real'},'idwt','CD');
else
    validateattributes(a,{'numeric'},{'vector','finite','real'},'idwt','CA');
    validateattributes(d,{'numeric'},{'vector','finite','real'},'idwt','CD');
end

if ischar(varargin{1})
    [Lo_R,Hi_R] = wfilters(varargin{1},'r');
    next = 2;
else
    if nargin < 4
        error(message('Wavelet:FunctionInput:InvalidLoHiFilters'));
    end
    Lo_R = varargin{1};
    Hi_R = varargin{2};
    next = 3;

    validateattributes(Lo_R,{'numeric'},...
        {'vector','finite','real'},'idwt','Lo_R');
    validateattributes(Hi_R,{'numeric'},...
        {'vector','finite','real'},'idwt','Hi_R');

    if (length(Lo_R) < 2) || (length(Hi_R) < 2) || ...
            mod(length(Lo_R),2) || mod(length(Hi_R),2)
        error(message('Wavelet:FunctionInput:Invalid_Filt_Length'));
    end
end

% Check arguments for Length, Extension and Shift.
DWT_Attribute = getappdata(0,'DWT_Attribute');
if isempty(DWT_Attribute) , DWT_Attribute = dwtmode('get'); end
dwtEXTM = DWT_Attribute.extMode; % Default: Extension.
shift   = DWT_Attribute.shift1D; % Default: Shift.
lx = [];
k = next;
while k<=length(varargin)
    if ischar(varargin{k})
        switch varargin{k}
           case 'mode'  , dwtEXTM = varargin{k+1};
           case 'shift' , shift = mod(varargin{k+1},2);
        end
        k = k+2;
    else
        lx = varargin{k};
        k = k+1;
    end
end

% Reconstructed Approximation and Detail.
x = upsconv1(a,Lo_R,lx,dwtEXTM,shift) + upsconv1(d,Hi_R,lx,dwtEXTM,shift);
