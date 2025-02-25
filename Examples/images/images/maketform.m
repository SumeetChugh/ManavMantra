function t = maketform( varargin )
% MAKETFORM Create spatial transformation structure (TFORM).  
%   MAKETFORM is not recommended. Use AFFINE2D, PROJECTIVE2D, AFFINE3D, or
%   FITGEOTRANS instead.
%
%   T = MAKETFORM(TRANSFORMTYPE,...) creates a multidimensional spatial
%   transformation structure (a 'TFORM struct') that can be used with
%   TFORMFWD, TFORMINV, FLIPTFORM, IMTRANSFORM, or TFORMARRAY.
%   TRANSFORMTYPE can be 'affine', 'projective', 'custom', 'box', or
%   'composite'. Spatial transformations are also called geometric
%   transformations.
%
%   T = MAKETFORM('affine',A) builds a TFORM struct for an N-dimensional
%   affine transformation.  A is a nonsingular real (N+1)-by-(N+1) or
%   (N+1)-by-N matrix.  If A is (N+1)-by-(N+1), then the last column
%   of A must be [zeros(N,1); 1].  Otherwise, A is augmented automatically
%   such that its last column is [zeros(N,1); 1].  A defines a forward
%   transformation such that TFORMFWD(U,T), where U is a 1-by-N vector,
%   returns a 1-by-N vector X such that X = U * A(1:N,1:N) + A(N+1,1:N).
%   T has both forward and inverse transformations.
%
%   T = MAKETFORM('projective',A) builds a TFORM struct for an N-dimensional
%   projective transformation.  A is a nonsingular real (N+1)-by-(N+1)
%   matrix.  A(N+1,N+1) cannot be 0.  A defines a forward transformation
%   such that TFORMFWD(U,T), where U is a 1-by-N vector, returns a 1-by-N
%   vector X such that X = W(1:N)/W(N+1), where W = [U 1] * A.  T has
%   both forward and inverse transformations.
%   
%   T = MAKETFORM('affine',U,X) builds a TFORM struct for a
%   two-dimensional affine transformation that maps each row of U
%   to the corresponding row of X.  U and X are each 3-by-2 and
%   define the corners of input and output triangles.  The corners
%   may not be collinear.
%
%   T = MAKETFORM('projective',U,X) builds a TFORM struct for a
%   two-dimensional projective transformation that maps each row of U
%   to the corresponding row of X.  U and X are each 4-by-2 and
%   define the corners of input and output quadrilaterals.  No three
%   corners may be collinear.
%
%   T = MAKETFORM('custom',NDIMS_IN,NDIMS_OUT,FORWARD_FCN,INVERSE_FCN,
%   TDATA) builds a custom TFORM struct based on user-provided function
%   handles and parameters.  NDIMS_IN and NDIMS_OUT are the numbers of
%   input and output dimensions.  FORWARD_FCN and INVERSE_FCN are
%   function handles to forward and inverse functions.  Those functions
%   must support the syntaxes X = FORWARD_FCN(U,T) and U =
%   INVERSE_FCN(X,T), where U is a P-by-NDIMS_IN matrix whose rows are
%   points in the transformation's input space, and X is a
%   P-by-NDIMS_OUT matrix whose rows are points in the transformation's
%   output space.  TDATA can be any MATLAB array and is typically used to
%   store parameters of the custom transformation.  It is accessible to
%   FORWARD_FCN and INVERSE_FNC via the "tdata" field of T.  Either
%   FORWARD_FCN or INVERSE_FCN can be empty, although at least
%   INVERSE_FCN must be defined to use T with TFORMARRAY or IMTRANSFORM.
%
%   T = MAKETFORM('composite',T1,T2,...,TL) or T = MAKETFORM('composite',
%   [T1 T2 ... TL]) builds a TFORM whose forward and inverse functions are
%   the functional compositions of the forward and inverse functions of the
%   T1, T2, ..., TL.  Note that the inputs T1, T2, ..., TL are ordered just
%   as they would be when using the standard notation for function
%   composition: 
%
%      T = T1 o T2 o ... o TL 
%
%   and note also that composition is associative, but not commutative.
%   This means that in order to apply T to the input U, one must apply TL
%   first and T1 last. Thus if L = 3, for example, then TFORMFWD(U,T) is
%   the same as TFORMFWD(TFORMFWD(TFORMFWD(U,T3),T2),T1). The components
%   T1 through TL must be compatible in terms of the numbers of input and
%   output dimensions.  T has a defined forward transform function only if
%   all of the component transforms have defined forward transform
%   functions.  T has a defined inverse transform function only if all of
%   the component functions have defined inverse transform functions.
%
%   T = MAKETFORM('box',TSIZE,LOW,HIGH) or T = MAKETFORM('box',INBOUNDS,
%   OUTBOUNDS) builds an N-dimensional affine TFORM struct, T.  TSIZE is
%   an N-element vector of positive integers, and LOW and HIGH are also
%   N-element vectors.  The transformation maps an input "box" defined
%   by the opposite corners ONES(1,N) and TSIZE or, alternatively, by
%   corners INBOUNDS(1,:) and INBOUND(2,:) to an output box defined by
%   the opposite corners LOW and HIGH or OUTBOUNDS(1,:) and OUTBOUNDS(2,:).
%   LOW(K) and HIGH(K) must be different unless TSIZE(K) is 1, in which
%   case the affine scale factor along the K-th dimension is assumed to be
%   1.0.  Similarly, INBOUNDS(1,K) and INBOUNDS(2,K) must be different
%   unless OUTBOUNDS(1,K) and OUTBOUNDS(1,K) are the same, and vice versa.
%   The 'box' TFORM is typically used to register the row and column
%   subscripts of an image or array to some "world" coordinate system.
%
%   Example
%   -------
%   Make and apply an affine transformation.
%
%       T = maketform('affine',[.5 0 0; .5 2 0; 0 0 1]);
%       tformfwd([10 20],T);
%       I = imread('cameraman.tif');
%       transformedI = imtransform(I,T);
%       figure, imshow(I), figure, imshow(transformedI)
%
%   See also AFFINE2D, AFFINE3D, FITGEOTRANS, FLIPTFORM, PROJECTIVE2D,
%            IMTRANSFORM, TFORMARRAY, TFORMFWD, TFORMINV.

%   Copyright 1993-2017 The MathWorks, Inc.

% Testing notes
% Syntaxes
%---------
% T = MAKETFORM( 'affine', A )
%
% A:        Numeric, non-singular, real square matrix (no Infs or Nans).
%           Last column must be zero except for a one in the lower right corner.

narginchk(1, Inf);

args = matlab.images.internal.stringToChar(varargin);

transform_type = getTransformType(args{1});

switch transform_type
    case 'affine'
        fcn = @affine;
    case 'projective'
        fcn = @projective;
    case 'composite'
        fcn = @composite;
    case 'custom'
        fcn = @custom;
    case 'box'
        fcn = @box;
    otherwise
        error(message('images:maketform:unknownTransformType', args{ 1 }))
end

t = feval(fcn,args{2:end});

%--------------------------------------------------------------------------

function t = assigntform(ndims_in, ndims_out, forward_fcn, inverse_fcn, tdata)

% Use this function to ensure consistency in the way we assign
% the fields of each TFORM struct.

t.ndims_in    = ndims_in;
t.ndims_out   = ndims_out;
t.forward_fcn = forward_fcn;
t.inverse_fcn = inverse_fcn;
t.tdata       = tdata;

%--------------------------------------------------------------------------

function t = affine( varargin )

% Build an affine TFORM struct.

narginchk(1,2);


if nargin == 2
    % Construct a 3-by-3 2-D affine transformation matrix A
    % that maps the three points in X to the three points in U.
    U = varargin{1};
    X = varargin{2};
    A = construct_matrix( U, X, 'affine' ); 
    A(:,3) = [0 0 1]';  % Clean up noise before validating A.
else
    A = varargin{1};
end
A = validate_matrix( A, 'affine' );

N = size(A,2) - 1;
tdata.T    = A;
tdata.Tinv = inv(A);

% In case of numerical noise, coerce the inverse into the proper form.
tdata.Tinv(1:end-1,end) = 0;
tdata.Tinv(end,end) = 1;

t = assigntform(N, N, @fwd_affine, @inv_affine, tdata);

%--------------------------------------------------------------------------

function U = inv_affine( X, t )

% INVERSE affine transformation 
%
% T is an affine transformation structure. X is the row vector to
% be transformed, or a matrix with a vector in each row.

U = trans_affine(X, t, 'inverse');

%--------------------------------------------------------------------------

function X = fwd_affine( U, t)

% FORWARD affine transformation 
%
% T is an affine transformation structure. U is the row vector to
% be transformed, or a matrix with a vector in each row.

X = trans_affine(U, t, 'forward');

%--------------------------------------------------------------------------

function U = trans_affine( X, t, direction )

% Forward/inverse affine transformation method
%
% T is an affine transformation structure. X is the row vector to
% be transformed, or a matrix with a vector in each row.
% DIRECTION is either 'forward' or 'inverse'.

if strcmp(direction,'forward')
    M = t.tdata.T;
elseif strcmp(direction,'inverse')
    M = t.tdata.Tinv;
else
    error(message('images:maketform:invalidDirection'))
end

X1 = [X ones(size(X,1),1)];   % Convert X to homogeneous coordinates
U1 = X1 * M;                  % Transform in homogeneous coordinates
U  = U1(:,1:end-1);           % Convert homogeneous coordinates to U

%--------------------------------------------------------------------------

function t = projective( varargin )

% Build a projective TFORM struct.

narginchk(1,2);

if nargin == 2
    % Construct a 3-by-3 2-D projective transformation matrix A
    % that maps the four points in U to the four points in X.
    U = varargin{1};
    X = varargin{2};
    A = construct_matrix( U, X, 'projective' ); 
else
    A = varargin{1};
end
A = validate_matrix( A, 'projective' );

N = size(A,2) - 1;
tdata.T    = A;
tdata.Tinv = inv(A);

t = assigntform(N, N, @fwd_projective, @inv_projective, tdata);

%--------------------------------------------------------------------------

function U = inv_projective( X, t )

% INVERSE projective transformation 
%
% T is an projective transformation structure. X is the row vector to
% be transformed, or a matrix with a vector in each row.

U = trans_projective(X, t, 'inverse');

%--------------------------------------------------------------------------

function X = fwd_projective( U, t)

% FORWARD projective transformation 
%
% T is an projective transformation structure. U is the row vector to
% be transformed, or a matrix with a vector in each row.

X = trans_projective(U, t, 'forward');

%--------------------------------------------------------------------------

function U = trans_projective( X, t, direction )

% Forward/inverse projective transformation method
%
% T is an projective transformation structure. X is the row vector to
% be transformed, or a matrix with a vector in each row.
% DIRECTION is either 'forward' or 'inverse'.

if strcmp(direction,'forward')
    M = t.tdata.T;
elseif strcmp(direction,'inverse')
    M = t.tdata.Tinv;
else
    error(message('images:maketform:invalidDirection'))
end

N  = t.ndims_in;
X1 = [X ones(size(X,1),1)];   % Convert X to homogeneous coordinates
U1 = X1 * M;                  % Transform in homogeneous coordinates
UN = repmat(U1(:,end),[1 N]); % Replicate the last column of U
U  = U1(:,1:end-1) ./ UN;     % Convert homogeneous coordinates to U

%---------------------------------------------------------------

function A = validate_matrix( A, transform_type )

% Make sure A is double and real-valued.
if ~isa(A,'double') || ~isreal(A)
    error(message('images:maketform:invalidAValue'))
end

% Make sure A is finite.
if ~all(isfinite(A))
    error(message('images:maketform:aContainsInfs'))
end

% Make sure A is (N + 1)-by-(N + 1).  Append a column if needed for 'affine'.
N = size(A,1) - 1;
if strcmp(transform_type,'affine') && size(A,2) == N
    A(:,N+1) = [zeros(N,1); 1];
end
if N < 1 || size(A,2) ~= N + 1
    error(message('images:maketform:invalidASize'))
end

switch transform_type
    case 'affine'
      % Validate the final column of A.
      if any(A(:,N+1) ~= [zeros(N,1); 1])
           error(message('images:maketform:invalidAForAffine'))
      end

    case 'projective'
      % Validate lower right corner of A
      if abs(A(N+1,N+1)) <= 100 * eps * norm(A)
            warning(message('images:maketform:lastElementInANearZero'))
      end
end

if cond(A) > condlimit
    warning(message('images:maketform:conditionNumberofAIsHigh', num2str( cond( A ) )))
end

%---------------------------------------------------------------

function A = construct_matrix( U, X, transform_type )

% Construct a 3-by-3 2-D transformation matrix A
% that maps the points in U to the points in X.

switch transform_type
  case 'affine'
    nPoints = 3;
    unitFcn = @UnitToTriangle;
  case 'projective'
    nPoints = 4;
    unitFcn = @UnitToQuadrilateral;
end

if any(size(U) ~= [nPoints 2])
    error(message('images:maketform:invalidUSize', nPoints))
end

if any(size(X) ~= [nPoints 2])
    error(message('images:maketform:invalidXSize', nPoints))
end

if ~isa(U,'double') || ~isreal(U) || ~all(isfinite(U(:)))
    error(message('images:maketform:invalidUValue'))
end

if ~isa(X,'double') || ~isreal(X) || ~all(isfinite(X(:)))
    error(message('images:maketform:invalidXValue'))
end

Au = feval(unitFcn,U);
if cond(Au) > condlimit
    warning(message('images:maketform:conditionNumberOfUIsHigh'))
end

Ax = feval(unitFcn,X);
if cond(Ax) > condlimit
    warning(message('images:maketform:conditionNumberOfXIsHigh'))
end

% (unit shape) * Au = U
% (unit shape) * Ax = X
%
% U * inv(Au) * Ax = (unit shape) * Ax = X and U * A = X,
% so inv(Au) * Ax = A, or Au * A = Ax, or A = Au \ Ax.

A = Au \ Ax;

if any(~isfinite(A(:)))
    error(message('images:maketform:collinearPointsinUOrX'))
end

A = A / A(end,end);

%---------------------------------------------------------------

function A = UnitToTriangle( X )

% Computes the 3-by-3 two-dimensional affine transformation
% matrix A that maps the unit triangle ([0 0], [1 0], [0 1])
% to a triangle with corners (X(1,:), X(2,:), X(3,:)).
% X must be 3-by-2, real-valued, and contain three distinct
% and non-collinear points. A is a 3-by-3, real-valued matrix.

A = [ X(2,1) - X(1,1)   X(2,2) - X(1,2)    0; ...
      X(3,1) - X(1,1)   X(3,2) - X(1,2)    0; ...
           X(1,1)            X(1,2)        1  ];

%---------------------------------------------------------------

function A = UnitToQuadrilateral( X )

% Computes the 3-by-3 two-dimensional projective transformation
% matrix A that maps the unit square ([0 0], [1 0], [1 1], [0 1])
% to a quadrilateral corners (X(1,:), X(2,:), X(3,:), X(4,:)).
% X must be 4-by-2, real-valued, and contain four distinct
% and non-collinear points.  A is a 3-by-3, real-valued matrix.
% If the four points happen to form a parallelogram, then
% A(1,3) = A(2,3) = 0 and the mapping is affine.
%
% The formulas below are derived in
%   Wolberg, George. "Digital Image Warping," IEEE Computer
%   Society Press, Los Alamitos, CA, 1990, pp. 54-56,
% and are based on the derivation in
%   Heckbert, Paul S., "Fundamentals of Texture Mapping and
%   Image Warping," Master's Thesis, Department of Electrical
%   Engineering and Computer Science, University of California,
%   Berkeley, June 17, 1989, pp. 19-21.

x = X(:,1);
y = X(:,2);

dx1 = x(2) - x(3);
dx2 = x(4) - x(3);
dx3 = x(1) - x(2) + x(3) - x(4);

dy1 = y(2) - y(3);
dy2 = y(4) - y(3);
dy3 = y(1) - y(2) + y(3) - y(4);

if dx3 == 0 && dy3 == 0
    % Parallelogram: Affine map
    A = [ x(2) - x(1)    y(2) - y(1)   0 ; ...
          x(3) - x(2)    y(3) - y(2)   0 ; ...
          x(1)           y(1)          1 ];
else
    % General quadrilateral: Projective map
    a13 = (dx3 * dy2 - dx2 * dy3) / (dx1 * dy2 - dx2 * dy1);
    a23 = (dx1 * dy3 - dx3 * dy1) / (dx1 * dy2 - dx2 * dy1);
    
    A = [x(2) - x(1) + a13 * x(2)   y(2) - y(1) + a13 * y(2)   a13 ;...
         x(4) - x(1) + a23 * x(4)   y(4) - y(1) + a23 * y(4)   a23 ;...
         x(1)                       y(1)                       1   ];
end

%---------------------------------------------------------------

function t = composite( varargin )

% Construct COMPOSITE transformation structure.

% Create TDATA as a TFORM structure array.
if nargin == 0
    error(message('images:maketform:tooFewTformStructs'))
elseif nargin == 1
    if length(varargin{1}) == 1
        % One TFORM input, just copy to t
        t = varargin{1};
        if ~istform(t)
            error(message('images:maketform:invalidTformStruct'))
        end
        return;
    else
        % An array of TFORMs
        tdata = varargin{1};
        if ~istform(tdata)
            error(message('images:maketform:invalidTformStructArray'))
        end
    end
else
    % A list of TFORMs
    for k = 1:nargin
        if ~istform(varargin{k}) || length(varargin{k}) ~= 1
            error(message('images:maketform:invalidTformsInArray'))
        end
    end
    tdata = [varargin{:}];
end

% Check for consistency of dimensions
N = length(tdata);
ndims_in =  [tdata.ndims_in];
ndims_out = [tdata.ndims_out];
if any(ndims_in(1:N-1) ~= ndims_out(2:N))
    error(message('images:maketform:tFormsDoNotHaveSameDimension'))
end

% Check existence of forward and inverse function handles 
if any(cellfun('isempty',{tdata.forward_fcn}))
    forward_fcn = [];
else
    forward_fcn = @fwd_composite;
end

if any(cellfun('isempty',{tdata.inverse_fcn}))
    inverse_fcn = [];
else
    inverse_fcn = @inv_composite;
end

if (isempty(forward_fcn) && isempty(inverse_fcn))
    error(message('images:maketform:invalidForwardOrInverseFunction'))
end

t = assigntform(tdata(N).ndims_in, tdata(1).ndims_out, ...
                forward_fcn, inverse_fcn, tdata);

%---------------------------------------------------------------

function X = fwd_composite( U, t )

% FORWARD composite transformation 
%
% U is the row vector to be transformed, or
% a matrix with a vector in each row.

N = length(t.tdata);
X = U;
for i = N:-1:1
    X = feval(t.tdata(i).forward_fcn, X, t.tdata(i));
end

%---------------------------------------------------------------

function U = inv_composite( X, t )

% INVERSE composite transformation 
%
% X is the row vector to be transformed, or
% a matrix with a vector in each row.

N = length(t.tdata);
U = X;
for i = 1:N
    U = feval(t.tdata(i).inverse_fcn, U, t.tdata(i));
end

%--------------------------------------------------------------------------

function t = custom( varargin )

narginchk(5,5);


ndims_in    = varargin{1};
ndims_out   = varargin{2};
forward_fcn = varargin{3};
inverse_fcn = varargin{4};
tdata       = varargin{5};

% Validate sizes and types
if length(ndims_in) ~= 1 || ~isdoubleinteger(ndims_in)
    
    error(message('images:maketform:invalidNDims_In'))
end

if length(ndims_out) ~= 1 || ~isdoubleinteger(ndims_out)
  
    error(message('images:maketform:invalidNDims_Out'))
end

if ndims_in < 1
  
    error(message('images:maketform:nDimsInIsNotPositive'))
end

if ndims_out < 1
   
    error(message('images:maketform:nDimsOutIsNotPositive'))
end

if ~isempty(forward_fcn)
    if length(forward_fcn) ~= 1 || ~isa(forward_fcn,'function_handle')
      
        error(message('images:maketform:invalidForwardFcn'))
    end
end

if ~isempty(inverse_fcn)
    if length(inverse_fcn) ~= 1 || ~isa(inverse_fcn,'function_handle')
      
        error(message('images:maketform:invalidInverseFcn'))
    end
end

if isempty(forward_fcn) && isempty(inverse_fcn)
  
    error(message('images:maketform:emptyForwardAndInverseFcn'))
end

t = assigntform(ndims_in, ndims_out, forward_fcn, inverse_fcn, tdata);

%--------------------------------------------------------------------------

function t = box( varargin )

narginchk(2,3);

if nargin == 3
    % Construct an affine TFORM struct that maps a box bounded by 1 and TSIZE(k)
    % in dimension k to a box bounded by LO(k) and HI(k) in dimension k.
    % Construct INBOUNDS and OUTBOUNDS arrays, then call BOX2.
    
    tsize = varargin{1};
    lo    = varargin{2};
    hi    = varargin{3};
    
    tsize = tsize(:);
    lo = lo(:);
    hi = hi(:);
    
    if ~isdoubleinteger(tsize)
      
        error(message('images:maketform:invalidTSize'))
    end
    
    if any(tsize < 1 )
      
        error(message('images:maketform:tSizeIsNotPositive'))
    end
    
    if ~isa(lo,'double') || ~isreal(lo) || ~all(isfinite(lo))
      
        error(message('images:maketform:invalidLo'))
    end
    
    if ~isa(hi,'double') || ~isreal(hi) || ~all(isfinite(hi))
      
        error(message('images:maketform:invalidHi'))
    end
    
    N = length(tsize);
    if length(lo) ~= N || length(hi) ~= N
      
        error(message('images:maketform:unequalLengthsForLoHiAndTSize'))
    end

    if any(lo == hi & ~(tsize == 1))  
        error(message('images:maketform:invalidLoAndHi'))
    end
    
    inbounds  = [ones(1,N); tsize'];
    outbounds = [lo'; hi'];
else
    inbounds  = varargin{1};
    outbounds = varargin{2};
end

t = box2(inbounds,outbounds);

%--------------------------------------------------------------------------

function t = box2( inBounds, outBounds )

% Construct an affine TFORM struct that maps a box bounded by INBOUNDS(1,k)
% and INBOUNDS(2,k) in dimensions k to a box bounded by OUTBOUNDS(1,k) and
% OUTBOUNDS(2,k).
%
% inBounds:   2-by-N
% outBounds:  2-by-N

if ~isfinitedouble(inBounds)
    error(message('images:maketform:invalidInbounds'))
end

if ~isfinitedouble(outBounds)
    error(message('images:maketform:invalidOutbounds'))
end

N = size(inBounds,2);
if (ndims(inBounds) ~= 2  ...
    || ndims(outBounds)  ~= 2 ...
    || size(inBounds,1)  ~= 2 ...
    || size(outBounds,1) ~= 2 ...
    || size(outBounds,2) ~= N)
  
    error(message('images:maketform:inboundsAndOutbounds2ByN'))

end

qDegenerate  = (inBounds(1,:) == inBounds(2,:));
if any((outBounds(1,:) == outBounds(2,:)) ~= qDegenerate)

    error(message('images:maketform:invalidInboundsAndOutbounds'))

end

num = outBounds(2,:) - outBounds(1,:);
den =  inBounds(2,:)  - inBounds(1,:);

% Arbitrarily set the scale to unity for degenerate dimensions.
num(qDegenerate) = 1;
den(qDegenerate) = 1;

tdata.scale = num ./ den;
tdata.shift = outBounds(1,:) - tdata.scale .* inBounds(1,:);

t = assigntform(N, N, @fwd_box, @inv_box, tdata);

%--------------------------------------------------------------------------

function U = inv_box( X, t )

% INVERSE box transformation 
%
% T is an box transformation structure. X is the row vector to
% be transformed, or a matrix with a vector in each row.

U = bsxfun(@minus, X, t.tdata.shift);
U = bsxfun(@rdivide, U, t.tdata.scale);

%--------------------------------------------------------------------------

function X = fwd_box( U, t)

% FORWARD box transformation 
%
% T is an box transformation structure. U is the row vector to
% be transformed, or a matrix with a vector in each row.

X = bsxfun(@times, U, t.tdata.scale);
X = bsxfun(@plus, X, t.tdata.shift);


%--------------------------------------------------------------------------

function transform_type = getTransformType(type)

if ischar(type)
    low_type = lower(type);
else
  
    error(message('images:maketform:invalidTransformType'))
end
    
transform_names = {'affine','projective','composite','custom','box'};

% try to recognize the TransformType
imatch = strmatch(low_type,transform_names);

switch length(imatch)
  case 1    % one match
    transform_type = transform_names{imatch};
  case 0    % no matches
    error(message('images:maketform:unknownTransformType', type))
  otherwise % more than one match
    error(message('images:maketform:ambiguousTransformType', type))
end

%--------------------------------------------------------------------------

function q = isfinitedouble( x )

% Return true iff x is a finite, real-valued double array.

q = isa(x,'double');
if q
    q = isreal(x) && all(isfinite(x(:)));
end

%--------------------------------------------------------------------------

function q = isdoubleinteger( x )

% Return true iff x is a double array containing 
% (real-valued and finite) integers.

if isa(x,'double')
    qint = (x == floor(x));
    q = ~(~isreal(x) || ~all(qint(:)) || ~all(isfinite(x(:))));
else
    q = ~1;
end
   
%--------------------------------------------------------------------------

function limit = condlimit

limit = 1e9;
