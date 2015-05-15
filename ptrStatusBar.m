
function ptrStatusBar(hObject, action, varargin)
    func = eval(['@' action]);
    ptrData = guidata (hObject);
    func (hObject, ptrData, varargin{:});
end


function create (hObject, ptrData, varargin)
    pos = [0, 0, ptrData.params.mainWinSize(1) ptrData.params.statusBarHeight];
    bgColor = [0.83 0.83 0.83];
    
    % Main panel
    statusBar.statusBar = uipanel('Parent',ptrData.handles.win, ...
            'Units','Pixels', ...
            'Position',pos, ...
            'BorderType', 'none');

    % Line (top of statusbar)
    statusBar.line = uicontrol('Parent', statusBar.statusBar,...
            'Units','Normalized', ...
            'Style','text', ...
            'Position', [0 0.9 1 0.1],...
            'BackgroundColor', [1 1 1]);
        
    % Background
    statusBar.bg = uicontrol('Parent', statusBar.statusBar,...
            'Units','Normalized', ...
            'Style','text', ...
            'BackgroundColor', bgColor, ...
            'Position', [0 0 1 0.9]);
        
    % Text
    statusBar.text = uicontrol('Parent', statusBar.statusBar,...
            'Style', 'text', ...
            'Units', 'normalized', ...
            'Position', [0.01 0.1 0.79 0.65], ...
            'HorizontalAlignment','left', ...
            'BackgroundColor', bgColor, ...
            'String', '');
   
    % Progress bar
    statusBar.progressBar = uicontrol( ...
            'Parent',statusBar.statusBar, ...
            'Style', 'text', ...
            'Units','normalized', ...
            'Position', [0.80 0.2 0.19 0.6], ...
            'Visible','off', ...
            'BackgroundColor', [0 0 1]);

    statusBar.progressBarBg = uicontrol( ...
            'Parent',statusBar.statusBar, ...
            'Style', 'text', ...
            'Units','normalized', ...
            'Position', [0.80 0.2 0.19 0.6], ...
            'Visible','off', ...
            'BackgroundColor', [1 1 1]);
        
    ptrData.handles.statusBar = statusBar;
    guidata(hObject, ptrData);
    
    updateTxt (hObject, ptrData, varargin{:});
end


function updateTxt (hObject, ptrData, varargin)
    n = 0; sel = 0;
    if isfield(ptrData, 'images'), 
        n = numel(ptrData.images);
        for i=1:n, if ptrData.images(i).selected, sel = sel+1; end, end
    end
    
    txt = '';
    if n>0, txt = [' ' ptrLgGetString('statusBar_Images') ': ' num2str(n)]; end
    if sel>0,
        sufix = ptrLgGetString('statusBar_Selected');
        txt = [txt ' (' num2str(sel) ' ' sufix ')'];
    end
    
    if isfield(ptrData, 'train')
        if ~isempty(txt), txt = [txt '   ']; end
        txt = [txt ptrLgGetString('statusBar_Train') ': ' ...
               ptrData.train.name];
    end
    
    set(ptrData.handles.statusBar.progressBar, 'Visible', 'off');
    set(ptrData.handles.statusBar.progressBarBg, 'Visible', 'off');
    set(ptrData.handles.statusBar.text,'String',txt);
    drawnow
end


function updateProgress (hObject, ptrData, varargin)
    if numel(varargin)>0, pct = varargin{1}; else pct = -1; end
    if numel(varargin)>1, txt = varargin{2}; else txt = ''; end

    if ~isempty(txt) && txt(1) == '$',
        txt = ptrLgGetString(txt(2:end));
    end
        
    if pct == -1
        set(ptrData.handles.statusBar.progressBar, 'Visible', 'off');
        set(ptrData.handles.statusBar.progressBarBg, 'Visible', 'off');
        set(ptrData.handles.statusBar.text, 'String', txt)
    else
        pct = max(min(pct, 0.999), 0.001);
        set(ptrData.handles.statusBar.progressBar, 'Visible', 'on', ...
                  'Position', [0.80 0.2 0.19*pct 0.6]);
        set(ptrData.handles.statusBar.progressBarBg, 'Visible', 'on', ...
                  'Position', [0.80+0.19*pct 0.2 0.19*(1-pct) 0.6]);
        set(ptrData.handles.statusBar.text, 'String', ...
            [txt ' (' num2str(round(pct*100)) '%)']);
    end
            
    guidata(hObject, ptrData);
    drawnow
end


function updateSize (hObject, ptrData, varargin)
    diff = varargin{1};
    pos = get(ptrData.handles.statusBar.statusBar,'Position');
    pos(3) = pos(3) - diff(1);
    set(ptrData.handles.statusBar.statusBar,'Position',pos);
end
