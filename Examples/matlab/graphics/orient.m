function varargout = orient(varargin)
%ORIENT Set paper orientation for printing.
%   ORIENT is used to set up the orientation of a Figure or Model
%   window for printing.
%
%   ORIENT LANDSCAPE causes subsequent PRINT operations from the current
%   Figure window to generate output in full-page landscape orientation
%   on the paper. 
%
%   ORIENT ROTATED causes subsequent PRINT operations from the current
%   Figure window to generate output in full-page rotated orientation
%   on the paper. 
%
%   ORIENT PORTRAIT causes subsequent PRINT operations from the current
%   Figure window to generate output in portrait orientation.
%
%   ORIENT TALL causes the current Figure window to map to the whole page
%   in portrait orientation for subsequent PRINT operations. 
%
%   ORIENT, by itself, returns a string containing the paper
%   orientation, either PORTRAIT, LANDSCAPE, ROTATED or TALL
%	of the current Figure.
%
%   ORIENT(FIGHandle) or ORIENT(MODELName) returns the current
%   orientation of the Figure or Model.
%
%   ORIENT( FIG, ORIENTATION) specifies which figure to orient and how to 
%   orient it based on the rules given above.  ORIENTATION is one of
%   'landscape', 'portrait', 'rotated', or 'tall'.
%
%   ORIENT( SYS, ORIENTATION ) species which Simulink model or system
%   to orient and how to orient it based on the rules given above.
%
%   For more specific information on how this function works, refer to
%   this MATLAB file by entering the command:
%
%      type orient.m
%
%   at the MATLAB command line.
%
%   See also PRINT.

%   Copyright 1984-2017 The MathWorks, Inc.

%   ORIENT PORTRAIT does one of three things:
%     If the current figure PaperType is the same as the default
%     PaperType and the DefaultFigurePaperOrientation is
%     PORTRAIT, then ORIENT PORTRAIT returns the figure to the default
%     PaperOrientation and PaperPosition settings. 
%
%     If the current figure PaperType is the same as the default
%     PaperType and the DefaultFigurePaperOrientation is
%     LANDSCAPE, then ORIENT PORTRAIT will use the 
%     DefaultFigurePaperPosition value with the X/Y and Width/Height 
%     values flipped.
%
%     If the current figure PaperType is different than the default
%     PaperType, then the X/Y and Width/Height of the current
%     figure PaperPosition are flipped.
%
%   ORIENT TALL causes the current figure window to map to the whole page
%   in portrait PaperOrientation. The PaperPosition is set to the
%   PaperSize minus a 0.25 inch border around the outside.
%

import matlab.graphics.internal.isCharOrString;

switch nargin
  % make one if no figure, that is current behavior
  case 0
    HandleStr = gcf;
    varargout{1} = LocalGetOrientation(HandleStr);

  % Figure handle or Simulink Model passed in    
  % return current orientation  
  case 1
    if isCharOrString(varargin{1})
      switch lower(varargin{1})
        % An orientation was passed in so set the current figure's orientation
        case {'landscape','rotated', 'portrait','tall'}
          HandleStr=gcf;
          
          Orientation=lower(varargin{1});
          aMessage=LocalSetOrientation(HandleStr,Orientation);          
          if ~isempty(aMessage)
            error(aMessage);
          end            
          
          if nargout
            varargout{1}=Orientation;
          end

        % A figure or model handle was passed in so return its orientation.
        otherwise
          [HandleStr,aMessage]=LocalValidateHandleStr(varargin{1});
          if ~isempty(aMessage)
            error(aMessage);
          end            
          
          varargout{1}=LocalGetOrientation(HandleStr);  
          
      end % switch
      
    % A handle was passed in, so get the orientation      
    else      
      
      [HandleStr,aMessage]=LocalValidateHandleStr(varargin{1});
      if ~isempty(aMessage)
        error(aMessage);
      end
      
      varargout{1}=LocalGetOrientation(HandleStr);  
      
    end % if isstr
      
  case 2
    [HandleStr,aMessage]=LocalValidateHandleStr(varargin{1});    
    if ~isempty(aMessage)
      error(aMessage);
    end
    
    Orientation=lower(varargin{2});    
    aMessage=LocalSetOrientation(HandleStr,Orientation);
    if ~isempty(aMessage)
      error(aMessage);
    end
    if nargout
      varargout{1}=Orientation;
    end

end % switch nargin


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGetOrientation %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Orientation=LocalGetOrientation(HandleStr)
  Orientation = LocalGet(HandleStr,'PaperOrientation');
  if strcmp(Orientation,'portrait')
    
    TempPaperUnits=LocalGet(HandleStr,'PaperUnits');
    LocalSet(HandleStr,'PaperUnits','inches');
    
    PaperPosition = LocalGet(HandleStr,'PaperPosition');
    PaperSize = LocalGet(HandleStr,'PaperSize');
    
    LocalSet(HandleStr,'PaperUnits',TempPaperUnits);
    
    if all(PaperPosition([3,4]) == (PaperSize-.5))
      Orientation = 'tall';
    end
    
  end % if strcmp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSetOrientation %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function aMessage=LocalSetOrientation(HandleStr,Orientation)

  aMessage=[];
  
  % If the current paperpositionmode is auto then set the orientation
  % and return
  CurrentPaperPositionMode=LocalGet(HandleStr,'PaperPositionMode');
  if strcmp(CurrentPaperPositionMode,'auto') && ...
        ~strcmp(Orientation,'tall')
    if ~strcmp(Orientation,'portrait') && ...
       ~strcmp(Orientation,'rotated') && ...
       ~strcmp(Orientation,'landscape')
      aMessage=message('MATLAB:orient:InvalidOrientation');      
      
    else
      LocalSet(HandleStr,'PaperOrientation',Orientation);
      
    end    % if ~strcmp
    
    return
    
  end % if strcmp

  % The current paperpositionmode is manual
  TempPaperUnits=LocalGet(HandleStr,'PaperUnits');
  LocalSet(HandleStr,'PaperUnits','inches');       
  
  CurrentOrientation=LocalGet(HandleStr,'PaperOrientation');  
  CurrentPosition=LocalGet(HandleStr,'PaperPosition');
  NewPosition=CurrentPosition;
  
  switch Orientation
    case {'landscape', 'rotated'}
      % This needs to be here so that papersize is correct
      LocalSet(HandleStr,'PaperOrientation',Orientation);
      PaperSize = LocalGet(HandleStr,'PaperSize');
      NewPosition=[0.25 0.25 PaperSize-0.5];
      
    case 'portrait'
      if ~matlab.graphics.internal.isCharOrString(HandleStr)
        DefaultOrientation=get(0,'DefaultFigurePaperOrientation');
        %DefaultUnits=get(0,'DefaultFigurePaperUnits');
        DefaultPosition=get(0,'DefaultFigurePaperPosition');
        DefaultPaperType=get(0,'DefaultFigurePaperType');
      else
        DefaultOrientation=get_param(0,'PaperOrientation');
        %DefaultUnits=get_param(0,'PaperUnits');
        DefaultPosition=get_param(0,'PaperPosition');
        DefaultPaperType=get_param(0,'PaperType');
      end
      LocalSet(HandleStr,'PaperOrientation',Orientation);
      
      % check to see if the current papertype and the default
      % papertype are the same.  If they are, be smart, otherwise
      % don't do anything.
      if strcmp(LocalGet(HandleStr,'PaperType'),DefaultPaperType)

        if strcmp(DefaultOrientation,Orientation)
          NewPosition=DefaultPosition;
        else
          NewPosition=DefaultPosition([2 1 4 3]);
        end % if strcmp
        
        % The current PaperType and default PaperType are not
        % the same so do something that makes sense.
      else  
        % If the current and new orientation are different then
        % flip the x,y and width,height
        % If the new orientation and the current orientation are the
        % same then do nothing.
        if ~strcmp(CurrentOrientation,Orientation)
          LocalSet(HandleStr,'PaperOrientation',Orientation);
          NewPosition=CurrentPosition([2 1 4 3]);
          
        end %if ~strcmp
      end % if strcmp

    case 'tall'
      % PaperPositionMode is going to be forced to manual
      Orientation='portrait';
      LocalSet(HandleStr,'PaperOrientation',Orientation);
      PaperSize = LocalGet(HandleStr,'PaperSize');
      NewPosition=[0.25 0.25 PaperSize-0.5];
      
    otherwise
      aMessage=message('MATLAB:orient:InvalidOrientation');      
      
  end % switch      
  
  LocalSet(HandleStr,'PaperPosition',NewPosition);
  LocalSet(HandleStr,'PaperUnits',TempPaperUnits);

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalGet %%%%%
%%%%%%%%%%%%%%%%%%%%
function Value=LocalGet(HandleStr,Parameter)
% Deal with SL model
if matlab.graphics.internal.isCharOrString(HandleStr)
  Value=get_param(HandleStr,Parameter);
else
  Value=get(HandleStr,Parameter);
end

%%%%%%%%%%%%%%%%%%%%
%%%%% LocalSet %%%%%
%%%%%%%%%%%%%%%%%%%%
function LocalSet(HandleStr,Parameter,Value)
if matlab.graphics.internal.isCharOrString(HandleStr)
  RootSys=bdroot(HandleStr);
  LockSetting=get_param(RootSys,'Lock');
  set_param(RootSys,'Lock','off');
  set_param(HandleStr,Parameter,Value);
  set_param(RootSys,'Lock',LockSetting);
else
  set(HandleStr,Parameter,Value)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% LocalValidateHandleStr %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HandleStr,aMessage]=LocalValidateHandleStr(HandleStr)

import matlab.graphics.internal.isCharOrString;

IsHG=false;
IsSimulink=true;

% since a Simulink Model will be specified by a String name in HandleStr 
% and a Figure won't ever be specified as a String, don't bother trying 
% the get_param call UNLESS it's a character string.
if isCharOrString(HandleStr) 
   try
      get_param(HandleStr,'Handle');
   catch
      IsSimulink=false;
   end
else
   IsSimulink = ~ishghandle(HandleStr);
end

if ~isCharOrString(HandleStr) && ~IsSimulink
  IsHG=ishghandle(HandleStr);
end  

aMessage=[];
if IsHG
  %HandleStr=HandleStr;
  
elseif IsSimulink
  if ~strcmp(get_param(HandleStr,'Type'),'block_diagram') && ...
        ~strcmp(get_param(HandleStr,'BlockType'),'SubSystem')
    HandleStr=[];
    aMessage=message('MATLAB:orient:InvalidHandle');
    return     
  else
    HandleStr=getfullname(HandleStr);
  end
  
else
  HandleStr=[];
  aMessage=message('MATLAB:orient:InvalidHandle');
end  
