function makevase(action)
%MAKEVASE Generate and plot a surface of revolution.
%   This is a demonstration of MATLAB graphics
%   applied to both two and three dimensional
%   representations of data.
%
%   First, specify a line shape with the mouse
%   by clicking on the screen.  Click with the
%   right mouse (or shift-click) to enter the
%   final point.
%
%   When you have  finished, the body-of-revolution
%   corresponding to that line is plotted using the
%   SURFL command.
%
%   See also SURFL

%   Ned Gulley, 6-21-93; jae Roh, 10-15-96
%   Copyright 1984-2014 The MathWorks, Inc.

if nargin<1,
   action = 'initialize';
end;

switch lower(action)
   case 'initialize'
      figNumber = figure( ...
         'Name',getString(message('MATLAB:demos:makevase:TitleMakingAVase')), ...
         'NumberTitle','off', ...
         'RendererMode','manual',...
         'Visible','off');
      axes( ...
         'ButtonDownFcn','makevase(''axselect'')',...
         'Units','normalized', ...
         'XTick',[],'YTick',[], ...
         'Box','on', ...
         'Position',[0.05 0.35 0.70 0.60]);
      
      % ===================================
      % Set up the Comment Window
      top = 0.30;
      left = 0.05;
      right = 0.75;
      bottom = 0.05;
      labelHt = 0.05;
      spacing = 0.005;
      % First, the MiniCommand Window frame
      frmBorder = 0.02;
      frmPos = [left-frmBorder bottom-frmBorder ...
         (right-left)+2*frmBorder (top-bottom)+2*frmBorder];
      uicontrol( ...
         'Style','frame', ...
         'Units','normalized', ...
         'Position',frmPos, ...
         'BackgroundColor',[0.5 0.5 0.5]);
      % Then the text label
      labelPos = [left top-labelHt (right-left) labelHt];
      uicontrol( ...
         'Style','text', ...
         'Units','normalized', ...
         'Position',labelPos, ...
         'BackgroundColor',[0.5 0.5 0.5], ...
         'ForegroundColor',[1 1 1], ...
         'String',getString(message('MATLAB:demos:makevase:LabelCommentWindow')));
      % Then the editable text field
      txtPos = [left bottom (right-left) top-bottom-labelHt-spacing];
      txtHndl = uicontrol( ...
         'Style','edit', ...
         'HorizontalAlignment','left', ...
         'Units','normalized', ...
         'Max',10, ...
         'BackgroundColor',[1 1 1], ...
         'Position',txtPos, ...
         'Enable','inactive',...
         'Callback','makevase(''eval'')', ...
         'String','');
      % Save this handle for future use
      set(gcf,'UserData',txtHndl);
      
      % ====================================
      % Information for all buttons
      % labelColor = [0.8 0.8 0.8];
      top = 0.95;
      left = 0.80;
      btnWid = 0.15;
      btnHt = 0.10;
      % Spacing between the button and the next command's label
      spacing = 0.02;
      
      % ====================================
      % The CONSOLE frame
      frmBorder = 0.02;
      yPos = 0.05-frmBorder;
      frmPos = [left-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
      uicontrol( ...
         'Style','frame', ...
         'Units','normalized', ...
         'Position',frmPos, ...
         'BackgroundColor',[0.5 0.5 0.5]);
      
      % ====================================
      % The NEW SHAPE button
      btnNumber = 1;
      yPos = top-(btnNumber-1)*(btnHt+spacing);
      labelStr = getString(message('MATLAB:demos:makevase:ButtonNewShape'));
      callbackStr = 'makevase(''newshape'')';
      
      % Generic popup button information
      btnPos = [left yPos-btnHt btnWid btnHt];
      uicontrol( ...
         'Style','pushbutton', ...
         'Units','normalized', ...
         'Position',btnPos, ...
         'String',labelStr, ...
         'Callback',callbackStr, ...
         'UserData',btnNumber);
      
      % ====================================
      % The INFO button
      uicontrol( ...
         'Style','push', ...
         'Units','normalized', ...
         'Position',[left bottom+btnHt+spacing btnWid btnHt], ...
         'String',getString(message('MATLAB:demos:shared:LabelInfo')), ...
         'Callback','makevase(''info'')');
      
      % ====================================
      % The CLOSE button
      uicontrol( ...
         'Style','push', ...
         'Units','normalized', ...
         'Position',[left bottom btnWid btnHt], ...
         'String',getString(message('MATLAB:demos:shared:LabelClose')), ...
         'Callback','close(gcf)');
      % Now uncover the figure
      makevase('newshape');
      set(figNumber,'Visible','on');
      
   case 'axselect'
      figNumber = gcf;
      txtHndl = get(figNumber,'UserData');
      ptList = get(gca,'UserData');
      
      if ~strcmp(get(figNumber,'SelectionType'),'normal'),
         if size(ptList,1)<3,
            set(txtHndl,'String',' You must choose at least three points');
         else
            makevase('render');
         end % df size<3
      else
         currPt = get(gca,'CurrentPoint');
         currPt = currPt(1,1:2);
         
         ptList = [ptList; currPt];
         set(gca,'UserData',ptList);
         
         line(currPt(1),currPt(2), ...
            'LineStyle','none', ...
            'Marker','.', ...
            'Color','r', ...
            'MarkerSize',25);
         line(-currPt(1),currPt(2), ...
            'LineStyle','none', ...
            'Marker','.', ...
            'Color','b', ...
            'MarkerSize',25);
         
         numPts = size(ptList,1);
         if numPts>1
            line(ptList([numPts-1 numPts],1),ptList([numPts-1 numPts],2), ...
               'Color','y');
            line(-ptList([numPts-1 numPts],1),ptList([numPts-1 numPts],2), ...
               'Color','g');
         end % df numPts>1
         
      end % df ~normal click
   case 'render'
      figNumber = gcf;
      txtHndl = get(figNumber,'UserData');
      str = getString(message('MATLAB:demos:makevase:DlgRenderingPleaseWait'));
      set(txtHndl,'String',str);
      xylist = get(gca,'UserData');
      x = xylist(:,1)';
      y = xylist(:,2)';
      hold off;
      n = 180;
      t = (0:n)'*2*pi/n;
      hndl = surfl(cos(t)*x,sin(t)*x,ones(n+1,1)*y);
      set(hndl,...
         'EdgeColor','none',...
         'FaceLighting','gouraud',...
         'BackFaceLighting','reverselit');
      material metal;
      axis([-1.1 1.1 -1.1 1.1 0.1 0.9]);
      axis off;
      str = getString(message('MATLAB:demos:makevase:MsgRenderingComplete'));
      set(txtHndl,'String',str);
      
   case 'newshape'
      figNumber = gcf;
      txtHndl = get(figNumber,'UserData');
      str = getString(message('MATLAB:demos:makevase:MsgHowToMakeVase'));
      set(txtHndl,'String',str);
      cla reset;
      ax = [-1 1 0 1];
      plot([0 0],[0 1],'r');
      axis(ax);
      set(gca,'XTick',[],'YTick',[],...
         'Box','on',...
         'UserData',[],...
         'ButtonDownFcn','makevase(''axselect'')');
      hold on;
      colormap(fliplr(pink));
      
   case 'info'
      helpwin(mfilename);
      
end;    % switch action

