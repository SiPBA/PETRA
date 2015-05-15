
function ptrSetMainPanel(ptrData)

    set(ptrData.handles.win,'Pointer','watch')
    ptrStatusBar(ptrData.handles.win, 'updateProgress', -1, '$main_CreatingUI');
    
    % Delete previous panel (if exists)
    if isfield(ptrData, 'handles') && ...
       isfield(ptrData.handles, 'mainPanel') && ...
       isfield(ptrData.handles.mainPanel, 'hPanel') && ...
       ishandle(ptrData.handles.mainPanel.hPanel)
   
        delete(ptrData.handles.mainPanel.hPanel);
    end
    
    % Create new panel (if there are images)
    if isfield(ptrData, 'images') && numel(ptrData.images) > 0
        fcn = ptrData.params.displayModeFcn{ptrData.params.displayMode};
        feval (fcn, ptrData.handles.win);
    end
    
    ptrStatusBar(ptrData.handles.win, 'updateTxt');
    set(ptrData.handles.win,'Pointer','arrow')
end