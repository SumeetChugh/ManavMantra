classdef (CaseInsensitiveProperties = true, TruncatedProperties = true) datametadata
%

%   Copyright 2009-2016 The MathWorks, Inc.
    
    properties
        Units = '';
        Interpolation;
        UserData;
        InterpretSingleRowDataAs3D = false;
    end
    
    properties (Hidden = true, GetAccess = protected, SetAccess = protected)
        Version = 10.1;
    end
    
    methods
        
        function outmetadata = utCommonMath(in1, in2)
            % UTCOMMONMATH  Returns a common datametadata object.
            %
            % OBJ = UTCOMMONMATH(OBJ1,OBJ2) where OBJ1 and OBJ2 are two datametadata
            % objects. When OBJ1 is the same as OBJ2, OBJ is equal to OBJ1. Otherwise,
            % OBJ is generated by the datametadata constructor.
            %

            
            % Merge Units
            if ~isempty(in1.Units) && ~isempty(in2.Units) && strcmp(in1.Units,in2.Units)
                outordunits = in1.Units;
            else
                outordunits = '';
            end
            
            % Merge interpolation. Differing methods => zoh
            if isequal(in1.Interpolation.Fhandle,in2.Interpolation.Fhandle)
                outordinterp = in1.Interpolation;
            else
                outordinterp = tsdata.interpolation('linear');
            end
            
            % Merge UserData
            if isequal(in1.UserData,in2.UserData)
                outordUserData = in1.UserData;
            else
                outordUserData = [];
            end
            
            outmetadata = tsdata.datametadata;
            outmetadata.Units = outordunits;
            outmetadata.Interpolation = outordinterp;
            outmetadata.UserData = outordUserData;
        end
        
        function isStorage = isstorage(~)
            isStorage = false;
        end
        
        %Setter function for interpolation property
        function this = set.Interpolation(this, myFuncHandle)
            if ischar(myFuncHandle) || isstring(myFuncHandle) || isa(myFuncHandle,'function_handle')
                this.Interpolation = tsdata.interpolation(myFuncHandle);
            elseif isa(myFuncHandle,'tsdata.interpolation')
                this.Interpolation = myFuncHandle;
            else
                error(message('MATLAB:timeseries:setinterpmethod:invInterp'));
            end
        end
    end
    
    methods (Static = true, Hidden = true)
        function this = loadobj(obj)
            if isstruct(obj)
                this = tsdata.datametadata;
                if isfield(obj,'Units')
                    this.Units = obj.Units;
                else
                    this.Units = '';
                end
                if isfield(obj,'Interpolation')
                    this.Interpolation = obj.Interpolation;
                else
                    this.Interpolation = tsdata.interpolation('linear');
                end
                if isfield(obj,'UserData')
                    this.UserData = obj.UserData;
                end         
            elseif isa(obj,'tsdata.datametadata')
                this = obj;
            else
                error(message('MATLAB:tsdata:datametadata:loadobj:invloaddatametadata'));
            end
        end
        
        function warnAboutIsTimeFirst(isTimeFirst,sizeData,len,interpretSingleRowDataAs3D)
            % isTimeFirst deprecation warning now throws error if the isTimeFirst disagrees
            % with the calculated isTimeFirst value.
            if (len>0 && isTimeFirst ~= tsdata.datametadata.isTimeFirst(sizeData,len,interpretSingleRowDataAs3D))                 
               error(message('MATLAB:tsdata:datametadata:warnAboutIsTimeFirst:isTimeFirstDeprecationError'));
            end
        end   
        
        % Static method to compute the isTimeFirst property from the
        % InterpretSingleRowDataAs3D stored in the datametadata SampleDimensions
        % property. The algorithm works as follows:
        function state = isTimeFirst(sizeData,len,interpretSingleRowDataAs3D)

            if nargin<=2 || isempty(interpretSingleRowDataAs3D)
                interpretSingleRowDataAs3D = false;
            end
            
            if len~=1
                state = length(sizeData)<=2;
            else
                % If the data is a single row sample use
                % interpretSingleRowDataAs3D to compute isTimeFirst
                if length(sizeData)==2 && sizeData(1)==1
                    state = ~interpretSingleRowDataAs3D;
                else % 3d vectors or column vectors require isTimeFirst false
                    state = false;                   
                end
            end     
        end
        
        % Compute the sample size form the data. In the current
        % implementation, isTimeFirst is settable, so it must be passed as
        % an input argument. This static method implements the following
        % lookup table:
        %
        %
        %                       isTimeFirst
        %             true                      false
        %           ----------------------------------------------
        %  len==1  |  sizeData(2:end)           sizeData          |
        %          |                                              |
        %  len>1   |  sizeData(2:end)           sizeData(1:end-1) |
        %             --------------------------------------------
        function sampleSize = getSampleDimensions(sizeData,len,isTimeFirst)
            % <=10a algorithm
            if isTimeFirst
                sampleSize = sizeData(2:end);
            else
                if len==1 
                    sampleSize = sizeData;
                else
                    sampleSize = sizeData(1:end-1);
                end
            end
        end
        
        function [metadata,data1,data2] = combineDataForBinaryMath(in1,in2,data1,data2)
        
            % Utility method which synchronizes the data and metadata in 
            % @datametadata objects for binary math operations. This code
            % is shared by overloaded binary math methods.
            
            % Extract the data and construct the output datametadata
            if ~isempty(in1) && ~isempty(in2) && isobject(in1) && ...
                    isa(in2,'tsdata.datametadata')
                metadata = utCommonMath(in1,in2);
            elseif ~isempty(in1) && isobject(in1) 
                metadata = in1;
            elseif ~isempty(in2) && isobject(in2)
                metadata = in2;
            else
                error(message('MATLAB:tsdata:datametadata:combineDataForBinaryMath:nonumeric')) 
            end

            % TO DO: Remove the following cast once the test: test/toolbox/
            % fixpoint/fpca/tfpca_task3 is updated so the that order
            % of the signals reported in the Model Advisor html reflects 
            % the change in the class of the result of a @timeseries
            % embedded.fi minus operation.
            if ~strcmp(class(data1),class(data2))
                data1 = double(data1);
                data2 = double(data2);
            end
            % Expand scalar samples to the size of non-scalar samples.
            if ~isequal(size(data1),size(data2))
                s1 = size(data1);
                s2 = size(data2);
                s1 = [s1 ones(1,length(s2)-length(s1))];
                s2 = [s2 ones(1,length(s1)-length(s2))];
                if sum(s1>=2)==1 && (s1(1)==1 || s1(end)==1) && sum(s2>=2)>1
                    if s1(1)>1
                        data1 = repmat(data1,[1 s2(2:end)]);
                    elseif s1(end)>1
                        data1 = repmat(data1,[s2(1:end-1) 1]);
                    end
                elseif sum(s2>=2)==1 && (s2(1)==1 || s2(end)==1) && sum(s1>=2)>1
                    if s2(1)>1
                        data2 = repmat(data2,[1 s1(2:end)]);
                    elseif s1(end)>1
                        data2 = repmat(data2,[s1(1:end-1) 1]);
                    end
                end
            end
        end


    
        function [metadata,data] = defaultplus(in1,in2,data1,data2)

            %  Default implementation of overloaded plus used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload plus.

            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultplus:plusnonnumeric'));
            end
            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the addition
            try
                data = data1+data2;
            catch me
                if strcmp(me.identifier,'MATLAB:dimagree')
                      error(message('MATLAB:tsdata:datametadata:defaultplus:nonconfdimMatrixAdd'))
                else           
                    data = double(data1)+double(data2);
                end
            end
        end

        function [metadata,data] = defaultminus(in1,in2,data1,data2)

            %  Default implementation of overloaded minus used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload minus.

            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultminus:minusnonnumeric'));
            end           
            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the subtraction
            try
                data = data1-data2;
            catch me
                if strcmp(me.identifier,'MATLAB:dimagree')
                      error(message('MATLAB:tsdata:datametadata:defaultminus:nonconfdimMatrixSub'))
                else           
                    data = double(data1)-double(data2);
                end
            end
        end
        
        function [metadata,data] = defaultmtimes(in1,in2,data1,data2,isTimeFirst)

            
            %  Default implementation of overloaded mtimes used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload mtimes.
            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultmtimes:mtimesnonnumeric'));
            end
            if nargin<=4
                isTimeFirst = true;
            end

            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the mtimes
            try
                data = localmtimes(data1,data2,isTimeFirst);
            catch me
                if strcmp(me.identifier,'MATLAB:innerdim') || strcmp(me.identifier,'MATLAB:subsassigndimmismatch')
                      error(message('MATLAB:tsdata:datametadata:defaultmtimes:nonconfdimMatrixMul'))
                else           
                     data = localmtimes(double(data1),double(data2),isTimeFirst);
                end
            end   
        end
        
       function [metadata,data] = defaulttimes(in1,in2,data1,data2)


            %  Default implementation of overloaded times used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload times.
            
            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaulttimes:timesnonnumeric'));
            end
            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the times
            try
                data = data1.*data2;
            catch me
                if strcmp(me.identifier,'MATLAB:dimagree')
                      error(message('MATLAB:tsdata:datametadata:defaulttimes:nonconfdimMult'))
                else           
                    data = double(data1).*(double(data2));
                end
            end
       end

       function [metadata,data] = defaultldivide(in1,in2,data1,data2)


            %  Default implementation of overloaded ldivide used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload ldivide.
            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultldivide:ldividenonnumeric'));
            end
            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the ldivide
            try
                data = data1.\data2;
            catch me
                if strcmp(me.identifier,'MATLAB:dimagree')
                      error(message('MATLAB:tsdata:datametadata:defaultldivide:nonconfdimLDiv'))
                else           
                    data = double(data1).\(double(data2));
                end
            end
       end

       function [metadata,data] = defaultrdivide(in1,in2,data1,data2)


            %  Default implementation of overloaded rdivide used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload rdivide.
            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultrdivide:rdividenonnumeric'));
            end
            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the rdivide
            try
                data = data1./data2;
            catch me
                if strcmp(me.identifier,'MATLAB:dimagree')
                      error(message('MATLAB:tsdata:datametadata:defaultrdivide:nonconfdimRDiv'))
                else           
                    data = double(data1)./(double(data2));
                end
            end
       end
        
       function [metadata,data] = defaultmrdivide(in1,in2,data1,data2,isTimeFirst)

           
            %  Default implementation of overloaded mrdivide used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload mrdivide.
            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultmrdivide:mrdividenonnumeric'));
            end
            if nargin<=4
                isTimeFirst = true;
            end

            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the mrdivide
            try
                data = localmrdivide(data1,data2,isTimeFirst);
            catch me
                if strcmp(me.identifier,'MATLAB:innerdim') || strcmp(me.identifier,'MATLAB:subsassigndimmismatch')
                      error(message('MATLAB:tsdata:datametadata:defaultmrdivide:nonconfdimMLDiv'))
                else           
                     data = localmrdivide(double(data1),double(data2),isTimeFirst);
                end
            end  
        end
        

       function [metadata,data] = defaultmldivide(in1,in2,data1,data2,isTimeFirst)

           
            %  Default implemtenation of overloaded mldivide used by
            %  datametadata classes which do not store their own data. Note
            %  that subclasses of datametadata which do store data should
            %  overload mldivide.
            if (~isnumeric(data1) && ~islogical(data1)) || ...
                    (~isnumeric(data2) && ~islogical(data2))
                    error(message('MATLAB:tsdata:datametadata:defaultmldivide:mldividenonnumeric'));
            end
            if nargin<=4
                isTimeFirst = true;
            end

            [metadata,data1,data2] = tsdata.datametadata.combineDataForBinaryMath(in1,in2,data1,data2);

            % Perform the mldivide
            try
                data = localmldivide(data1,data2,isTimeFirst);
            catch me
                if strcmp(me.identifier,'MATLAB:innerdim') || strcmp(me.identifier,'MATLAB:subsassigndimmismatch')
                      error(message('MATLAB:tsdata:datametadata:defaultmldivide:nonconfdimMLDiv'))
                else           
                     data = localmldivide(double(data1),double(data2),isTimeFirst);
                end
            end  
       end       

    end
        
end

%%%%%%%%%%%%%% Local functions for numeric binary math %%%%%%%%%%%%%%%%%%%%

function dataout = localpermTimeToLast(data)
    % PERMTIMETOLAST Make the time dimension the last dimension
    if length(size(data))==2
        dataout = reshape(data,[1 size(data,2) size(data,1)]);
    else
        dataout = shiftdim(data,1);
    end
end


function data = localmtimes(data1,data2,isTimeFirst)

    if isscalar(data1) || isscalar(data2)
        data = data1*data2;
        return;
    end

    s1 = size(data1);
    s2 = size(data2);
    if isTimeFirst
        data = zeros(s1(1),s1(2),s2(end));
        data1 = localpermTimeToLast(data1);
        data2 = localpermTimeToLast(data2);
        for i=1:s1(1)
            data(i,:,:) = data1(:,:,i)*data2(:,:,i);
        end
    else
        data = zeros(s1(1),s2(end-1),s2(end));
        for i=1:s2(end)
            data(:,:,i) = data1(:,:,i)*data2(:,:,i);
        end
    end

end


function data = localmrdivide(data1,data2,isTimeFirst)

    % Perform the mrdivide
    if isscalar(data2)
        data = data1/data2;
        return;
    elseif isscalar(data1) 
        data = (data1/data2)';
        return;
    end

    s1 = size(data1);
    s2 = size(data2);
    if isTimeFirst
        data = zeros(s1(1),s1(2),s2(end));
        data1 = localpermTimeToLast(data1);
        data2 = localpermTimeToLast(data2);
        for i=1:s1(1)
            data(i,:,:) = data1(:,:,i)/data2(:,:,i);
        end
    else
        data = zeros(s1(1),s2(end-1),s2(end));
        for i=1:s2(end)
            data(:,:,i) = data1(:,:,i)/data2(:,:,i);
        end
    end
end


function data = localmldivide(data1,data2,isTimeFirst)

   % Perform the mldivide
    s1 = size(data1);
    s2 = size(data2);
    if isTimeFirst
        data = zeros(s1(1),s1(2),s2(end));
        data1 = localpermTimeToLast(data1);
        data2 = localpermTimeToLast(data2);
        for i=1:s1(1)
            data(i,:,:) = data1(:,:,i)\data2(:,:,i);
        end
    else
        data = zeros(s1(1),s2(end-1),s2(end));
        for i=1:s2(end)
            data(:,:,i) = data1(:,:,i)\data2(:,:,i);
        end
    end
end