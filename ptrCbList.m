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
        {'Max', 'Min', 'SliderStep', 'Value'});
    val = p{4} + (ev.VerticalScrollCount * ev.VerticalScrollAmount) * -p{3}(1);
    val = max(min(val, p{1}), p{2});

    set (ptrData.handles.mainPanel.volsPanelSlider, 'Value', val);
    mainSlider (ptrData.handles.mainPanel.volsPanelSlider, ptrData);
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
    for j = 1:3
        volume = ptrData.images(i).volume;
        h = ptrData.handles.mainPanel.volPanel(i);

        slIdx = h.sliceIdx(j);
        if j==1, sl = squeeze(volume(slIdx,:,:));
        elseif j==2, sl = squeeze(volume(:,slIdx,:));
        elseif j==3, sl = squeeze(volume(:,:,slIdx));
        end

        % Show slice
        set(h.slAxes(j),'NextPlot','replace');
        h.slImage(j) = ...
            imshow(sl,'Parent', h.slAxes(j));
        set(h.slImage(j), 'ButtonDownFcn', ...
            {'ptrCbList', 'setSlices',i,j});
        set(h.slAxes(j),...
            'DataAspectRatio',[1 1 1], ...
            'NextPlot', 'add');
        colormap (ptrData.params.colormap);

        % Show crosshair
        pto = h.sliceIdx(mod(j-2*(j==2),3)+1);
        plot(h.slAxes(j),[1 size(sl,2)],[pto pto],'w');
        pto = h.sliceIdx(mod(j-2*(j~=2),3)+1);
        plot(h.slAxes(j),[pto pto],[1 size(sl,1)],'w');
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
    pos([3 2]) = pos([3 2]) - diff;
    set (ptrData.handles.mainPanel.volsPanel,'Position',pos);

    % Slider
    pos = get (ptrData.handles.mainPanel.volsPanelSlider,'Position');
    pos([1 4]) = pos([1 4]) - diff;
    set (ptrData.handles.mainPanel.volsPanelSlider,'Position',pos);
    adjustSlider(hObject, ptrData, varargin);
    
    % All vol panels
    num = numel(ptrData.handles.mainPanel.volPanel);
    for i=1:num
        pos = get (ptrData.handles.mainPanel.volPanel(i).hPanel,'Position');
        pos([1]) = pos([1]) - diff(1)/2;
        set (ptrData.handles.mainPanel.volPanel(i).hPanel,'Position',pos);
        for j=1:3
            pos = get (ptrData.handles.mainPanel.volPanel(i).slAxes(j),'Position');
            pos([1]) = pos([1]) - diff(1)/2;
            set (ptrData.handles.mainPanel.volPanel(i).slAxes(j),'Position',pos);
        end
    end
end


