function [msg,x,y,xx,yy,linetype,plottype,barwidth,arg8] = makebars(varargin)
% This undocumented function may be removed in a future release.

%MAKEBARS Make data for bar charts.
%   [MSG,X,Y,XX,YY,LINETYPE,PLOTTYPE,BARWIDTH,EQUAL] = MAKEBARS(X,Y)
%   returns X and Y, the original data values, XX and YY, the data
%   values formatted to be plotted by one of the BARxx functions (BAR,
%   BARH, BAR3, BAR3H).
%
%   LINETYPE returns the color desired for the plot.
%   PLOTTYPE determines whether the plot will be grouped (PLOTTYPE=0),
%   stacked (PLOTTYPE=1), or detached (PLOTTYPE=2--only for 3-D plots).
%   BARWIDTH has the bar width (normalized to one).
%
%   [MSG,X,Y,XX,YY,LINETYPE,PLOTTYPE,BARWIDTH,ZZ] = MAKEBARS(X,Y)
%   does the same as above, except for the final parameter.
%   ZZ is the z-axis data for 3-D plots; used in BAR3 and BAR3H.
%
%   [...] = MAKEBARS(X,Y,WIDTH) or MAKEBARS(Y,WIDTH) returns the
%   specified width given in WIDTH.  The default is 0.8.
%   [...] = MAKEBARS(...,'grouped') returns the data in the form
%   so that the information will be plotted in groups.
%   [...] = MAKEBARS(...,'detached') {3-D only} returns the data
%   such that the information will be plotted detached.
%   [...] = MAKEBARS(...,'stacked') returns the data such that the
%   information will be plotted in stacked form.
%   [...] = MAKEBARS(...,'hist') creates centered bars that touch.
%   [...] = MAKEBARS(...,'histc') creates bars that touch edges.
%   EQUAL is true if spacing of the data is equal; false otherwise.
%   EQUAL is always true except for 'hist' and 'histc' plottypes.
%
%   See also HIST, PLOT, BAR, BARH, BAR3, BAR3H.

%   [...] = MAKEBARS(X,Y,[MIN MAX],'hist') creates bars where the
%   first bar includes MIN and the last includes MAX.

%   Copyright 1984-2017 The MathWorks, Inc.

% Initialize everything
x = []; y=[]; xx=[]; yy=[]; linetype=[]; plottype=[]; barwidth=[];
arg8 = [];
msg = [];

try
    narginchk(1,7);
catch e
    msg = struct('message',e.message,'identifier',e.identifier);
    return
end

barwidth = .8; % Normalized width of bar.
groupwidth = .8; % Normalized width of groups.
linetype = []; % Assume linetype is not specified
ishist = 0; % Assume this isn't a histogram
extremes = [];

nin = nargin;

varargin = matlab.graphics.internal.convertStringToCharArgs(varargin);

if nin>1 && all(strcmp(varargin{nin-1},'BaseValue'))
    basevalue = varargin{nin};
    nin = nin - 2;
else
    basevalue = 0;
end

if strcmp(varargin{nin},'3')
    threeD = 1;
    nin = nin-1;
    plottype = 2; % Detached plot default
else
    threeD = 0;
    plottype = 0; % Grouped plot default
end

if matlab.graphics.internal.isCharOrString(varargin{nin})  % Try to parse this string as a color
    [ls,co,mark,msg] = colstyle(varargin{nin});
    if ~isempty(ls) || ~isempty(mark) || ~isempty(msg)
        msg = struct('message',getString(message('MATLAB:bar:UnrecognizedOption',varargin{nin})),...
                     'identifier','MATLAB:bar:UnrecognizedOption');
    end
    if ~isempty(co)
        linetype = co;
        nin = nin - 1;
    end
end

if ischar(varargin{nin}) || ((isstring(varargin{nin}) || iscellstr(varargin{nin})) && isscalar(varargin{nin}))  % Process 'grouped','stacked' or
    varargin{nin} = char(varargin{nin});
    % 'detached' string.
    kind = [lower(varargin{nin}) 'g'];
    if kind(1)=='g'  % grouped
        plottype = 0;
    elseif kind(1)=='s'  % stacked
        plottype = 1;
    elseif threeD && kind(1)=='d'  % detached
        plottype = 2;
    elseif kind(1)=='h'  % histogram
        if strcmpi(varargin{nin},'histc')
            ishist = -1; barwidth = 1;
        else
            ishist = 1; barwidth = 1;
            if nin == 4 && isnumeric(varargin{3}) && ...
                    length(varargin{3}) == 2
                extremes = varargin{3};
                nin = nin-1;
            end
        end
    else
        msg.message = getString(message('MATLAB:bar:UnrecognizedOption', ...
            varargin{nin}));
        msg.identifier = 'MATLAB:bar:UnrecognizedOption';
        return
    end
    nin = nin-1;
elseif (isstring(varargin{nin}) && ~isscalar(varargin{nin})) || ...
        (iscell(varargin{nin}))
    msg = struct('message',getString(message('MATLAB:bar:InvalidStringOption')),...
             'identifier','MATLAB:bar:InvalidStringOption');
    return
end

% Parse input arguments.
if ((nin>1) && isscalar(varargin{nin}) && ~isscalar(varargin{nin-1})) || ...
        ((nin>2) && isscalar(varargin{nin}))
    % If last argument is a scalar and next to last isn't then last
    % argument must be the barwidth. Also if the third arg is a
    % scalar then that is the barwidth
    barwidth = varargin{nin};
    nin=nin-1;
end
varargin = getRealData(varargin(1:nin)); 
[msg,x,y] = xychk(varargin{1:nin});

if ~isempty(msg) 
    return
end

% Make sure x is monotonic
[x,ndx] = sort(x);
if min(size(y))==1
    y = y(ndx); 
else 
    y = y(ndx,:); 
end


% Expand x to be the same size as y.
if min(size(y))>1
    x = x(:,ones(size(y,2),1)); 
end

% Make sure vector arguments are columns
if min(size(y))==1
    x = x(:); y = y(:); 
end

[n,m] = size(y);

% Convert y values to basevalue where y is non-finite;
k = find(~isfinite(y));
if ~isempty(k)
    y(k) = basevalue; 
end

if threeD
    z = y; % Make variables consistent with 3-D bar graph
    y = x;

    if m==1 || plottype~=0
        groupwidth = 1;
    else
        groupwidth = min(groupwidth,m/(m+1.5));
    end

    nn = 6*n; mm = 4*m;
    zz = zeros(nn,mm);
    yy = zz;
    xx = zeros(nn,4);

    % Define xx
    xx(:,3:4) = 1;
    if plottype==0
        xx = (xx-0.5)*barwidth*groupwidth/m;
    else
        xx = (xx-0.5)*barwidth*groupwidth;
    end

    % Define heights
    zz(2:6:nn,2:4:mm) = z;
    zz(2:6:nn,3:4:mm) = z;
    zz(3:6:nn,2:4:mm) = z;
    zz(3:6:nn,3:4:mm) = z;

    if plottype==1 && m>1  % Stacked
        z = cumsum(z.').';
        zz = zz + [zeros(nn,4) z(ones(6,1)*(1:n),ones(4,1)*(1:m-1))];
    end

    if length(y)==1 || all(max(diff(y))==0)
        equal = []; % Special case
    else
        equal = max(abs(diff(diff(y)))) <= max(max(abs(y)))*sqrt(eps(class(y)));
        if isempty(equal), equal = 0; end % check for double-diff in above line
    end

    %
    % Determine beginning of bars (t) and bar spacing (delta)
    %
    if isempty(equal)  % Scalar case and special case
        delta = ones(size(y));
        t = y - 0.5*delta;
        x = 1;
    elseif equal
        if plottype~=0  % Stacked or detached
            delta = ones(n,1) * (max(y) - min(y)) * groupwidth / (n-1);
            t = y - 0.5*delta;
        else % grouped
            delta = ones(n,1) * (max(y) - min(y)) * groupwidth / (n-1) / m ;
            t = y - 0.5*delta*m + (ones(n,1)*(0:m-1)).*delta;
        end
        if plottype==2
            x = 1:m; 
        else 
            x = ones(1,m); 
        end
    else % Spacing is unequal.
        if ishist==1 % Width of bin is average of difference between points.
            dy = diff(y); dy = (dy([1 1:end],:)+dy([1:end end],:))/2;
            t = [(y(1:end-1,:)+y(2:end,:))/2;y(end,:)+(y(end,:)-y(end-1,:))/2]-dy/2;
        elseif ishist==-1 % Width of bin is difference between edges
            dy = [diff(y,1);zeros(1,size(y,2))];
            t = y + dy*groupwidth/2;
        else % Width of bin is minimum of difference between points.
            dy = ones(n,1)*min(diff(y));
            t = y;
        end
        if plottype~=0  % Stacked or detached
            delta = dy * groupwidth;
            t = t - delta/2;
        else % Grouped
            delta = dy * groupwidth / m ;
            t = t - delta/2*m + (ones(n,1)*(0:m-1)).*delta;
        end
        if plottype==2
            x = 1:m; 
        else 
            x = ones(1,m); 
        end
    end
    t = t(:,ones(4,1)*(1:m));
    delta = delta(:,ones(4,1)*(1:m));
    yy(1:6:nn,:) = t + (1-barwidth)/2.*delta;
    yy(2:6:nn,:) = t + (1-barwidth)/2.*delta;
    yy(3:6:nn,:) = t + (1+barwidth)/2.*delta;
    yy(4:6:nn,:) = t + (1+barwidth)/2.*delta;
    yy(5:6:nn,:) = t + (1-barwidth)/2.*delta;

    % Insert NaN's so distinct bars are drawn
    ii1 = [(1:6:nn) (4:6:nn) (5:6:nn) (6:6:nn)];
    ii2 = 6:6:nn;
    xx(ii1,[1 4]) = nan;
    xx(ii2,[2 3]) = nan;
    yy(ii1,[(1:4:mm) (4:4:mm)]) = nan;
    yy(ii2,[(2:4:mm) (3:4:mm)]) = nan;
    zz(ii1,[(1:4:mm) (4:4:mm)]) = nan;
    zz(ii2,[(2:4:mm) (3:4:mm)]) = nan;
    arg8 = zz;
else

    nn = 5*n;
    yy = basevalue*ones(nn+1,m);
    xx = yy;
    equal = 0;
    if nn > 0
        if plottype && (m>1)
            yc = cumsum(y,2);
            
            % If the offset is 0, the baseline should be used instead.
            % This is generally true of the bottom bar in the stack
            bottom = yc(:,1:end-1);
            bottom(bottom == 0) = basevalue;
            ys = [basevalue*ones(n,1),bottom];

            yy(2:5:nn,:) = ys;
            yy(3:5:nn,:) = yc;
            yy(4:5:nn,:) = yc;
            yy(5:5:nn,:) = ys;
        else
            yy(3:5:nn,:) = y;
            yy(4:5:nn,:) = y;
        end

        if m==1 || plottype
            groupwidth = 1;
        else
            groupwidth = min(groupwidth,m/(m+1.5));
        end

        equal = max(abs(diff(diff(x)))) <= max(max(abs(x)))*sqrt(eps(class(x)));
        if ishist==0
            if isempty(equal)
                equal = 0; 
            end
            if length(x)==1 || all(max(diff(x))==0)
                equal = []; 
            end
        else
            if isempty(equal)
                equal = 1;
            end
        end

        %
        % Determine beginning of bars (t) and bar spacing (delta)
        %
        dt = [];
        t = x;
        if isempty(equal)  % Scalar case and special case
            delta = 1;
            if (ishist~=-1)
                dt = 0.5*delta; 
            end
        elseif equal
            if plottype
                delta = ones(n,1) * (max(x) - min(x)) * groupwidth / (n-1);
                if (ishist~=-1)
                    dt = 0.5*delta; 
                end
            else
                delta = ones(n,1) * (max(x) - min(x)) * groupwidth / (n-1) / m ;
                t = x + (ones(n,1)*(0:m-1)).*delta;
                if (ishist~=-1)
                    dt = 0.5*delta*m; 
                end
            end
        else % Spacing is unequal.
            if ishist==1  % Width of bin is average of difference between points.
                dx = diff(x); dx = (dx([1 1:end],:)+dx([1:end end],:))/2;
                t = [(x(1:end-1,:)+x(2:end,:))/2;x(end,:)+(x(end,:)-x(end-1,:))/2]-dx/2;
            elseif ishist==-1  % Width of bin is difference between edges
                dx = diff(x,1); dx = dx([(1:end) end],:);
                %      t = x + dx*groupwidth/2;
            else % Width of bin is minimum of difference between points.
                dx = ones(n,1)*min(diff(x));
            end
            if plottype
                delta = dx * groupwidth;
                if (ishist~=-1)
                    dt = delta/2; 
                end
            else
                delta = dx * groupwidth / m ;
                t = t + (ones(n,1)*(0:m-1)).*delta;
                if (ishist~=-1)
                    dt = delta/2*m; 
                end
            end
        end
        if (~isempty(dt))
            t = t - dt; 
        end

        xx(1:5:nn,:) = t;
        xx(2:5:nn,:) = t + (1-barwidth)/2.*delta;
        xx(3:5:nn,:) = t + (1-barwidth)/2.*delta;
        xx(4:5:nn,:) = t + (1+barwidth)/2.*delta;
        xx(5:5:nn,:) = t + (1+barwidth)/2.*delta;

        % ensure the bars cover the entire hist data range
        if ~isempty(extremes) && size(xx,2) == 1
            xx(2) = min(xx(2), extremes(1));
            xx(3) = min(xx(3), extremes(1));
            xx(nn) = max(xx(nn), extremes(2));
            xx(nn-1) = max(xx(nn-1), extremes(2));
        end
        xx(nn+1,:) = xx(nn,:);
    end


    if (ishist~=1) && (ishist~=-1)
        equal = 1;
    end
    arg8 = equal;
end
