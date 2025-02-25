function varargout = textread(varargin)
%TEXTREAD Read formatted data from text file.
%    A = TEXTREAD('FILENAME')
%    A = TEXTREAD('FILENAME','',N)
%    A = TEXTREAD('FILENAME','',param,value, ...)
%    A = TEXTREAD('FILENAME','',N,param,value, ...) reads numeric data from the file
%    FILENAME into a single variable. If the file contains any text data, an error
%    is produced.
%
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT')
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',N)
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',param,value, ...)
%    [A,B,C, ...] = TEXTREAD('FILENAME','FORMAT',N,param,value, ...) reads data from
%    the file FILENAME into the variables A,B,C,etc. The type of each return
%    argument is given by the FORMAT specifier. The number of return arguments must
%    match the number of conversion specifiers in the FORMAT argument. If there are
%    fewer fields in the file than in the format specifier, an error is produced.
%    See FORMAT SPECIFIERS below for more information.
%
%    If N is specified, the format specifier is reused N times. If N is -1 (or not
%    specified) TEXTREAD reads the entire file.
%
%    If param,value pairs are supplied, user configurable options customize the
%    behavior of TEXTREAD. See USER CONFIGURABLE OPTIONS below.
%
%    TEXTREAD works by matching and converting groups of characters from the file. An
%    input field is defined as a character vector of non-whitespace characters
%    extending to the next whitespace or delimiter character or until the field width
%    is exhausted. Repeated delimiter characters are significant while repeated
%    whitespace characters are treated as one.
%
%    FORMAT SPECIFIERS
%
%    If the FORMAT specifier is empty, TEXTREAD will only numeric data.
%
%    The FORMAT specifier can contain whitespace characters (which are ignored),
%    ordinary characters (which are expected to match the next non-whitespace
%    character in the input), or conversion specifications.
%
%    Supported conversion specifications:
%        %n - read a number - float or integer (returns double array)
%             %5n reads up to 5 digits or until next delimiter
%        %d - read a signed integer value (returns double array)
%             %5d reads up to 5 digits or until next delimiter
%        %u - read an integer value (returns double array)
%             %5u reads up to 5 digits or until next delimiter
%        %f - read a floating point value (returns double array)
%             %5f reads up to 5 digits or until next delimiter
%        %s - read a whitespace separated text (returns cell array of character vectors)
%             %5s reads up to 5 characters or until whitespace
%        %q - read a double-quoted text, ignoring the quotes (returns returns cell array of character vectors)
%             %5q reads up to 5 non-quote characters or until whitespace
%        %c - read character or whitespace (returns char array)
%             %5c reads up to 5 characters including whitespace
%        %[...]  - reads characters matching characters between the
%                  brackets until first non-matching character or
%                  whitespace (returns cellstr)
%                  use %[]...] to include ]
%             %5[...] reads up to 5 characters
%        %[^...] - reads characters not matching characters between the
%                  brackets until first matching character or whitespace
%                  (returns cellstr)
%                  use %[^]...] to exclude ]
%             %5[^...] reads up to 5 characters
%
%    Note: Format specifiers are interpreted as with sprintf before parsing. For
%    example, textread('mydata.dat','%s\t') will search for a tab not the character
%    '\' followed by the character 't'. See the Language Reference Guide or a C
%    manual for complete details.
%
%    Using %* instead of % in a conversion causes TEXTREAD to skip the matching
%    characters in the input (and no output is created for this conversion).
%
%    The % can be followed by an optional field width to handle fixed width fields.
%    For example %5d reads a 5 digit integer. In addition the %f format supports the
%    form %<width>.<prec>f.
%
%    USER CONFIGURABLE OPTIONS
%
%    Possible param/value options are:
%         'bufsize'      - maximum text length in bytes (default is 4095)
%         'commentstyle' - one of 
%              'matlab'  -- characters after % are ignored
%              'shell'   -- characters after # are ignored
%              'c'       -- characters between /* and */ are ignored
%              'c++'     -- characters after // are ignored
%         'delimiter'    - delimiter characters (default is none)
%         'emptyvalue'   - empty cell value in delimited files (default is 0)
%         'endofline'    - end of line character (default determined from file)
%         'expchars'     - exponent characters (default is 'eEdD')
%         'headerlines'  - number of lines at beginning of file to skip
%         'whitespace'   - whitespace characters (default is ' \b\t')
%    
%    TEXTREAD is useful for reading text files with a known format. Both
%    fixed and free format files can be handled.
%
%    Examples:
%     Suppose the text file mydata.dat contains data in the following form:
%        Sally    Type1 12.34 45 Yes
%        Joe      Type2 23.54 60 No
%        Bill     Type1 34.90 12 No
%          
%     Read each column into a variable
%       [names,types,x,y,answer] = textread('mydata.dat','%s%s%f%d%s');
%
%     Read first column into a cell array (skipping rest of line)
%       [names]=textread('mydata.dat','%s%*[^\n]')
%
%     Read first character into char array (skipping rest of line)
%       [initials]=textread('mydata.dat','%c%*[^\n]')
%
%     Read file as a fixed format file while skipping the doubles
%       [names,types,y,answer] = textread('mydata.dat','%9c%5s%*f%2d%3s');
%
%     Read file and match Type literal
%       [names,typenum,x,y,answer]=textread('mydata.dat','%sType%d%f%d%s');
%
%     Read MATLAB file into cell array of character vectors
%       file = textread('fft.m','%s','delimiter','\n','whitespace','');
%
%     To read all numeric data from a delimited text file, use a single output
%     argument, empty format specifier, and the appropriate delimiter. For 
%     example, suppose data.csv contains:
%       1,2,3,4
%       5,6,7,8
%       9,10,11,12
%
%     Read the whole matrix into a single variable:
%       [data] = textread('data.csv','','delimiter',',');
%
%     Read the first two columns into two variables:
%       [col1, col2] = textread('data.csv','%n%n%*[^\n]','delimiter',',');
%
%     For files with empty cells, use the emptyvalue parameter. Suppose
%     data.csv contains:
%       1,2,3,4,,6
%       7,8,9,,11,12
%
%     Read the file like this, using NaN in empty cells:
%       [data] = textread('data.csv','','delimiter',',','emptyvalue',NaN);
%
%   TEXTREAD is not recommended. Use TEXTSCAN instead.
%
%   See also TEXTSCAN, STRREAD, DLMREAD, LOAD, SSCANF, XLSREAD.

%   Copyright 1984-2016 The MathWorks, Inc.

% do some preliminary error checking
narginchk(1,inf);
varargin{1} = reshape(varargin{1}', 1, numel(varargin{1}));
if (noargname(@exist,varargin{1}) ~= 2 || noargname(@exist,fullfile(cd,varargin{1})) ~= 2) ...
                                       && ~isempty(noargname(@which,varargin{1}))
    varargin{1} = noargname(@which,varargin{1});
end

%MDL files should be readable, as well as ordinary files.
nRet = noargname(@exist,varargin{1});
if  nRet ~= 2 && nRet ~= 4
    error(message('MATLAB:textread:FileNotFound'));
end

if nargout == 0
    nlhs = 1;
else
    nlhs = nargout;
end

[varargout{1:nlhs}]=dataread('file',varargin{:}); %#ok<REMFF1>

% Execute the function handle f in a context that has
% no variable with the name 'f' or 'arg'. We assume
% only one return argument.
%
function arg = noargname(f,arg)
if strcmpi(arg,'f')
   tmp = f;
   clear f;
   arg = tmp(arg);
elseif strcmpi(arg,'arg')
   tmp = arg;
   clear arg;
   arg = f(tmp);
else
   arg = f(arg);
end
