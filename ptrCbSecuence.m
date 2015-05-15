function ptrCbSecuence(hObject, eventdata, action, varargin)
    func = eval(['@' action]);
    ptrData = guidata (hObject);
    func (hObject, ptrData, varargin{:});
end


function refreshImage (hObject, ptrData, varargin)
    if ~isfield(ptrData, 'images') || numel(ptrData.images)<1, return, end
    
    volume = ptrData.images(ptrData.current.img).volume;
    if strcmp (ptrData.current.sliceMode, 'all')
        if ptrData.current.view == 1,
            for i=1:size(volume,1), im(:,:,1,i)=squeeze(volume(i,:,:)); end
        elseif ptrData.current.view == 2,
            for i=1:size(volume,2), im(:,:,1,i)=squeeze(volume(:,i,:)); end
        else
            for i=1:size(volume,3), im(:,:,1,i)=squeeze(volume(:,:,i)); end
        end
        montage(im);
    else
        maxSlice = size(volume, ptrData.current.view);
        slice = round(ptrData.current.slice * (maxSlice-1)) + 1;

        if ptrData.current.view == 1,
            sl = squeeze(volume(slice,:,:));
        elseif ptrData.current.view == 2,
            sl = squeeze(volume(:,slice,:));
        else
            sl = squeeze(volume(:,:,slice));
        end

        imshow(sl,'Parent', ptrData.handles.mainPanel.axes)
        set(ptrData.handles.mainPanel.axes, 'DataAspectRatio',[1 1 1], ...
                          'DataAspectRatioMode', 'manual');
        axis off

        set (ptrData.handles.mainPanel.buttonsBar.sliderSlice, 'SliderStep', ...
                [1/maxSlice min(1, 10/maxSlice)]);
        set (ptrData.handles.mainPanel.buttonsBar.txtSliceIdx, 'String', ...
                [num2str(slice) '/' num2str(maxSlice) ' ']);
    end

    set (ptrData.handles.mainPanel.buttonsBar.txtImg, 'String', ...
            num2str(ptrData.current.img));
    set (ptrData.handles.mainPanel.buttonsBar.selCheck, 'Value', ...
            ptrData.images(ptrData.current.img).selected);
    colormap (ptrData.params.colormap);
end


function changeImage (hObject, ptrData, varargin)
    if ~isfield(ptrData, 'images') || numel(ptrData.images)<1, return, end
    
    inc = varargin{1};
    num = numel(ptrData.images);
    ptrData.current.img = mod (ptrData.current.img - 1 + inc, ...
        numel(ptrData.images)) + 1;
    guidata (hObject, ptrData);
    refreshImage (hObject, ptrData);
end


function changeView (hObject, ptrData, varargin)
    h = ptrData.handles.mainPanel.buttonsBar.cbSliceView;
    ptrData.current.view = get (h, 'Value');
    guidata (hObject, ptrData);
    refreshImage (hObject, ptrData);
end


function changeColormap (hObject, ptrData, varargin)
    set (ptrData.handles.mainPanel.imgPanel, 'BackgroundColor', ...
        ptrData.params.colormap(1,:));
end


function changeSlice (hObject, ptrData, varargin)
    h = ptrData.handles.mainPanel.buttonsBar.sliderSlice;
    v = get(ptrData.handles.mainPanel.buttonsBar.sliderSlice, 'Value');
    ptrData.current.slice = v;
    guidata (hObject, ptrData);
    refreshImage (hObject, ptrData);
end


function changeSliceMode (hObject, ptrData, varargin)
    mode = get (hObject,'Value');
    userData = get(hObject,'UserData');
    hs = findobj(get(hObject,'Parent'),'Tag','ButtonPanel.SliceControl');
    
    if mode == get (hObject, 'Min')
        for i=1:numel(hs), set (hs(i), 'Visible', 'on'); end
        set (hObject,'CData',userData{2});
        ptrData.current.sliceMode = 'one';
    else
        for i=1:numel(hs), set (hs(i), 'Visible', 'off'); end
        set (hObject,'CData',userData{1});
        ptrData.current.sliceMode = 'all';
    end
    guidata (hObject, ptrData);
    refreshImage (hObject, ptrData);
end


function playSlices (hObject, ptrData, varargin)
    play = (get(hObject,'Value') == get(hObject,'Max'));
    userData = get(hObject,'UserData');
    set(hObject,'CData',userData{~play+1});
    
    if play
        hPanel = get(hObject,'Parent');
        hs = [findobj(hPanel,'Style','pushbutton'); ...
              findobj(hPanel,'Style','togglebutton'); ...
              findobj(hPanel,'Style','checkbox'); ...
              findobj(hPanel,'Style','slider'); ...
              findobj(hPanel,'Style','popupmenu')];
        hs = setdiff(hs, hObject);
        for h=hs', set(h,'Enable','inactive'); end
        hSlider = ptrData.handles.mainPanel.buttonsBar.sliderSlice;

        while (1)
            try
            val = get(hSlider, {'Value','SliderStep','Max','Min'});
            slice = val{1} + val{2}(1);
            if slice > val{3}, slice = val{4}; end
            ptrData.current.slice = slice;
            set (hSlider, 'Value', slice);
            
            refreshImage (hObject, ptrData);
            pause(0.1);
            if (get(hObject,'Value') == get(hObject,'Min')), break, end
            catch e
            end
        end
        guidata (hObject,ptrData);
        for h=hs', set(h,'Enable','on'); end
    end
        
end


function updateData (hObject, ptrData, varargin)
    field = varargin{1};
    img = varargin{2};
    if isempty(find(img==ptrData.current.img, 1)), return, end
        
    switch field
    case 'check'
        h = ptrData.handles.mainPanel.buttonsBar.selCheck;
        set (h, 'Value', ptrData.images(ptrData.current.img).selected);
    case 'slices'
        refreshImage (hObject, ptrData);
    end

end


function changeWindowSize (hObject, ptrData, varargin)
    ptrSetMainPanel(ptrData)
end
