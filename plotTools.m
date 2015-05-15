function plotTools (action, hBtn)
    fcn = str2func(action);
    releaseBtn(get(hBtn,'Parent'), hBtn);
    fcn(hBtn);
end

function releaseBtn(hPn, hBtn)
    hs = findobj(hPn,'Style','togglebutton')';
    for h = hs
        if h==hBtn, continue, end
        userData = get(h, 'UserData');
        if isfield(userData, 'releaseMe') && userData.releaseMe
            set(h, 'Value', get(h,'Min'));
        end
    end
end

function zoomMas(hObject)
    h = zoom;
    button_state = get(hObject,'Value');
    if button_state == get(hObject,'Max')
        set(h,'Enable','on');
        set(h,'Direction','in');
        set(hObject,'UserData',struct('releaseMe',true));
    elseif button_state == get(hObject,'Min')
        set(h,'Enable','off');
        set(hObject,'UserData',struct('releaseMe',false));
    end
end
    
function zoomReset(hObject)
    zoom out
    set(zoom,'Enable','off');
end

function zoomMenos(hObject)
    h = zoom;
    button_state = get(hObject,'Value');
    if button_state == get(hObject,'Max')
        set(h,'Enable','on');
        set(h,'Direction','out');
        set(hObject,'UserData',struct('releaseMe',true));
    elseif button_state == get(hObject,'Min')
        set(hObject,'UserData',struct('releaseMe',false));
        set(h,'Enable','off');
    end
end

function hand(hObject)
    if get(hObject,'Value') == get(hObject,'Max')
        set(hObject,'UserData',struct('releaseMe',true));
        pan on
    else
        set(hObject,'UserData',struct('releaseMe',false));
        pan off
    end
end

function rotate(hObject)
    if get(hObject,'Value') == get(hObject,'Max')
        set(hObject,'UserData',struct('releaseMe',true));
        rotate3d on
    else
        set(hObject,'UserData',struct('releaseMe',false));
        rotate3d off
    end
end


