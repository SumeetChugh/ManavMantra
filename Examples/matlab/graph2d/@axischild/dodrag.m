function aObj = dodrag(aObj, varargin)
%AXISCHILD/DODRAG Do axischild drag
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2015 The MathWorks, Inc. 

savedState.me = aObj;
figH = get(aObj,'Figure');

if nargin==2
   initialPosition = varargin{1};
   set(figH,'CurrentPoint',initialPosition);
end

myHG = get(aObj,'MyHGHandle');
myH = get(aObj,'MyHandle');

axH = get(aObj,'Axis');

prefix = get(aObj,'Prefix');
if ~isempty(prefix)
  if ischar(prefix)
   eval(prefix);
  else
   feval(prefix{1},myH,prefix{2:end});
  end
end

figObjH = getobj(figH);

pointer = get(axH, 'CurrentPoint');
pointX = pointer(1,1);
pointY = pointer(1,2);

savedState.PointX = pointX;
savedState.PointY = pointY;

savedState.SelType = get(figH,'SelectionType');

savedState.Fig = figH;
savedState.Ax = axH;

% call these with my handle, so that they can be overloaded...
X = get(myH, 'XData');
Y = get(myH, 'YData');

savedState.OffsetX = pointX-X(1);
savedState.OffsetY = pointY-Y(1);

aObj = set(aObj,'SavedState',savedState);







