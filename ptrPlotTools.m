function ptrPlotTools (hObject, eventdata, action, varargin)
    fcn = str2func(action);
    releaseBtn(hObject);
    fcn(hObject, varargin{:});
end

function enable(hObject, varargin)
    hs = findobj(hObject,'Tag','Toolbar.ImageTool');
    for i=1:numel(hs), set (hs(i), 'Visible', varargin{1}); end
end

function releaseBtn(hBtn)
    hPn = get(hBtn, 'Parent');
    hs = findobj(hPn,'State','on','Tag','Toolbar.ImageTool');
    hs = setdiff(hs, hBtn);
    for i=1:numel(hs)
        set (hs(i), 'State','off');
    end
end

function zoomIn(hObject)
    h = zoom;
    set(h,'Direction','in');
    set(h,'Enable',get(hObject,'State'));
end
    
function zoomReset(hObject)
    zoom out
    set(zoom,'Enable','off');
    pan ('off');
end

function zoomOut(hObject)
    h = zoom;
    set(h,'Direction','out');
    set(h,'Enable',get(hObject,'State'));
end

function hand(hObject)
    pan(get(hObject,'State'));
end

function rotate(hObject)
    rotate3d(get(hObject,'State'));
end


