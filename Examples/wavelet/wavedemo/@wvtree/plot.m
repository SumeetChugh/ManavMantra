function varargout = plot(t,varargin)
%PLOT Plot WVTREE object.
%   PLOT(T) plots the WVTREE object T.
%   FIG = PLOT(T) returns the handle of the figure, which
%   contains the tree T.
%   PLOT(T,FIG) plots the tree T in the figure FIG, which
%   already contains a tree.
%
%   PLOT is a graphical tree-management utility. The figure
%   that contains the tree is a GUI tool. It lets you change
%   the Node Label to Depth_Position or Index, and Node Action
%   to Split-Merge or Visualize.
%   The default values are Depth_Position and Visualize.
%
%   You can click the nodes to execute the current Node Action.
%
%   After some split or merge actions you can get the new tree
%   using the handle of the figure, which contains it.
%   You must use the following special syntax:
%       NEWT = PLOT(T,'read',FIG).
%   In fact, the first argument is dummy. Then the most general
%   syntax for this purpose is:
%       NEWT = PLOT(DUMMY,'READ',FIG);
%   where DUMMY is any object parented by an NTREE object.
%
%   DUMMY can be any object constructor name, which returns
%   an object parented by an NTREE object. For example:
%      NEWT = PLOT(ntree,'read',FIG);
%      NEWT = PLOT(dtree,'read',FIG);

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 07-Oct-1999.
%   Last Revision: 10-Jun-2013.
%   Copyright 1995-2013 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2013/07/05 04:29:30 $ 

nbin = length(varargin);
fig_tree = NaN;
switch nbin
  case 0    , option = 'create';
  otherwise
    option = varargin{1};
    if isnumeric(option)
        fig_tree = option;
        option = 'create';
    end
end

switch option
  case 'create'
  case {'length','type'} , fig_tree = varargin{2};  % Added Node Labels
  case'Reconstruct'      , fig_tree = varargin{2};  % Added Node Action
end

switch option
  case 'create'
    fig_tree = plot(get(t,'wtree'),fig_tree);
    if nargout>0 , varargout{1} = fig_tree; end
	set(fig_tree,'NumberTitle','Off','Name',...
        ['Fig ' handle2str(fig_tree) ...		
		 ' - Wavelet Tree Object - DWT extension mode: ',get(t,'dwtMode')]);

    % Store the WVTREE.
    %------------------
    plot(dtree,'write',fig_tree,t);

    % Add Node Label menus.
    %----------------------
    plot(ntree,'addNodeLabel',fig_tree,'length');
    plot(ntree,'addNodeLabel',fig_tree,'type');

    % Add Node Action menu.
    %----------------------
    plot(ntree,'addNodeAction',fig_tree,'Reconstruct');

    % Set default Node Label to 'Index'.
    %-----------------------------------
    plot(ntree,'setNodeLabel',fig_tree,'Index');

  case {'length','type'}
    t = plot(ntree,'read',fig_tree);
    if nbin<3 , nodes = allnodes(t); else nodes = varargin{3}; end
    n = length(nodes);
    switch option
      case 'length' , labtype = 's';
      case 'type'   , labtype = 't';
    end
    labels = tlabels(t,labtype,nodes);
    err    = ~isequal(n,size(labels,1));
    varargout = {labels,err};

  case 'Reconstruct'
    node = plot(ntree,'getNode',fig_tree);
    if isempty(node) , return; end
    t = plot(ntree,'read',fig_tree);
    axe_vis = plot(ntree,'getValue',fig_tree,'axe_vis');

    %============================================================%
    mousefrm(fig_tree,'watch')
    x = rnodcoef(t,node);
    if ~isempty(x)
        if min(size(x))<2
            plot(x,'Color','r','Parent',axe_vis);
            lx = length(x);
            if lx> 1 , set(axe_vis,'XLim',[1,lx]); end
        else
           NBC = 128;
           colormap(pink(NBC))
           image(wcodemat(x,NBC,'mat',0),'Parent',axe_vis);
        end
        endMSG = 'TREE_DataForNode_1';
    else
        delete(get(axe_vis,'Children'))
        endMSG = 'TREE_DataForNode_2';
    end
    order = treeord(t);
    [d,p] = ind2depo(order,node);
    ldep = sprintf('(%0.f,%0.f)',d,p);
    axeTitle = getWavMSG(['Wavelet:moreMSGRF:' endMSG],node,ldep);
    wtitle(axeTitle,'Parent',axe_vis);
    mousefrm(fig_tree,'arrow')
    %============================================================%

  otherwise
    try %#ok<*TRYNC>
      nbout = nargout;
      varargout{1:nbout} = plot(dtree,varargin{:});       
    end
        
end

%-------------------------------------------------------------------------%
% Internal Functions                                                      %
%-------------------------------------------------------------------------%
function labels = tlabels(t,varargin)

labtype = varargin{1};
if length(varargin)<2
    nodes = allnodes(t);
else
    nodes = varargin{2};
end
nbnodes	= length(nodes);
labels  = [];
order = treeord(t);
switch labtype
   case 's'
     sizes = read(t,'sizes',nodes);
     switch order
       case 2
         labels = sprintf('%0.f',max(sizes(1,:)));
         for k=2:nbnodes
           labels = char(labels,sprintf('%0.f',max(sizes(k,:)))); %#ok<*VCAT>
         end

       case 4
         labels = sprintf('(%0.f,%0.f)',sizes(1,:));  
         for k=2:nbnodes
           labels = char(labels,sprintf('(%0.f,%0.f)',sizes(k,:)));
         end
     end

   case 't'
     [~,p] = ind2depo(order,nodes);
     p = rem(p,order);
     pstr = repLine('a',nbnodes);
     if order==2
         I = find(p==1); pd = repLine('d',length(I)); pstr(I,:) = pd;
     else
         I = find(p==1); pd = repLine('h',length(I)); pstr(I,:) = pd;
         I = find(p==2); pd = repLine('v',length(I)); pstr(I,:) = pd;
         I = find(p==3); pd = repLine('d',length(I)); pstr(I,:) = pd;
     end
     lp = repLine('(',nbnodes);
     rp = repLine(')',nbnodes);
     labels = [lp pstr rp];
end
%-------------------------------------------------------------------------%
function m = repLine(c,n)
%REPLINE Replicate Lines.

m = c(ones(n,1),:);
%-------------------------------------------------------------------------%
