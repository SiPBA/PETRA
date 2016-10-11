function ptrCbGrid(hObject, eventdata, action, varargin)
    func = eval(['@' action]);
    ptrData = guidata (hObject);
    func (hObject, ptrData, varargin{:});
end

function refreshImage (hObject, ptrData, varargin)
    if ~isfield(ptrData, 'images') || numel(ptrData.images)<1, return, end

    nVols = numel(ptrData.images);
    sizes = zeros(nVols, 3);
    for i=1:nVols, sizes(i,:) = size(ptrData.images(i).volume); end
    maxSize = max(sizes,[],1);
    
    maxSlice = maxSize(ptrData.current.view);
    slice = round(ptrData.current.slice * (maxSlice-1)) + 1;

    slSize = maxSize(setdiff(1:3,ptrData.current.view));
    vol = zeros ([slSize 1 nVols]);
    for i=1:nVols
        if slice > sizes(i, ptrData.current.view)
            continue;
        elseif ptrData.current.view == 1,
            sl = squeeze(ptrData.images(i).volume(slice,:,:));
        elseif ptrData.current.view == 2,
            sl = squeeze(ptrData.images(i).volume(:,slice,:));
        else
            sl = squeeze(ptrData.images(i).volume(:,:,slice));
        end

        vol(1:size(sl,1),1:size(sl,2),1,i) = sl;
    end
    
    if nVols==1, mSize = [1,1]; else mSize = [NaN, NaN]; end
    axes(ptrData.handles.mainPanel.axes);
    montage(vol, 'Size', mSize);
    colormap (ptrData.params.colormap);
    
    set (ptrData.handles.mainPanel.buttonsBar.sliderSlice, 'SliderStep', ...
            [1/maxSlice min(1, 10/maxSlice)]);
    set (ptrData.handles.mainPanel.buttonsBar.txtSliceIdx, 'String', ...
            [num2str(slice) '/' num2str(maxSlice) ' ']);
end

function changeView (hObject, ptrData, varargin)
    h = ptrData.handles.mainPanel.buttonsBar.cbSliceView;
    ptrData.current.view = get (h, 'Value');
    guidata (hObject, ptrData);
    refreshImage (hObject, ptrData);
end


function changeColormap (hObject, ptrData, varargin)
    set (ptrData.handles.mainPanel.gridPanel, 'BackgroundColor', ...
        ptrData.params.colormap(1,:));
end


function changeSlice (hObject, ptrData, varargin)
    h = ptrData.handles.mainPanel.buttonsBar.sliderSlice;
    v = get(ptrData.handles.mainPanel.buttonsBar.sliderSlice, 'Value');
    ptrData.current.slice = v;
    guidata (hObject, ptrData);
    refreshImage (hObject, ptrData);
end


function changeWindowSize (hObject, ptrData, varargin)
    ptrSetMainPanel(ptrData)
end





