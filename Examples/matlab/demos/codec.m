function codec(action)
%CODEC  Coder/Decoder
%   The CODEC acts like an encoder/decoder for
%   messages using the letters of the alphabet.
%   The "Code" popup menu determines the
%   degree of transposition: a "b" code transposes
%   all letters by one like so: "alphabet" becomes
%   "bmqibcfu" and so on.
%
%   The "Mode" popup menu determines whether
%   you are encoding or decoding.

%   Ned Gulley, 6-21-93; jae Roh, 10-15-96
%   Copyright 1984-2014 The MathWorks, Inc.

% Possible actions:
% initialize
% type
% shading
% colormap
% axis

if nargin<1,
   action = 'initialize';
end;

if strcmp(action,'initialize'),
   figNumber = figure( ...
      'Visible','off', ...
      'Name',getString(message('MATLAB:demos:codec:TitleCodeDecode')), ...
      'NumberTitle','off');
   
   % ===================================
   % Set up the Input Window
   top = 0.95;
   left = 0.05;
   right = 0.75;
   bottom = 0.53;
   labelHt = 0.05;
   spacing = 0.005;
   callback = 'codec(''encode'')';
   
   % First, the MiniCommand Window frame
   frmBorder = 0.02;
   frmPos = [left-frmBorder bottom-frmBorder ...
      (right-left)+2*frmBorder (top-bottom)+2*frmBorder];
   uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',192/255*[1 1 1]);
   % Then the text label
   labelPos = [left top-labelHt (right-left) labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',192/255*[1 1 1], ...
      'String',getString(message('MATLAB:demos:codec:LabelInput')));
   % Then the editable text field
   txtPos = [left bottom (right-left) top-bottom-labelHt-spacing];
   inputHndl = uicontrol( ...
      'Style','edit', ...
      'FontName','courier', ...
      'FontSize',14, ...
      'HorizontalAlignment','left', ...
      'Units','normalized', ...
      'Max',10, ...
      'String','MATLAB', ...
      'BackgroundColor',[1 1 1], ...
      'Callback',callback, ...
      'Position',txtPos);
   
   % ===================================
   % Set up the Output Window
   top = 0.48;
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
      'BackgroundColor',192/255*[1 1 1]);
   % Then the text label
   labelPos = [left top-labelHt (right-left) labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',192/255*[1 1 1], ...
      'String',getString(message('MATLAB:demos:codec:LabelOutput')));
   % Then the editable text field
   txtPos = [left bottom (right-left) top-bottom-labelHt-spacing];
   outputHndl = uicontrol( ...
      'Style','edit', ...
      'FontName','courier', ...
      'FontSize',14, ...
      'HorizontalAlignment','left', ...
      'Units','normalized', ...
      'Max',10, ...
      'BackgroundColor',[1 1 1], ...
      'Position',txtPos);
   % Save this handle for future use
   % set(gcf,'UserData',txtHndl);
   
   % ====================================
   % Information for all buttons
   labelColor = [0.8 0.8 0.8];
   % yInitLabelPos = 0.80;
   xLabelPos = 0.80;
   labelWid = 0.15;
   labelHt = 0.05;
   btnWid = 0.15;
   btnHt = 0.05;
   % Spacing between the label and the button for the same command
   btnOffset = 0.005;
   % Spacing between the button and the next command's label
   spacing = 0.05;
   
   % ====================================
   % The CONSOLE frame
   frmBorder = 0.02;
   yPos = 0.05-frmBorder;
   frmPos = [xLabelPos-frmBorder yPos btnWid+2*frmBorder 0.9+2*frmBorder];
   uicontrol( ...
      'Style','frame', ...
      'Units','normalized', ...
      'Position',frmPos, ...
      'BackgroundColor',192/255*[1 1 1]);
   
   % ====================================
   % The CODE command popup button
   btnNumber = 1;
   yLabelPos = 0.95-(btnNumber-1)*(btnHt+labelHt+spacing);
   labelStr = [' ',getString(message('MATLAB:demos:codec:LabelCodeKeyLetter'))];
   popupStr = char(97:122)';
   callbackStr = 'codec(''encode'')';
   
   % Generic label information
   labelPos = [xLabelPos yLabelPos-labelHt labelWid labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',labelColor, ...
      'HorizontalAlignment','left', ...
      'String',labelStr);
   
   % Generic popup button information
   btnPos = [xLabelPos yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   typeHndl = uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'Value',2, ...
      'String',popupStr, ...
      'Callback',callbackStr);
   
   % ====================================
   % The MODE command popup button
   btnNumber = 2;
   yLabelPos = 0.95-(btnNumber-1)*(btnHt+labelHt+spacing);
   labelStr = [' ',getString(message('MATLAB:demos:codec:LabelMode'))];
   popupStr = str2mat(getString(message('MATLAB:demos:codec:PopupEncode')),getString(message('MATLAB:demos:codec:PopupDecode')));
   callbackStr = 'codec(''encode'')';
   
   % Generic label information
   labelPos = [xLabelPos yLabelPos-labelHt labelWid labelHt];
   uicontrol( ...
      'Style','text', ...
      'Units','normalized', ...
      'Position',labelPos, ...
      'BackgroundColor',labelColor, ...
      'HorizontalAlignment','left', ...
      'String',labelStr);
   
   % Generic popup button information
   btnPos = [xLabelPos yLabelPos-labelHt-btnHt-btnOffset btnWid btnHt];
   modeHndl = uicontrol( ...
      'Style','popup', ...
      'Units','normalized', ...
      'Position',btnPos, ...
      'String',popupStr, ...
      'Callback',callbackStr);
   
   % ====================================
   uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[xLabelPos 0.20 btnWid 0.10], ...
      'String',getString(message('MATLAB:demos:shared:LabelInfo')), ...
      'Callback','codec(''info'')');
   
   % The close button.
   uicontrol( ...
      'Style','push', ...
      'Units','normalized', ...
      'Position',[xLabelPos 0.05 btnWid 0.10], ...
      'String',getString(message('MATLAB:demos:shared:LabelClose')), ...
      'Callback','close(gcf)');
   
   % Uncover the figure
   hndlList = [inputHndl outputHndl typeHndl modeHndl];
   set(figNumber,'Visible','on', ...
      'UserData',hndlList);
   codec encode
   
elseif strcmp(action,'info'),
   helpwin(mfilename);
   
elseif strcmp(action,'encode'),
   hndlList = get(gcf,'UserData');
   inputHndl = hndlList(1);
   outputHndl = hndlList(2);
   typeHndl = hndlList(3);
   modeHndl = hndlList(4);
   % Get direction
   dir = get(modeHndl,'Value')*(-2)+3;
   % Get key
   key = get(typeHndl,'Value');
   inStr = get(inputHndl,'String');
   inStr = abs(inStr);
   selectLowerCase = (inStr >= 97) & (inStr <= 122);
   selectUpperCase = (inStr >= 65) & (inStr <= 90);
   codeStrLower = inStr(selectLowerCase)+dir*(key-1);
   codeStrUpper = inStr(selectUpperCase)+dir*(key-1);
   if ~isempty(codeStrLower),
      codeStrLower(codeStrLower>122) = codeStrLower(codeStrLower>122)-26;
      codeStrLower(codeStrLower<97) = codeStrLower(codeStrLower<97)+26;
   end;
   if ~isempty(codeStrUpper),
      codeStrUpper(codeStrUpper>90) = codeStrUpper(codeStrUpper>90)-26;
      codeStrUpper(codeStrUpper<65) = codeStrUpper(codeStrUpper<65)+26;
   end;
   if ~isempty(inStr),
      inStr(selectLowerCase) = codeStrLower;
      inStr(selectUpperCase) = codeStrUpper;
   end;
   outStr = char(inStr);
   set(outputHndl,'String',outStr);
   
end;    % if strcmp(action, ...
