function disp(obj)
%DISP Display method for timer objects.
%
%   DISP(OBJ) displays information pertaining to the timer object.
%   OBJ can be an array of timer objects.
%
%   See also TIMER/GET.

%    RDD 11-20-2001
%    Copyright 2001-2017 The MathWorks, Inc.

s = length(obj);
validobjs = obj.isvalid();
jobj(validobjs) = obj(validobjs).getJobjects;
validObj = isJavaTimer(jobj);

if (s==0)
    % empty object
    fprintf(getString(message('MATLAB:timer:EmptyTimerObject')));
elseif (s==1)
    % single object to be displayed
    if ~validObj
        % if the timer is an invalid object, display the invalid message.
        fprintf('%s\n', getString(message('MATLAB:timer:invalid')));
    else 
        % print out the object's most important properties in a table.
                
        fprintf([...
                '\n   Timer Object: ' localEscapeString(obj.Name) '\n\n' ... 
                '   Timer Settings\n' ...
                '      ExecutionMode: ' obj.ExecutionMode '\n' ... 
                '             Period: ' num2str(obj.Period) '\n' ... 
                '           BusyMode: ' obj.BusyMode '\n' ... 
                '            Running: ' obj.Running '\n\n' ... 
                '   Callbacks\n' ...
                '           TimerFcn: ' cb2str(obj.TimerFcn,40) '\n' ...
                '           ErrorFcn: ' cb2str(obj.ErrorFcn,40) '\n' ...
                '           StartFcn: ' cb2str(obj.StartFcn,40) '\n' ...
                '            StopFcn: ' cb2str(obj.StopFcn,40) '\n\n']);
    end
else
    % Multiple-timer objects. First write out the header.
    fprintf(['\nTimer Object Array\n\n', ...
            '   Index:  ExecutionMode:  Period:  TimerFcn:               Name:\n']);
    for i = 1:s
        index = num2str(i);
        fprintf([blanks(3) index blanks(8 - length(index))]);
        if validobjs(i)
            % Valid object. Get the property values.
            modeVal   = obj(i).ExecutionMode;
            PeriodVal = num2str(obj(i).Period);
            timerFcnVal = cb2str(obj(i).TimerFcn,23);
            nameVal = localEscapeString(obj(i).Name);
        else
            % Invalid object. Just display 'Invalid' for each property.
            modeVal = 'Invalid';
            PeriodVal = 'Invalid';
            timerFcnVal = 'Invalid';
            nameVal = 'Invalid';
        end	
        fprintf([modeVal blanks(16 - length(modeVal)), ...
                PeriodVal blanks(9 - length(PeriodVal)), ...
                timerFcnVal blanks(24 - length(timerFcnVal)), ...
                nameVal, '\n']);
    end
    fprintf('\n');
end

function out = cb2str(cb,maxlen)
% this subfunction formats a callback into a more favorable text description,
% which could be a cell array containing about any data type
%
% Note: something like "s=eval('disp(cb)')" doesn't give good results
%
noncb = false;
if isempty(cb) && isa(cb,'double') % if empty double, display empty brackets
    out = '[]';
elseif ischar(cb) % if character, surround cb with tick marks
    out = localEscapeString([ '''' cb '''' ]);
elseif isa(cb,'function_handle') % function handle is displayed with @ prefix
    out = func2str(cb);
    if (strncmp(out, '@', 1) == 0)
        out = ['@' out ];
    end
elseif iscell(cb) % for cell, surround with {}
    cdisp = evalc('disp(cb)');
    
    % Remove spaces from the start of the string and replace them with an
    % open brace.
    out = regexprep(cdisp, '^\s*', '{', 'once');
    
    % Remove spaces from the end of the string and replace them with a
    % close brace.
    out = regexprep(out, '\s*$', '}', 'once');
    
    % Replace any remaining spaces with a single space.
    out = regexprep(out, '\s*', ' ');
    
    out = localEscapeString(out);
else % otherwise, mark for just summary output
    noncb = true;
end

% if too long, just display size/class summary
if (length(out)>maxlen) || noncb
    sz = size(cb);
    dims = length(sz);
    out = [];
    % display size in AxBxC format
    for lcv=1:dims-1
        out = [out num2str(sz(lcv)) 'x'];
    end
    out = [out num2str(sz(dims)) ' ' class(cb)];     % add the class name
    if isobject(cb) % tag on discriptors like 'object' for objects...
        out = [out ' object'];
    else
        out = [out ' array'];
    end
end

function out = localEscapeString(theString)
% This function escapes the '%' and '\' characters in strings to be passed
% to fprintf.  This allows them to be printed out normally.
escapeChars = {'%', '\'};
out = theString;
for i = 1:length(escapeChars)
    out = strrep(out, escapeChars{i}, [escapeChars{i} escapeChars{i}]);
end
    