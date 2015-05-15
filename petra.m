%
% PETRA is copyrighted software. Please read file licence.txt
%
function petra

    % Load params
    ptrData.params = ptrParamsLoad();
    
    % Set variables for controling the display
    ptrData.current.img = 1;   % Show first loaded image by default
    ptrData.current.view = 1;  % View axial by default
    ptrData.current.slice = 0.5; % Show midle slice by default
    ptrData.current.sliceMode = 'one'; % Show slices one by one by default
    
    % Add itself to path
    addpath (ptrData.params.pathMain);
    
    % Create figure
    ptrData.handles.win = figure('Visible','off','CloseRequestFcn', @closePetra);
    guidata (ptrData.handles.win, ptrData)
    
    % Create main window (menu bar, status bar, etc)
    ptrDsMainWindow(ptrData.handles.win);
	set(ptrData.handles.win, 'Visible','on')
end


function closePetra(hObject, evendata)
    ptrData = guidata(hObject);
    
    % Save options
    ptrParamsUnload(ptrData.params);
    
    % Delete figure
    delete (ptrData.handles.win);
end

