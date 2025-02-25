function [b,map] = cmpermute(a,cm,ndx)
%CMPERMUTE Rearrange colors in colormap.
%   [Y,NEWMAP] = CMPERMUTE(X,MAP) randomly reorders the colors in
%   MAP to produce a new colormap NEWMAP. CMPERMUTE also
%   modifies the values in X to maintain correspondence between
%   the indices and the colormap, and returns the result in
%   Y. The image Y and associated colormap NEWMAP produce the
%   same image as X and MAP.
%
%   [Y,NEWMAP] = CMPERMUTE(X,MAP,INDEX) uses an ordering matrix
%   (such as the second output of SORT) to define the order of
%   colors in the new colormap.
%
%   For example, to order a colormap by luminance, use:
%
%      ntsc = rgb2ntsc(map);
%      [dum,index] = sort(ntsc(:,1));
%      [Y,newmap] = cmpermute(X,map,index);
%
%   Class Support
%   -------------
%   The input image X can be of class uint8 or double. Y is
%   returned as an array of the same class as X.
%
%   Example
%   -------
%   This example orders a colormap by value.
%
%       load clown
%       hsvmap = rgb2hsv(map)
%       [dum,index] = sort(hsvmap(:,3));
%       [Y,newmap] = cmpermute(X,map,index);
%       figure, image(X), colormap(map)
%       figure, image(Y), colormap(newmap)
%
%   See also RANDPERM, SORT.

%   Copyright 1993-2008 The MathWorks, Inc.

%   I/O Spec
%   ========
%   IN
%      X     - image of class uint8 or double
%      MAP   - colormap; an (M-by-3) array of double values 
%      INDEX - an array of integers of class double
%   OUT
%      Y     - the same class as X

narginchk(2,3);
validateattributes(a,{'uint8' 'double'},{'nonsparse' 'real'},mfilename,'X',1);

if isa(a, 'uint8')
    a = double(a)+1;
    u8out = 1;       % Output a uint8 indexed image
else
    u8out = 0;       % Output a double precision indexed image
end

n = size(cm,1);

if nargin==2  % Use random permutation
  ndx = randperm(n);
end

if length(ndx)~=size(cm,1)
  error(message('MATLAB:cmpermute:wrongLength'));
end

pos = zeros(1,n);
pos(ndx) = 1:n;

b = zeros(size(a));
b(:) = pos(a);
map = cm(ndx,:);

if u8out
    b = uint8(b-1);
end

