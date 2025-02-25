classdef ImageBrowserCore < handle
    
    % Copyright 2016-2017 The MathWorks, Inc.
    properties (Constant = true)        
        % Left and right arrow icons for the preview (when multiple
        % thumbnails are selected)
        LIconImage = ...
            imread(fullfile(matlabroot,'toolbox','images','icons','leftArrow.png'));
        RIconImage = ...
            imread(fullfile(matlabroot,'toolbox','images','icons','rightArrow.png'));        
    end
    
    properties
        ToolGroup
        tabGroup
        mainTab
        
        loadSplitButton;
        
        sizeSlider;
        slideLabel;
        
        togglePreviewButton;
        
        zoomInButton;
        zoomOutButton;
        panButton;
        
        gallery;
        galleryItems;
        
        exportButton;
        wasAnythingExported = false;
        
        hThumbnailFig = matlab.graphics.primitive.Image.empty();
        hThumbnailComponent;
        thumbnailSize = [125 125];
        % Index into CurrentSelection when more than one thumbnail is
        % selected
        CurrentSelection = [];
        selectionIndex = [];
        
        hPreviewFig    = matlab.graphics.primitive.Image.empty();
        hPreviewPanel  = [];
        hPreviewImageAxes = matlab.graphics.axis.Axes.empty();
        hPreviewLRButtons = [];
               
        statusBar;
        statusText='';
        notificationTimer=[];
                               
        supportedImageFormats = {};
        
    end
    
    methods
        
        function tool = ImageBrowserCore()
            
            %% Setup
            tool.ToolGroup = matlab.ui.internal.desktop.ToolGroup(getString(message('images:imageBrowser:appName')));
            tool.ToolGroup.setClosingApprovalNeeded(true);
            
            % Add DDUX logging to Toolgroup
            images.internal.app.utilities.addDDUXLogging(tool.ToolGroup,'Image Processing Toolbox','Image Browser');
            
            tool.ToolGroup.setContextualHelpCallback(@(es, ed) doc('Image Browser'));
            
            import matlab.ui.internal.toolstrip.*;
            tool.tabGroup = TabGroup();
            tool.mainTab  = Tab(getString(message('images:imageBrowser:Browse')));
            
            %% Load
            section = tool.mainTab.addSection(getString(message('images:imageBrowser:Load')));
            
            c = section.addColumn();
            tool.loadSplitButton = SplitButton(getString(message('images:imageBrowser:Load')),Icon.IMPORT_24);
            tool.loadSplitButton.Tag = 'LoadSplitButton';
            tool.loadSplitButton.Description = getString(message('images:imageBrowser:LoadToolTip'));
            tool.loadSplitButton.ButtonPushedFcn = @(varargin)tool.loadFolderUI(false);
            tool.loadSplitButton.DynamicPopupFcn = @(x,y) buildDynamicPopupListForLoadImages();
            c.add(tool.loadSplitButton);
            
            function popup = buildDynamicPopupListForLoadImages()
                import matlab.ui.internal.toolstrip.*
                popup = PopupList();
                popup.Tag = 'LoadButtonPopUp';
                
                item = ListItem(getString(message('images:imageBrowser:LoadFolder')),Icon.IMPORT_16);
                item.Tag = 'LoadFolder';
                item.ShowDescription = false;
                item.ItemPushedFcn = @(varargin)tool.loadFolderUI(false);
                popup.add(item);
                
                item = ListItem(getString(message('images:imageBrowser:LoadFolderWithSub')),Icon.IMPORT_16);
                item.Tag = 'LoadFolderAndSubfolders';
                item.ShowDescription = false;
                item.ItemPushedFcn = @(varargin)tool.loadFolderUI(true);
                popup.add(item);
                
                item = ListItem(getString(message('images:imageBrowser:LoadIMDS')),Icon.IMPORT_16);
                item.Tag = 'LoadDatastore';
                item.ShowDescription = false;
                item.ItemPushedFcn = @(varargin)tool.loadimdsUI();
                popup.add(item);
            end
            
            %% Thumbnails
            section = tool.mainTab.addSection(getString(message('images:imageBrowser:Thumbnails')));
            
            % Slider
            topCol = section.addColumn('width',150,...
                'HorizontalAlignment','center');            
            tool.sizeSlider = Slider();
            tool.sizeSlider.Tag = 'Slider';
            tool.sizeSlider.Description = getString(message('images:imageBrowser:ThumbnailSizeTooltip'));
            tool.sizeSlider.Enabled = false;
            tool.sizeSlider.Limits = [50 800];
            tool.sizeSlider.Ticks = 5;
            tool.sizeSlider.Value = tool.thumbnailSize(1);
            tool.sizeSlider.ValueChangedFcn = @(varargin)tool.applyThumnailSizeChange;
            topCol.add(tool.sizeSlider);
            
            tool.slideLabel = Label(getString(message('images:imageBrowser:ThumbnailSize')));
            tool.slideLabel.Tag = 'SliderLabel';                        
            tool.slideLabel.Enabled = false;
            
            topCol.add(tool.slideLabel);
            
            
            %% Preview
            section = tool.mainTab.addSection(getString(message('images:imageBrowser:Preview')));
            
            topCol = section.addColumn();
            tool.togglePreviewButton = ToggleButton(getString(message('images:imageBrowser:Preview')), Icon.SEARCH_24);
            tool.togglePreviewButton.Tag = 'PreviewToggle';
            tool.togglePreviewButton.Description = getString(message('images:imageBrowser:PreviewTooltip'));
            tool.togglePreviewButton.Enabled = false;
            tool.togglePreviewButton.ValueChangedFcn = @(varargin)tool.togglePreview();
            topCol.add(tool.togglePreviewButton);
            
            topCol = section.addColumn();
            tool.zoomInButton = ToggleButton(getString(message('images:commonUIString:zoomInTooltip')), Icon.ZOOM_IN_16);
            tool.zoomInButton.Tag = 'ZoomInButton';
            tool.zoomInButton.Enabled = false;
            tool.zoomInButton.Description = getString(message('images:commonUIString:zoomInTooltip'));
            tool.zoomInButton.ValueChangedFcn = @(varargin)tool.zoomInPreview();
            topCol.add(tool.zoomInButton);
            tool.zoomOutButton = ToggleButton(getString(message('images:commonUIString:zoomOutTooltip')), Icon.ZOOM_OUT_16);
            tool.zoomOutButton.Tag = 'ZoomOutButton';
            tool.zoomOutButton.Enabled = false;
            tool.zoomOutButton.Description = getString(message('images:commonUIString:zoomOutTooltip'));
            tool.zoomOutButton.ValueChangedFcn = @(varargin)tool.zoomOutPreview();
            topCol.add(tool.zoomOutButton);
            tool.panButton = ToggleButton(getString(message('images:commonUIString:pan')), Icon.PAN_16);
            tool.panButton.Tag = 'PanButton';
            tool.panButton.Enabled = false;
            tool.panButton.Description = getString(message('images:commonUIString:pan'));
            tool.panButton.ValueChangedFcn = @(varargin)tool.panPreview();
            topCol.add(tool.panButton);
            
            %% Launcher Gallery
            section = tool.mainTab.addSection(getString(message('images:commonUIString:Launcher')));
            topCol = section.addColumn();
            popup = GalleryPopup();
            popup.Tag = 'GalleryPopup';
            
            % build categories
            vizCat = GalleryCategory('Visualization');
            vizCat.Tag = 'VisualizationCategory';
            analysisCat = GalleryCategory('Analysis');
            analysisCat.Tag = 'AnalysisCategory';
            popup.add(vizCat);
            popup.add(analysisCat);
            
            % imtool
            imtoolIconImage = fullfile(matlabroot,'toolbox','images','icons','image_app_24.png');
            tool.galleryItems.imtoolItem = GalleryItem(getString(message('images:desktop:Tool_imtool_Label')),Icon(imtoolIconImage));
            tool.galleryItems.imtoolItem.Tag = 'Launcher_imtool';
            tool.galleryItems.imtoolItem.Enabled = false;
            tool.galleryItems.imtoolItem.Description = getString(message('images:desktop:Tool_imtool_Description'));
            tool.galleryItems.imtoolItem.ItemPushedFcn = @(varargin)tool.launchImtool;
            vizCat.add(tool.galleryItems.imtoolItem);
            
            % color thresholder
            colorThreshIcon = fullfile(matlabroot,'toolbox','images','icons','color_thresholder_24.png');
            tool.galleryItems.colorThreshItem = GalleryItem(getString(message('images:desktop:Tool_colorThresholder_Label')),Icon(colorThreshIcon));
            tool.galleryItems.colorThreshItem.Tag = 'Launcher_colorThresholder';
            tool.galleryItems.colorThreshItem.Enabled =false;
            tool.galleryItems.colorThreshItem.Description = getString(message('images:desktop:Tool_colorThresholder_Description'));
            tool.galleryItems.colorThreshItem.ItemPushedFcn = @(varargin)tool.launchColorThresh;
            analysisCat.add(tool.galleryItems.colorThreshItem);
            
            % segmenter
            segAppIcon = fullfile(matlabroot,'toolbox','images','icons','imageSegmenter_AppIcon_24.png');
            tool.galleryItems.segItem = GalleryItem(getString(message('images:desktop:Tool_imageSegmenter_Label')),Icon(segAppIcon));
            tool.galleryItems.segItem.Tag = 'Launcher_imageSegmenter';
            tool.galleryItems.segItem.Enabled = false;
            tool.galleryItems.segItem.Description = getString(message('images:desktop:Tool_imageSegmenter_Description'));
            tool.galleryItems.segItem.ItemPushedFcn = @(varargin)tool.launchSegApp;
            analysisCat.add(tool.galleryItems.segItem);
            
            % region analyzer
            regionAnalyAppIcon = fullfile(matlabroot,'toolbox','images','icons','ImageRegionAnalyzer_AppIcon_24px.png');
            tool.galleryItems.regionAnalyItem = GalleryItem(getString(message('images:desktop:Tool_imageRegionAnalyzer_Label')),Icon(regionAnalyAppIcon));
            tool.galleryItems.regionAnalyItem.Tag = 'Launcher_imageRegionAnalyzer';
            tool.galleryItems.regionAnalyItem.Enabled = false;
            tool.galleryItems.regionAnalyItem.Description = getString(message('images:desktop:Tool_imageRegionAnalyzer_Description'));
            tool.galleryItems.regionAnalyItem.ItemPushedFcn = @(varargin)tool.launchRegionApp;
            analysisCat.add(tool.galleryItems.regionAnalyItem);
            
            
            tool.gallery = Gallery(popup,'MaxColumnCount',4,'MinColumnCount',2);
            topCol.add(tool.gallery);
            
            %% Export
            section = tool.mainTab.addSection(getString(message('images:commonUIString:export')));
            section.Tag = '';
            topCol = section.addColumn();
            tool.exportButton = Button(getString(message('images:imageBrowser:exportAll')),Icon.CONFIRM_24);
            tool.exportButton.Description = getString(message('images:imageBrowser:exportAllTooltip'));
            tool.exportButton.Tag = 'ExportButton';
            tool.exportButton.Enabled = false;
            tool.exportButton.ButtonPushedFcn = @(varargin)tool.exportToDataStore();
            topCol.add(tool.exportButton);
            
            %%
            imf = imformats;
            tool.supportedImageFormats = strcat('.',[imf.ext]);
            tool.supportedImageFormats{end+1} = '.dcm';
            tool.supportedImageFormats{end+1} = '.dic';
            tool.supportedImageFormats{end+1} = '.ima';
            tool.supportedImageFormats{end+1} = '.ntf';
            tool.supportedImageFormats{end+1} = '.nitf';
            tool.supportedImageFormats{end+1} = '.dpx';
            
            %% App setup
            tool.tabGroup.add(tool.mainTab);
            tool.tabGroup.SelectedTab = tool.mainTab;
            tool.ToolGroup.addTabGroup(tool.tabGroup);
            tool.ToolGroup.hideViewTab();
            
            % Disable "Hide" option in tabs.
            g = tool.ToolGroup.Peer.getWrappedComponent;
            g.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.PERMIT_DOCUMENT_BAR_HIDE, false);
            
            % Disable drag-drop
            dropListener = com.mathworks.widgets.desk.DTGroupProperty.IGNORE_ALL_DROPS;
            group = tool.ToolGroup.Peer.getWrappedComponent;
            group.putGroupProperty(com.mathworks.widgets.desk.DTGroupProperty.DROP_LISTENER, dropListener);
            
            [x,y,width,height] = imageslib.internal.apputil.ScreenUtilities.getInitialToolPosition();            
            tool.ToolGroup.setPosition(x, y, width, height);
            
            tool.ToolGroup.disableDataBrowser();

            % Show the app
            tool.ToolGroup.open();                        
            
            % Store java toolgroup so that app will stay in memory
            internal.setJavaCustomData(tool.ToolGroup.Peer,tool);
                        
            addlistener(tool.ToolGroup,'GroupAction',@(src, hEvent) tool.closeCallback(hEvent));
            
            tool.setStatus(getString(message('images:imageBrowser:clickLoad')));
        end
        
        %% Load
        function loadFolderUI(tool, recursiveTF)
            if ~isempty(tool.hThumbnailFig) && isvalid(tool.hThumbnailFig)
                if tool.okToClearExisting()
                    tool.deleteThumbnailFigure();
                    tool.resetApp();
                else
                    return;
                end
            end
            
            dirname = uigetdir(pwd,getString(message('images:imageBrowser:SelectFolder')));
            if(dirname)
                tool.loadFolder(dirname, recursiveTF);
            end
        end
        function loadFolder(tool, dirname, recursiveTF)
            tool.showAsBusy;
            % Force tool to wait before proceeding.
            drawnow;
            resetWait = onCleanup(@()tool.unshowAsBusy);
            
            tool.setStatus(getString(message('images:imageBrowser:loadingFolder',dirname)));
            
            try
                imds = imageDatastore(dirname,...
                    'IncludeSubfolders',recursiveTF,...
                    'ReadFcn', @iptui.internal.imageBrowser.readAllIPTFormats,...
                    'FileExtensions', tool.supportedImageFormats);
                
                if dirname(end)=='/' || dirname(end)=='\'
                    % Drop trailing / to get dirname using fileparts
                    dirname(end)=[];
                end
                if strcmp(dirname,'.')
                    % Get the actual dir name
                    dirname = pwd;
                end
                
                [~,cname] = fileparts(dirname);
                
                tool.newFileCollectionFig(cname);                                
                
                if numel(imds.Files)>0
                    tool.hThumbnailComponent.imds = imds;
                    tool.hThumbnailFig.Name = [cname, ' (',num2str(numel(imds.Files)), ' ', getString(message('images:imageBrowser:images')), ')'];
                    tool.hThumbnailFig.Tag  = cname;
                    tool.setNotificationMessage(getString(message('images:imageBrowser:loadedN', num2str(numel(imds.Files)))));
                    tool.hThumbnailComponent.setSelection(1);
                else
                    hw = warndlg(getString(message('images:imageBatchProcessor:noImagesFoundDetail',dirname)),...
                        getString(message('images:imageBatchProcessor:noImagesFound')),...
                        'modal');
                    uiwait(hw);
                    tool.deleteThumbnailFigure();
                    tool.resetApp();
                end
            catch ALL
                if(strcmp(ALL.identifier,'MATLAB:datastoreio:pathlookup:emptyFolderNoSuggestion'))
                    hw = warndlg(getString(message('images:imageBatchProcessor:noImagesFoundDetail',dirname)),...
                        getString(message('images:imageBatchProcessor:noImagesFound')),...
                        'modal');
                    uiwait(hw);
                else
                    % Catch all failure
                    hw = warndlg(getString(message('images:imageBrowser:unableToLoad',dirname)),...
                        getString(message('images:imageBrowser:unableToLoadTitle')),...
                        'modal');
                    uiwait(hw);
                end
            end
            
            
        end
        function loadimdsUI(tool)
            if ~isempty(tool.hThumbnailFig) && isvalid(tool.hThumbnailFig)
                if tool.okToClearExisting()
                    tool.deleteThumbnailFigure();
                    tool.resetApp();
                else
                    return;
                end
            end
            
            varInfo = evalin('base','whos');
            imdsVars = varInfo(strcmp({varInfo.class},'matlab.io.datastore.ImageDatastore'));
            
            if isempty(imdsVars)
                errordlg(getString(message('images:imageBrowser:noimds')),...
                    getString(message('images:imageBrowser:noimdsTitle')),...
                    'modal');
                return;
            end
            
            hd = dialog('Visible','on',...
                'Name',getString(message('images:imageBrowser:importImageDataStore')),...
                'Units','char');
            hd.Position(3:4) = [70 20];
            
            okCancelRowHeight = 2;
            
            % List of imds
            hl = uicontrol('Style','listbox',...
                'Units','char',...
                'Fontname','Courier',...
                'Value',1,...
                'Parent',hd,...
                'Tag','ListBoxIMDS',...
                'Position', [0 okCancelRowHeight+2 hd.Position(3), hd.Position(4)-okCancelRowHeight-2-1],...
                'String', {imdsVars.name});
            
            % OK - Cancel
            hOk = uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback', @(varargin)importimds,...
                'Position',[hd.Position(3)-10-2 1 10 okCancelRowHeight],...
                'Tag', 'importOk',...
                'String',getString(message('images:commonUIString:ok')));
            hCancel = uicontrol('Style','pushbutton',...
                'Parent', hd,...
                'Units','char',...
                'Callback',@(varargin)delete(hd),...
                'Position',[2 1 10 okCancelRowHeight],...                
                'Tag', 'importCancel',...
                'String',getString(message('images:commonUIString:cancel')));
            
            hd.Units = 'pixels'; % needed for positioning API below
            hd.Position = imageslib.internal.apputil.ScreenUtilities.getModalDialogPos(...
                tool.ToolGroup.Name, hd.Position(3:4));
            hd.Visible = 'on';
            
            function importimds
                hOk.Enable = 'off';
                hCancel.Enable = 'off';
                varName = hl.String{hl.Value};
                imds = evalin('base',varName);
                delete(hd);
                tool.newVarCollectionFig(varName,imds);
            end
            
        end
        
        function tf = okToClearExisting(~)
            tf = false;
            noStr  = getString(message('images:commonUIString:no'));
            yesStr = getString(message('images:commonUIString:yes'));
            
            selectedStr = questdlg(...
                getString(message('images:imageBrowser:clearContent')),...
                getString(message('images:imageBrowser:clearContentTitle')),...
                yesStr, noStr, noStr);
            if(strcmp(selectedStr, yesStr))
                tf = true;
            end
        end
        
        %% Thumbnail slider
        function applyThumnailSizeChange(tool)
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            
            tool.thumbnailSize(1) = tool.sizeSlider.Value;
            tool.thumbnailSize(2) = tool.sizeSlider.Value;
            
            % Update component's sizes
            tool.hThumbnailComponent.updateThumbnailSize(tool.thumbnailSize);            
        end
        
        %% Zoom pan
        function zoomInPreview(tool)
            zoom(tool.hPreviewFig,'off');
            pan(tool.hPreviewFig,'off');
            if tool.zoomInButton.Value
                tool.zoomOutButton.Value = false;
                tool.panButton.Value     = false;
                hZoomPan = zoom(tool.hPreviewFig);
                hZoomPan.Direction = 'in';
                hZoomPan.Enable = 'on';
            end
        end
        
        function zoomOutPreview(tool)
            zoom(tool.hPreviewFig,'off');
            pan(tool.hPreviewFig,'off');
            if tool.zoomOutButton.Value
                tool.zoomInButton.Value = false;
                tool.panButton.Value    = false;
                hZoomPan = zoom(tool.hPreviewFig);
                hZoomPan.Direction = 'out';
                hZoomPan.Enable = 'on';
            end
        end
        
        function panPreview(tool)
            pan(tool.hPreviewFig,'off');
            zoom(tool.hPreviewFig,'off');
            if tool.panButton.Value
                tool.zoomOutButton.Value = false;
                tool.zoomInButton.Value  = false;
                hZoomPan = pan(tool.hPreviewFig);
                hZoomPan.Enable = 'on';
            end
        end
        
        %% Preview
        function togglePreview(tool)
            if(tool.togglePreviewButton.Value)
                % Toggle on
                tool.hPreviewFig = figure('NumberTitle', 'off',...
                    'Name',getString(message('images:imageBrowser:Preview')),...
                    'Color','w',...
                    'Renderer','painters',...
                    'IntegerHandle','off',...
                    'Interruptible','off',...
                    'BusyAction','cancel',...
                    'Tag','PreviewFigure',...
                    'WindowKeyPressFcn',@tool.arrowKeyNavInPreview,...
                    'CloseRequestFcn',@(varargin)toggleOffPreview,...
                    'HandleVisibility','off');
                % Image index of currently shown image
                tool.hPreviewFig.UserData.imageNum = [];
                
                tool.ToolGroup.addFigure(tool.hPreviewFig);
                
                tool.hPreviewPanel = uipanel('Parent', tool.hPreviewFig,...
                    'BackgroundColor','w',...
                    'BorderType','none',...
                    'Tag','PreviewPanel',...
                    'Visible','off',...
                    'Units','pixels');
                
                tool.hPreviewLRButtons = uicontrol('style','pushbutton',...
                    'Parent',tool.hPreviewFig,...
                    'Units','pixels',...
                    'Visible','off',...
                    'Tag','PreviewLeftButton',...
                    'Tooltip',getString(message('images:imageBrowser:lrButtonToolTips')),...
                    'Callback',@(varargin)tool.goLeftInPreview,...
                    'Interruptible','off',...
                    'BusyAction','cancel',...
                    'CData', tool.LIconImage,...
                    'String','');
                tool.hPreviewLRButtons(2) = uicontrol('style','pushbutton',...
                    'Parent',tool.hPreviewFig,...
                    'Units','pixels',...
                    'Visible','off',...
                    'Tag','PreviewRightButton',...
                    'Tooltip',getString(message('images:imageBrowser:lrButtonToolTips')),...
                    'Callback',@(varargin)tool.goRightInPreview,...
                    'Interruptible','off',...
                    'BusyAction','cancel',...
                    'CData', tool.RIconImage,...
                    'String','');
                tool.hPreviewImageAxes = ...
                    iptui.internal.imshowWithCaption(tool.hPreviewPanel,...
                    false,'','im');
                tool.hPreviewImageAxes.Tag = 'ImageAxes';
                colormap(tool.hPreviewImageAxes, gray);                
                
                % Set this up after components have been created
                tool.hPreviewFig.SizeChangedFcn = @(varargin)tool.positionPreviewControls();
                
                tool.positionFigures();
                tool.updatePreview();
                
                tool.zoomInButton.Enabled       = true;
                tool.zoomOutButton.Enabled      = true;
                tool.panButton.Enabled          = true;
                
                % Ensure figure and components are created 
                tool.hPreviewPanel.Visible = 'on';
                drawnow;
            else
                % Toggle off
                toggleOffPreview();
            end
            
            function toggleOffPreview
                if ~isvalid(tool) % tool has closed
                    return;
                end
                
                delete(tool.hPreviewFig);
                
                % un 'bold' thumbnail, if multiselection bold was shown
                tool.hThumbnailComponent.unBold();
                
                tool.togglePreviewButton.Value = false;
                
                tool.zoomInButton.Value = false;
                tool.zoomOutButton.Value = false;
                tool.panButton.Value = false;
                
                tool.zoomInButton.Enabled = false;
                tool.zoomOutButton.Enabled = false;
                tool.panButton.Enabled = false;
                
                tool.positionFigures();
            end
            
        end
        
        function positionPreviewControls(tool)
            if ~isvalid(tool.hPreviewFig)
                % Skip callback when figure has already closed
                return;
            end
            
            % All units in pixels
            lowerMargin = 20;
            buttonWidth = 40;
            
            
            % Space for L/R buttons
            hCenter = tool.hPreviewFig.Position(3)/2;
            tool.hPreviewLRButtons(1).Position = [hCenter-(buttonWidth+buttonWidth/2) lowerMargin buttonWidth buttonWidth];
            tool.hPreviewLRButtons(2).Position = [hCenter+buttonWidth/2 lowerMargin buttonWidth buttonWidth];
            
            % Ensure positions are settled
            drawnow;
            % before updating image panel position
            leftrightMargin = 20;
            width  = max(1,tool.hPreviewFig.Position(3)-2*leftrightMargin);
            height = max(1, tool.hPreviewFig.Position(4)-buttonWidth-lowerMargin);
            tool.hPreviewPanel.Position = [leftrightMargin buttonWidth+lowerMargin ...
                 width height];
        end
        
        function updatePreview(tool)
            if ~tool.togglePreviewButton.Value ...
                    || isempty(tool.hPreviewFig) ...
                    || ~isvalid(tool.hPreviewFig) ...
                    || isempty(tool.hThumbnailComponent.CurrentSelection)
                % Nothing to do
                return;
            end
            tool.CurrentSelection = tool.hThumbnailComponent.CurrentSelection;
            
            
            tool.hPreviewFig.UserData.curSelection    = tool.CurrentSelection;
            % Show first in selection to begin with
            tool.selectionIndex  = 1;
            
            imageNum = tool.CurrentSelection(tool.selectionIndex);
            if ~isequal(tool.hPreviewFig.UserData.imageNum,imageNum)
                tool.showImageInPreview();
            end
            
            numSelections = numel(tool.CurrentSelection);
            if(numSelections>1)
                set(tool.hPreviewLRButtons,'Visible','on');
                tool.hThumbnailComponent.enBolden(imageNum);
            else
                set(tool.hPreviewLRButtons,'Visible','off');
            end
        end
        
        function showImageInPreview(tool)
            if isempty(tool.hPreviewFig) || isempty(tool.hPreviewImageAxes)
                return;
            end
            
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            
            % Show selectionIndex'th image of current selection
            imageNum = tool.CurrentSelection(tool.selectionIndex);
            tool.hPreviewFig.UserData.imageNum = imageNum;
            fullImage = tool.hThumbnailComponent.readFullImage(imageNum);
                        
            % Show file name as title
            sizeAndClass= ['[' num2str(size(fullImage)) '] ' class(fullImage)];
            fullPath = tool.hThumbnailComponent.getOneLineDescription(imageNum);
            [~, fname, ext] = fileparts(fullPath);
            titleString = [fname, ext, '  ', sizeAndClass];
            
            % Delete context menu (export to workspace)
            delete(findall(tool.hPreviewFig,'Type','uicontextmenu'));
            
            if tool.zoomInButton.Value|| tool.zoomOutButton.Value|| tool.panButton.Value
                % Recreate image axis (else reset to original wont work as
                % expected)
                delete(tool.hPreviewImageAxes);
                tool.hPreviewImageAxes = ...
                    iptui.internal.imshowWithCaption(tool.hPreviewPanel,...
                    fullImage,titleString,'im');
            else
                % Update image context in-place
                tool.hPreviewImageAxes.Children.CData = fullImage;
                tool.hPreviewImageAxes.XLim = [.5 size(fullImage,2)+.5];
                tool.hPreviewImageAxes.YLim = [.5 size(fullImage,1)+.5];
                if(islogical(fullImage))
                    tool.hPreviewImageAxes.CLim = [0 1];
                else
                    cLimMax = 255;
                    if ~isa(fullImage,'uint8')
                        % Scale
                        cLimMax = max(fullImage(:));
                    end
                    tool.hPreviewImageAxes.CLim = [0 cLimMax];
                end
                tool.hPreviewImageAxes.Title.String = titleString;
            end
            
            % Install new context menu
            hImage = tool.hPreviewImageAxes.Children;
            iptui.internal.installSaveToWorkSpaceContextMenu(hImage, titleString, 'im');
        end
        function arrowKeyNavInPreview(tool, ~, hEvent)
            switch hEvent.Key
                case 'uparrow'
                    tool.goLeftInPreview();
                case 'downarrow'
                    tool.goRightInPreview();
                otherwise
                    tool.arrowKeyCommon(hEvent);
            end
        end
        
        
        function positionFigures(tool)
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            hFig = tool.hPreviewFig;
            
            if ~isempty(hFig) && isvalid(hFig)
                % Set the initial tiling of the document area
                md.setDocumentArrangement(tool.ToolGroup.Name, md.TILED, java.awt.Dimension(2,1));
                loc = com.mathworks.widgets.desk.DTLocation.create(1);
                md.setClientLocation(hFig.Name, tool.ToolGroup.Name, loc);
                % Set the tiling again
                md.setDocumentArrangement(tool.ToolGroup.Name, md.TILED, java.awt.Dimension(2,1));
                % Make the first column wider for the main document
                md.setDocumentColumnWidths(tool.ToolGroup.Name, [0.5, 0.5]);
            else
                % only thumbnail, reset
                md.setDocumentArrangement(tool.ToolGroup.Name, md.TILED, java.awt.Dimension(1,1));
            end
            
        end
        
        function arrowKeyCommon(tool, hEvent)
            switch hEvent.Key
                case 'leftarrow'
                    tool.goLeftInPreview();
                case 'rightarrow'
                    tool.goRightInPreview();
                case 'home'
                    tool.selectionIndex = 1;
                    tool.showImageInPreview();
                case 'end'
                    tool.selectionIndex = numel(tool.CurrentSelection);
                    tool.showImageInPreview();
            end
        end
        
        function goLeftInPreview(tool)
            newIndex = tool.selectionIndex-1;
            if(newIndex>0)
                tool.selectionIndex = newIndex;
            else
                % Wrap over to end
                tool.selectionIndex = numel(tool.CurrentSelection);
            end
            tool.showImageInPreview();  
            % Ensure full preview update happens in callback (to ensure any
            % subsequent key presses are dropped if triggered while one
            % callback is already executing)
            drawnow; 
            imageNum = tool.CurrentSelection(tool.selectionIndex);            
            tool.hThumbnailComponent.enBolden(imageNum);
        end
        
        function goRightInPreview(tool)
            newIndex = tool.selectionIndex+1;
            if(newIndex>numel(tool.CurrentSelection))
                % Wrap to start
                tool.selectionIndex = 1;
            else
                tool.selectionIndex = newIndex;
            end
            tool.showImageInPreview();
            drawnow;
            imageNum = tool.CurrentSelection(tool.selectionIndex);            
            tool.hThumbnailComponent.enBolden(imageNum);
        end
        
        %% Thumbnail figures
        function hp = commonNewCollectionFigCreation(tool)
            tool.hThumbnailFig = figure('NumberTitle', 'off',...
                'Color','w',...
                'Visible','off',...
                'Renderer','painters',...
                'Name','Thumbnails',...  % changes later
                'IntegerHandle','off',...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'Tag','ThumbnailFigure',...
                'HandleVisibility','off');
            % Create figure before adding to toolgroup
            drawnow;
            tool.ToolGroup.addFigure(tool.hThumbnailFig);
            
            % Create thumbnail component
            hp = uipanel('Parent', tool.hThumbnailFig, ...
                'Units','Normalized','Position',[0 0 1 1],...
                'Tag','ThumbnailPanel',...
                'BorderType','none');
            
            % Prevent thumbnail figure from closing
            drawnow; % This is important: getClient calls fail without this.
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            prop= com.mathworks.widgets.desk.DTClientProperty.PERMIT_USER_CLOSE;
            state = java.lang.Boolean.FALSE;
            md.getClient(tool.hThumbnailFig.Name, tool.ToolGroup.Name).putClientProperty(prop, state);
            
            
            % Enable toolstrip
            tool.sizeSlider.Enabled             = true;
            tool.slideLabel.Enabled             = true;
            tool.togglePreviewButton.Enabled    = true;
            if(tool.togglePreviewButton.Value)
                tool.zoomInButton.Enabled           = true;
                tool.zoomOutButton.Enabled          = true;
                tool.panButton.Enabled              = true;
            else
                tool.zoomInButton.Value           = false;
                tool.zoomOutButton.Value          = false;
                tool.panButton.Value              = false;
                tool.zoomInButton.Enabled           = false;
                tool.zoomOutButton.Enabled          = false;
                tool.panButton.Enabled              = false;
            end
        end
        
        function commonNewCollectionFigPostSetup(tool, hThumbnailFig)                        
            addlistener(tool.hThumbnailComponent,'OpenSelection',@tool.openThumbnail);
            addlistener(tool.hThumbnailComponent,'SelectionChange',@tool.thumbnailSelectionChanged);
                        
            hThumbnailFig.WindowButtonDownFcn = @(varargin)tool.hThumbnailComponent.mouseButtonDownFcn(varargin{:});
            hThumbnailFig.WindowScrollWheelFcn = @(varargin)tool.hThumbnailComponent.mouseWheelFcn(varargin{:});
            hThumbnailFig.WindowKeyPressFcn = @(varargin)tool.hThumbnailComponent.keyPressFcn(varargin{:});
            
            hThumbnailFig.Visible = 'on';
            
            if tool.hThumbnailComponent.NumberOfThumbnails>1
                tool.hThumbnailComponent.setSelection(1);
            end
        end
        
        function newFileCollectionFig(tool, cName)
            hp = tool.commonNewCollectionFigCreation();
            tool.hThumbnailFig.Name = cName;
            
            tool.hThumbnailComponent = iptui.internal.imageBrowser.FileThumbnails(hp, tool.thumbnailSize);
                                    
            addlistener(tool.hThumbnailComponent, 'CountChanged', @(varargin)tool.numberOfThumbnailsChanged);
                        
            tool.commonNewCollectionFigPostSetup(tool.hThumbnailFig);
            tool.exportButton.Enabled           = true;
        end
        
        function numberOfThumbnailsChanged(tool)
            if(tool.hThumbnailComponent.NumberOfThumbnails==0)
                % Close thumbnail figure when all thumbnails are removed
                tool.deleteThumbnailFigure();
                delete(tool.hPreviewFig);
                tool.resetApp();
            else
                % Update name (currently only the folder based component
                % can change its count )
                tool.hThumbnailFig.Name = ...
                    [tool.hThumbnailFig.Tag,...
                    ' (',num2str(tool.hThumbnailComponent.NumberOfThumbnails),...
                    ' ', getString(message('images:imageBrowser:images')), ')'];
            end
                        
            if ~isempty(tool.hPreviewFig) &&  isvalid(tool.hPreviewFig)
                % Invalidate preview image number so it refreshes
                tool.hPreviewFig.UserData.imageNum = [];
            end
        end
        
        function newVarCollectionFig(tool, varName, var)
            if numel(var.Files)==0
                hw = warndlg(getString(message('images:imageBrowser:noImagesInImdsFoundDetail',varName)),...
                    getString(message('images:imageBatchProcessor:noImagesFound')),...
                    'modal');
                uiwait(hw);
                return;
            end
            
            hp = tool.commonNewCollectionFigCreation();                        
            tool.hThumbnailComponent =...
                iptui.internal.imageBrowser.ImageDatastoreThumbnails(...
                hp, tool.thumbnailSize, var);
            tool.hThumbnailFig.Name = ...
                [varName, ...
                ' (imageDatastore, ',num2str(tool.hThumbnailComponent.NumberOfThumbnails),...
                ' ',getString(message('images:imageBrowser:images')), ')'];                            
            tool.hThumbnailFig.Tag = varName;
            
            tool.commonNewCollectionFigPostSetup(tool.hThumbnailFig);
            % No 'export' from variables
            tool.exportButton.Enabled           = false;
            
            tool.setNotificationMessage(getString(...
                message('images:imageBrowser:loadedN',...
                tool.hThumbnailComponent.NumberOfThumbnails)));
        end
        
        function resetApp(tool)
            if isvalid(tool.hPreviewFig)
                delete(tool.hPreviewFig);
            end
            tool.hThumbnailFig = [];
            
            % Disable toolstrip
            tool.sizeSlider.Enabled             = false;            
            tool.slideLabel.Enabled             = false;
            
            tool.togglePreviewButton.Value  = false;
            tool.zoomInButton.Value         = false;
            tool.zoomOutButton.Value        = false;
            tool.panButton.Value            = false;
            
            tool.togglePreviewButton.Enabled    = false;
            tool.zoomInButton.Enabled           = false;
            tool.zoomOutButton.Enabled          = false;
            tool.panButton.Enabled              = false;
            
            tool.galleryItems.imtoolItem.Enabled      = false;
            tool.galleryItems.colorThreshItem.Enabled = false;
            tool.galleryItems.segItem.Enabled         = false;
            tool.galleryItems.regionAnalyItem.Enabled = false;
            
            
            tool.exportButton.Enabled           = false;
            
            tool.setStatus(getString(message('images:imageBrowser:clickLoad')));
        end
        
        %% Thumbnails
        function openThumbnail(tool, ~, ~)
            if isempty(tool.hPreviewFig) || ~isvalid(tool.hPreviewFig)
                % Programmatically toggle on preview
                tool.togglePreviewButton.Value = true;
                tool.togglePreview();
            else
                tool.updatePreview();
            end                        
        end
        
        function thumbnailSelectionChanged(tool, ~, ~)
            tool.galleryItems.imtoolItem.Enabled = false;
            tool.galleryItems.colorThreshItem.Enabled = false;
            tool.galleryItems.segItem.Enabled = false;
            tool.galleryItems.regionAnalyItem.Enabled = false;
            
            if(nargin==1)
                hFig = tool.getActiveThumbnailFigure();
                if isempty(hFig) || ~isvalid(hFig)
                    return;
                end
            end
            
            if numel(tool.hThumbnailComponent.CurrentSelection)>1
                tool.setStatus(getString(message('images:imageBrowser:selectedN',num2str(numel(tool.hThumbnailComponent.CurrentSelection)))));
            elseif numel(tool.hThumbnailComponent.CurrentSelection)==1
                % Single selection
                
                % Remove the 'bold' from any image (if multiple thumbnails
                % were selected previously and preview was open)
                tool.hThumbnailComponent.unBold();
                
                tool.setStatus(tool.hThumbnailComponent.getOneLineDescription(tool.hThumbnailComponent.CurrentSelection));
                
                tnMeta = tool.hThumbnailComponent.getBasicMetaDataFromThumbnail(tool.hThumbnailComponent.CurrentSelection);
                                
                if ~isempty(tnMeta) && ~tnMeta.isPlaceholder && ~tnMeta.isStack
                    tool.galleryItems.imtoolItem.Enabled = true;
                    if strcmp(tnMeta.class,'logical')
                        tool.galleryItems.regionAnalyItem.Enabled = true;
                        tool.galleryItems.segItem.Enabled         = false;
                    else
                        tool.galleryItems.regionAnalyItem.Enabled = false;
                        tool.galleryItems.segItem.Enabled         = true;
                    end
                    if numel(tnMeta.size)==3 && tnMeta.size(3)==3
                        % assume rgb
                        tool.galleryItems.colorThreshItem.Enabled = true;
                    else
                        tool.galleryItems.colorThreshItem.Enabled = false;
                    end
                end
            end
            
            tool.updatePreview();
        end
        
        %% Launchers
        function launchImtool(tool)
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            hFig = tool.hThumbnailFig;
            if isempty(hFig) || ~isvalid(hFig)
                return;
            end
            im = tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            imtool(im);
        end
        
        function launchColorThresh(tool, varargin)
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            hFig = tool.hThumbnailFig;
            if isempty(hFig) || ~isvalid(hFig)
                return;
            end
            im = tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            colorThresholder(im);
        end
        
        function launchSegApp(tool, varargin)
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            hFig = tool.hThumbnailFig;
            if isempty(hFig) || ~isvalid(hFig)
                return;
            end
            im = tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            s = warning('off','images:imageSegmenter:convertToGray');
            restoreWarningStateObj = onCleanup(@()warning(s));
            imageSegmenter(im);
        end
        
        function launchRegionApp(tool, varargin)
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            hFig = tool.hThumbnailFig;
            if isempty(hFig) || ~isvalid(hFig)
                return;
            end
            im = tool.hThumbnailComponent.readFullImage(tool.hThumbnailComponent.CurrentSelection(1));
            imageRegionAnalyzer(im);
        end
        
        %% Export
        function exportToDataStore(tool)
            tool.showAsBusy;
            unlockWhenDone = onCleanup(@()tool.unshowAsBusy);
            hFig = tool.hThumbnailFig;
            if isempty(hFig) || ~isvalid(hFig)
                return;
            end
            defaultVarName = matlab.lang.makeValidName(hFig.Tag);
            % Export all
            export2wsdlg({[getString(message('images:imageBrowser:exportAllTooltip')) ,':']},...
                {defaultVarName},...
                {tool.hThumbnailComponent.imds});
        end
        
        %% App status
        function showAsBusy(tool)
            tool.ToolGroup.setWaiting(true);
        end
        
        function unshowAsBusy(tool)
            tool.ToolGroup.setWaiting(false)
        end
        
        %% Status bar
        function setStatus(tool, text)
            tool.statusText = text;
            if(isempty(tool.notificationTimer) ||...
                    strcmp(tool.notificationTimer.Running,'off'))
                md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
                f = md.getFrameContainingGroup(tool.ToolGroup.Name);
                if ~isempty(f)
                    % Check to ensure app is not closing
                    javaMethodEDT('setStatusText', f, text);
                end
            end
        end
        
        function setNotificationMessage(tool, text)
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f = md.getFrameContainingGroup(tool.ToolGroup.Name);
            javaMethodEDT('setStatusText', f, text);
            % Reset to status after notification time
            if(isempty(tool.notificationTimer))
                tool.notificationTimer = timer(...
                    'ExecutionMode','singleShot',...
                    'StartDelay',3,...
                    'TimerFcn',@(varargin)tool.resetStatusText);
            end
            stop(tool.notificationTimer);
            start(tool.notificationTimer);
        end
        
        function resetStatusText(tool)
            md = com.mathworks.mlservices.MatlabDesktopServices.getDesktop;
            f = md.getFrameContainingGroup(tool.ToolGroup.Name);
            javaMethodEDT('setStatusText', f, tool.statusText);
        end
        
        %%
        function delete(tool)            
            if ~isempty(tool.notificationTimer) && isvalid(tool.notificationTimer)
                stop(tool.notificationTimer)
            end
            delete(tool.notificationTimer);
            
            if ~isempty(tool.ToolGroup) && isvalid(tool.ToolGroup)
                delete(tool.ToolGroup);
            end
        end
        
        function deleteThumbnailFigure(tool)
            delete(tool.hThumbnailComponent);
            delete(tool.hThumbnailFig);
        end
        
        function closeCallback(tool, hEvent)
            ET = hEvent.EventData.EventType;
            if strcmp(ET, 'CLOSING')
                drawnow; % flush all events/callbacks
                tool.ToolGroup.approveClose();
                tool.deleteThumbnailFigure();
                delete(tool.hPreviewFig);                
                delete(tool);
            end
        end
    end
    
end
