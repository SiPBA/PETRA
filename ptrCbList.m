function ptrCbList(hObject, eventdata, action, varargin)
    func = eval(['@' action]);
    ptrData = guidata (hObject);
    if ~isempty(eventdata) varargin = {varargin{:} eventdata}; end
    func (hObject, ptrData, varargin{:});
end


function mainSlider (hObject, ptrData, varargin)
    val = get(hObject,'Value');
    
    posMain = get(ptrData.handles.mainPanel.hPanel, 'Position');
    pos = get(ptrData.handles.mainPanel.volsPanel, 'Position');

    pos(2) = (posMain(4) - pos(4)) * val;
    set(ptrData.handles.mainPanel.volsPanel, 'Position', pos);
    
    %Repaint axes to address Matlab's bug
    if ptrData.params.bugNestedPanels
        nVols = numel(ptrData.handles.mainPanel.volPanel);
        for i=1:nVols
            for j=1:3
                h = ptrData.handles.mainPanel.volPanel(i).slAxes(j);
                set(h,'ZTickLabel','');
            end
        end
    end
    
    drawnow;
end


function adjustSlider (hObject, ptrData, varargin)
    if ~isfield(ptrData.handles.mainPanel,'volsPanel'), return, end

    posMP = get (ptrData.handles.mainPanel.hPanel,'Position');
    posVP = get (ptrData.handles.mainPanel.volsPanel,'Position');
    posVP1 = get (ptrData.handles.mainPanel.volPanel(1).hPanel,'Position');
    diffPn = posVP(4) - posMP(4);
    
    step = min((posVP1(4)+10) / max(diffPn,1), 1);
    if diffPn > 0, enable = 'on'; else enable = 'off'; end
    
    set (ptrData.handles.mainPanel.volsPanelSlider, ...
        'Enable', enable, 'SliderStep', [step/4 step]);
end


function scroll (hObject, ptrData, varargin)
    ev = varargin{1};
    p = get (ptrData.handles.mainPanel.volsPanelSlider, ...
        {'Max', 'Min', 'SliderStep', 'Value', 'Enable'});
    if strcmp(p{5},'on')
        val = p{4} + (ev.VerticalScrollCount * ev.VerticalScrollAmount) ...
            * -p{3}(1);
        val = max(min(val, p{1}), p{2});

        set (ptrData.handles.mainPanel.volsPanelSlider, 'Value', val);
        mainSlider (ptrData.handles.mainPanel.volsPanelSlider, ptrData);
    end
end


function setSlices (hObject, ptrData, varargin)
    i = varargin{1};
    j = varargin{2};
    
    h = ptrData.handles.mainPanel.volPanel(i);
    pto = get(h.slAxes(j),'CurrentPoint');
    h.sliceIdx (mod(j-2*(j~=2),3)+1) = round(pto(1,1));
    h.sliceIdx (mod(j-2*(j==2),3)+1) = round(pto(1,2));
    ptrData.handles.mainPanel.volPanel(i) = h;

    guidata (hObject, ptrData);
    drawSlices (hObject, ptrData, i);
end


function drawSlices (hObject, ptrData, varargin)
    i = varargin{1};
    h = ptrData.handles.mainPanel.volPanel(i);
    for j = 1:3
        slIdx = min(h.sliceIdx(j),size(ptrData.images(i).volume,j));
        if j==1,     sl = squeeze(ptrData.images(i).volume(slIdx,:,:));
        elseif j==2, sl = squeeze(ptrData.images(i).volume(:,slIdx,:));
        elseif j==3, sl = squeeze(ptrData.images(i).volume(:,:,slIdx));
        end
        
        % Set slice
        set(h.slImage(j),'CData',sl, ...
                         'XData',[1 size(sl,2)],'YData',[1 size(sl,1)]);
        set(h.slAxes(j),'XLim',[1 size(sl,2)],'YLim',[1 size(sl,1)]);
        
        % Set crosshair
        pto = h.sliceIdx(mod(j-2*(j==2),3)+1);
        set(h.slLineH(j), 'XData', [2 size(sl,2)],'YData', [pto pto]);
        pto = h.sliceIdx(mod(j-2*(j~=2),3)+1);
        set(h.slLineV(j), 'XData', [pto pto],'YData', [2 size(sl,1)]);
    end
end


function changeColormap (hObject, ptrData, varargin)
    for i=1:numel(ptrData.images)
        for j=1:3
            h = ptrData.handles.mainPanel.volPanel(i).slPanel(j);
            set (h,'BackgroundColor', ptrData.params.colormap(1,:));
        end
    end
end


function updateData (hObject, ptrData, varargin)
    field = varargin{1};
    img = varargin{2};
    switch field
    case 'name'
        for i=img(:)'
            h = ptrData.handles.mainPanel.volPanel(i).nameTxt;
            set (h, 'String', ptrData.images(i).fileName);
        end
    case 'class'
        for i=img(:)'
            h = ptrData.handles.mainPanel.volPanel(i).classTxt;
            set (h, 'String', ptrData.images(i).class);
        end
    case 'check'
        for i=img(:)'
            h = ptrData.handles.mainPanel.volPanel(i).selCheck;
            set (h, 'Value', ptrData.images(i).selected);
        end
    case 'slices'
        for i=img(:)'
            ptrStatusBar(hObject,'updateProgress', i/numel(img), ...
                '$main_CreatingUI');
            ptrCbList(hObject, [], 'drawSlices', i); 
        end
    end

end


function changeWindowSize (hObject, ptrData, varargin)
    diff = varargin{1};
    
    % Main panel
    pos = get (ptrData.handles.mainPanel.hPanel,'Position');
    pos(3:4) = pos(3:4) - diff;
    set (ptrData.handles.mainPanel.hPanel,'Position',pos);
    
    % Vols panel
    pos = get (ptrData.handles.mainPanel.volsPanel,'Position');
    pos(1) = pos(1) - (diff(1)/2);
    pos(2) = pos(2) - diff(2);
    set (ptrData.handles.mainPanel.volsPanel,'Position',pos);
    
    % Determines the number of columns for new window size
    mainWinSize = [ptrData.params.mainWinSize(1), ...
         ptrData.params.mainWinSize(2) - ptrData.params.statusBarHeight];
    p = ptrData.params.listView;
    volsColumns = max(floor((mainWinSize(1)-20-p.volPanelMarginW) / ...
        (p.volPanelW + p.volPanelMarginW)),1);
    
    % If there should be more or less columns, reallocate vol panels
    if  volsColumns ~= p.volsColumns
        nVols = numel(ptrData.handles.mainPanel.volPanel);
        volsRows = max(ceil(nVols / volsColumns),1);

        % Stores the new number of row and columns
        ptrData.params.listView.volsColumns = volsColumns;
        ptrData.params.listView.volsRows = volsRows;
        guidata (hObject, ptrData);
        
        % Adjust postion and size of container panel
        volsPanelW = p.volPanelMarginW + ...
            volsColumns * (p.volPanelW + p.volPanelMarginW);
        volsPanelH = p.volPanelMarginH + ...
            volsRows * (p.volPanelH + p.volPanelMarginH);
        pos = [(mainWinSize(1)-volsPanelW-20)/2 ...
                mainWinSize(2)-volsPanelH, ...
                volsPanelW, volsPanelH];
        set (ptrData.handles.mainPanel.volsPanel,'Position',pos);

        % Reallocate the panel of each volume
        for i=1:nVols
            iRow = ceil(i/volsColumns);
            iCol = mod(i-1,volsColumns)+1;
            pos = get (ptrData.handles.mainPanel.volPanel(i).hPanel,...
                'Position');
            pos(1) = p.volPanelMarginW + ...
                (p.volPanelW + p.volPanelMarginW) * (iCol-1);
            pos(2) = p.volPanelMarginH + ...
                (p.volPanelH + p.volPanelMarginH) * (volsRows-iRow);
            set (ptrData.handles.mainPanel.volPanel(i).hPanel,...
                'Position',pos);
        end
    end
    
    % Slider
    pos = get (ptrData.handles.mainPanel.volsPanelSlider,'Position');
    pos([1 4]) = pos([1 4]) - diff;
    set (ptrData.handles.mainPanel.volsPanelSlider,'Position',pos);
    adjustSlider(hObject, ptrData, varargin);
    
end


