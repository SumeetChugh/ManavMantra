function record(obj, varargin)
%RECORD Record data and event information to a file.
%
%   RECORD(OBJ) toggles the object's, OBJ, RecordStatus property between 
%   on and off. When RecordStatus is on, commands written to the device,
%   data read from the device and event information will be recorded in
%   the file specified by OBJ's RecordName property. When RecordStatus
%   is off, no information is recorded. OBJ must be a 1-by-1 serial port 
%   object. By default, OBJ's RecordStatus is off.
%
%   The serial port object must be connected to the device with the 
%   FOPEN function before recording can begin. A connected serial port
%   object has a Status property value of open.
%
%   The record file is an ASCII file. If OBJ's RecordDetail property
%   is configured to compact, the record file contains information on
%   the number of values read from the device, the number of values
%   written to the device and event information. If OBJ's RecordDetail
%   property is configured to verbose, the record file also contains the 
%   data that was read from the device or written to the device.
%
%   Binary data with uchar, schar, (u)int8, (u)int16 or (u)int32 precision
%   is recorded in the record file in hexadecimal format. For example if
%   an int16 value of 255 is read from the instrument, the value 00FF is 
%   recorded in the record file. Binary data with single or double precision
%   is recorded according to the IEEE 754 floating-point bit layout. 
%
%   RECORD(OBJ, 'STATE') configures the object's, OBJ, RecordStatus property
%   value to be STATE. STATE can be either 'on' or 'off'.
%
%   OBJ's RecordStatus property value is automatically configured to 
%   off when the object is disconnected from the device with the FCLOSE 
%   function.
%
%   The RecordName and RecordMode properties are read-only while OBJ is
%   recording. These properties must be configured before using RECORD.
%
%   Example:
%       s = serial('COM1');
%       fopen(s)
%       set(s, 'RecordDetail', 'verbose')
%       record(s, 'on');
%       fprintf(s, '*IDN?')
%       fscanf(s);
%       fclose(s);
%       type record.txt
%
%   See also SERIAL/FOPEN, SERIAL/FCLOSE.
%

%   Copyright 1999-2016 The MathWorks, Inc. 

% Error checking.
if (nargin > 2)
    error(message('MATLAB:serial:record:invalidSyntax'));
end

if ~isa(obj, 'icinterface')
    error(message('MATLAB:serial:record:invalidOBJInterface'));
end

if (length(obj) > 1)
    error(message('MATLAB:serial:record:invalidOBJDim'));
end

% convert to char in order to accept string datatype
varargin = instrument.internal.stringConversionHelpers.str2char(varargin);

switch nargin
case 2
    if ~isa(varargin{1}, 'char')
        error(message('MATLAB:serial:record:invalidSTATE'));
    end
    if ~any(strcmpi(varargin{1}, {'on', 'off'}))
        error(message('MATLAB:serial:record:invalidSTATE'));
    end
end

% Call record on the java object.
try
    record(igetfield(obj, 'jobject'), varargin{:});
catch aException
   error(message('MATLAB:serial:record:opfailed', aException.message));
end   
