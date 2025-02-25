%LOADLIBRARY Load a shared library into MATLAB. 
%   LOADLIBRARY(SHRLIB,HDRFILE) Loads the functions defined in
%   header file HDRFILE and found in library SHRLIB into MATLAB.
%
%   LOADLIBRARY(SHRLIB,@PROTOFILE) Loads the functions defined in MATLAB
%   program file PROTOFILE  and found in library SHRLIB into MATLAB.
%   PROTOFILE  is a MATLAB program file that had previously been generated by
%   LOADLIBRARY using the 'MFILENAME' option.  @PROTOFILE  is a function
%   handle that references this file.
%
%   [NOTFOUND, WARNINGS] = LOADLIBRARY('SHRLIB','HDRFILE') returns warning
%   information from the shrlib library file. NOTFOUND is a cell array of
%   the names of functions found in the header file HDRFILE, or any header
%   added with the addheader option, but not found in the SHRLIB library.
%   WARNINGS contains a single character array of warnings produced while
%   processing the header file HDRFILE.
%
%   LOADLIBRARY(SHRLIB,...,OPTIONS) Loads the library SHRLIB with one
%   or more of the following OPTIONS.  (Only the ALIAS option is
%   available when loading using a prototype file.)
%
%   OPTIONS:
%      'ALIAS',LIBNAME     Allows the library to be loaded as a 
%          different library name.
%
%      'ADDHEADER',HDRFILE     Loads the functions defined in the 
%          additional header file, HDRFILE. Specify the header 
%          parameter as a filename without a file extension.  
%          MATLAB does not verify the existence of the header files 
%          and ignores any that are not needed.
%
%          You can specify as many additional header files as you need 
%          using the syntax
%             LOADLIBRARY shrlib hdrfile ...
%                addheader hdrfile1 ...
%                addheader hdrfile2 ...          % and so on
%
%      'INCLUDEPATH',PATHSPEC     Adds additional path in which to
%      look for included header files.
%
%      'MFILENAME',PROTOFILE    Creates the prototype program file PROTOFILE  
%          in the current directory and uses that file to load the library.  
%          Successive LOADLIBRARY commands can specify the function handle 
%          @PROTOFILE to use this prototype file as the header in loading
%          the library.  You can use this to speed up and simplify the 
%          load process.
%
%       'THUNKFILENAME',TFILENAME Overrides the default thunk file name
%       with TFILENAME.  See the DOC LOADLIBRARY section "Using loadlibrary
%       on 64-Bit Platforms" for more information.
%
%   This function requires a C compiler.  A compiler is not normally 
%   present on 64-bit Windows  and must be installed.  See DOC LOADLIBRARY
%   for a list of supported compilers.
%
%   See also UNLOADLIBRARY, LIBISLOADED, LIBFUNCTIONS.

%   Copyright 2002-2014 The MathWorks, Inc.