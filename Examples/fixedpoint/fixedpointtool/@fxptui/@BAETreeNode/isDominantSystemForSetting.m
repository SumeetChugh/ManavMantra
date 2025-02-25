function b = isDominantSystemForSetting(this, propName)
% ISDOMINANTSYSTEMFORSETTING returns true if the property is controlled by this subsystem

% Copyright 2015 The MathWorks, Inc.

    b = false;
    %SubSystem, BlockDiagram or Charts are valid
    if(~fxptui.isValidTreeNode(this));
        return;
    end
    %if this is a ModelReference, LinkedLibrary or a system under a linked library (disable mmo and dto)
    if this.isNotSupportedDTOMMO
        return;
    end
    
    [dSys, dParam] = getDominantSystemForSetting(this, propName);
    b = isa(this, 'fxptui.blkdgmnode') || isequal(dSys, this.daobject);
    
    if b
        switch propName
          case 'MinMaxOverflowLogging'
            this.MMODominantSystem = [];
            this.MMODominantParam = '';
          case 'DataTypeOverride'
            this.DTODominantSystem = [];
            this.DTODominantParam = '';
          otherwise
        end
    else
        switch propName
          case 'MinMaxOverflowLogging'
            this.MMODominantSystem = dSys;
            this.MMODominantParam = dParam;
          case 'DataTypeOverride'
            this.DTODominantSystem = dSys;
            this.DTODominantParam = dParam;
          otherwise
        end
    end
end


