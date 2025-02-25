function applyShortcut(this, shortcutName)
% APPLYSHORTCUT Modify the system parameters based on the settings
% defined in the shortcut.

%   Copyright 2015-2016 The MathWorks, Inc.

% Flip all nodes in the tree to 'UseLocalSettings' before applying the
% batch action.
batchActionMap = getSettingsMapForShortcut(this,shortcutName);
try
    [refMdls, ~] = find_mdlrefs(this.ModelName);
catch mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

if ~isempty(batchActionMap)
    if batchActionMap.isKey('GlobalModelSettings')
        globalSettingsMap = batchActionMap.getDataByKey('GlobalModelSettings');
        for m = 1:globalSettingsMap.getCount
            prop = globalSettingsMap.getKeyByIndex(m);
            switch prop
                case {'CaptureDTO','CaptureInstrumentation','ModifyDefaultRun'}
                    this.(prop) = globalSettingsMap.getDataByKey(prop);
                    if strcmp(prop,'ModifyDefaultRun')
                        if globalSettingsMap.isKey('RunName')
                            set_param(this.ModelName,'FPTRunName',globalSettingsMap.getDataByKey('RunName'));
                        end
                    end
            end
        end
    end
    changeToLocalSettings(this);
    if batchActionMap.isKey('SystemSettingMap')
        settingMap = batchActionMap.getDataByKey('SystemSettingMap');
        for i = 1:settingMap.getCount
            blkSID = settingMap.getKeyByIndex(i);
            try
                blkObj = get_param(Simulink.ID.getHandle(blkSID),'Object');
                if ~isempty(refMdls)
                    modelName = Simulink.ID.getModel(blkSID);
                    if sum(ismember(refMdls, modelName)) == 0
                        % this model is not part of the model ref hierarchy, do
                        % not apply these settings.
                        continue;
                    end
                end
                % If the object captured is a model reference block, but
                % its referenced model is not captured, then skip it as it
                % is most likely no longer on the path, invalid or deleted.
                if isa(blkObj,'Simulink.ModelReference')
                    if ~settingMap.isKey(blkObj.ModelName)
                        continue;
                    end
                end
                
                blkSIDMap = settingMap.getDataByKey(blkSID);
                b = this.isFactoryShortcut(shortcutName);
                if blkSIDMap.isKey('DataTypeOverride') && this.CaptureDTO
                    if ~isa(blkObj,'Simulink.ModelReference')
                        set_param(blkObj.getFullName,'DataTypeOverride',blkSIDMap.getDataByKey('DataTypeOverride'));
                    end
                    if b
                        for p = 1:numel(refMdls)-1
                            set_param(refMdls{p},'DataTypeOverride',blkSIDMap.getDataByKey('DataTypeOverride'));
                        end
                    end
                    
                end
                if blkSIDMap.isKey('DataTypeOverrideAppliesTo') && this.CaptureDTO
                    if ~isa(blkObj,'Simulink.ModelReference')
                        set_param(blkObj.getFullName,'DataTypeOverrideAppliesTo',blkSIDMap.getDataByKey('DataTypeOverrideAppliesTo'));
                    end
                    if b
                        for p = 1:numel(refMdls)-1
                            set_param(refMdls{p},'DataTypeOverrideAppliesTo',blkSIDMap.getDataByKey('DataTypeOverrideAppliesTo'));
                        end
                    end
                end
                if blkSIDMap.isKey('MinMaxOverflowLogging') && this.CaptureInstrumentation
                    if ~isa(blkObj,'Simulink.ModelReference')
                        set_param(blkObj.getFullName,'MinMaxOverflowLogging',blkSIDMap.getDataByKey('MinMaxOverflowLogging'));
                    end
                    if b
                        for p = 1:numel(refMdls)-1
                            set_param(refMdls{p},'MinMaxOverflowLogging',blkSIDMap.getDataByKey('MinMaxOverflowLogging'));
                        end
                    end
                end
                if blkSIDMap.isKey('MLFBVariant')
                    fpt = fxptui.FixedPointTool.getExistingInstance;
                    if ~isempty(fpt)
                        fpt.getExternalViewer.overrideConvertedMATLABFunctionBlocks(modelName,blkSIDMap.getDataByKey('MLFBVariant'));
                    end
                end
            catch e
                % Blk no longer exists
                %continue;
            end
        end
    end
end
end

% LocalWords:  modelnotfound FPT
