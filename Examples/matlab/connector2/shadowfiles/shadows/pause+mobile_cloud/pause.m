function varargout = pause(varargin)
%PAUSE Wait for user response.
%   PAUSE(n) pauses for n seconds before continuing, where n can also be a
%   fraction. The resolution of the clock is platform specific. Fractional
%   pauses of 0.01 seconds should be supported on most platforms.
%
%   PAUSE causes a procedure to stop and wait for the user to strike any
%   key before continuing.
%
%   NOTE: The maximum pause is 2 seconds for this product offering on this platform.
%
%   PAUSE OFF indicates that any subsequent PAUSE or PAUSE(n) commands
%   should not actually pause. This allows normally interactive scripts to
%   run unattended.
%
%   PAUSE ON indicates that subsequent PAUSE commands should pause.
%
%   PAUSE QUERY returns the current state of pause, either 'on' or 'off'.
%
%   STATE = PAUSE(...) returns the state of pause previous to processing
%   the input arguments.
%
%   The accuracy of PAUSE is subject to the scheduling resolution of the
%   operating system you are using and also to other system activity. It
%   cannot be guaranteed with 100% confidence, but only with some expected
%   error. For example, experiments have shown that choosing N with a
%   resolution of .1 (such as N = 1.7) leads to actual pause values that
%   are correct to roughly 10% in the relative error of the fractional
%   part. Asking for finer resolutions (such as .01) shows higher relative
%   error.
%
%   Examples:
%       % Pause for 1 seconds
%       pause(1)
%
%       % Temporarily disable pause
%       pause off
%       pause(1) % Note that this does not pause
%       pause on
%
%       % Aternatively, disable/restore the state
%       pstate = pause('off')
%       pause(1) % Note that this does not pause
%       pause(pstate);
%
%   See also KEYBOARD, INPUT.

%   Copyright 1984-2011 The MathWorks, Inc.

if nargin == 0
    error(message('MATLAB:connector:Platform:FunctionArgumentsNotSupported', mfilename, 'empty'));
elseif any(isinf(varargin{1}))
    error(message('MATLAB:connector:Platform:FunctionArgumentsNotSupported', mfilename, 'Inf'));
elseif isnumeric(varargin{1}) && varargin{1} > 2
    error(message('MATLAB:connector:Platform:FunctionArgumentsNotSupported', mfilename, 'n > 2'));
else
    try
        % run the regular pause command
        if nargout > 0
            varargout = {builtin('pause', varargin{:})};
        else
            builtin('pause', varargin{:});
        end
    catch e
        throw(e);
    end
end

end
