function varargout = dlgSelecTrn(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @dlgSelecTrn_OpeningFcn, ...
                       'gui_OutputFcn',  @dlgSelecTrn_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);

    if nargin && ischar(varargin{1}) && exist(varargin{1})==2
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

% --- Executes just before dlgEntrenar is made visible.
function dlgSelecTrn_OpeningFcn(hObject, eventdata, handles, varargin)
    ptrLgSetUIStrings(hObject);
    
    handles.output.ok = false;
    handles.output.trn = [];
    handles.output.file = '';

    handles.rutaTrn = varargin{1};
    imTip = varargin{2};
    handles.entrenamientos = [];
    
    % Llena lista de tipos de imagen y de entrenamientos
    ls = []; k = 1;
    for i=1:numel(imTip)
        if imTip{i} == 0, continue; end
        ls{k} = imTip{i};
        k = k+1;
    end
    if isempty(ls), ls = ' '; end
    set(handles.cbTipoImg,'String',ls);
    handles = cargarLsTrn(handles);

    % Update handles structure
    guidata(hObject, handles);

    ptrCenterWindow(hObject);
    set(handles.dlg,'WindowStyle','modal') % Make the GUI modal

    % UIWAIT makes dlgEntrenar wait for user response (see UIRESUME)
    uiwait(handles.dlg);


function varargout = dlgSelecTrn_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout = struct2cell(handles.output);

    % The figure can be deleted now
    delete(handles.dlg);


function dlgSelecTrn_CloseRequestFcn(hObject, eventdata, handles)
    btnCancelar_Callback(hObject, eventdata, handles);


function dlgSelecTrn_KeyPressFcn(hObject, eventdata, handles)
    % Check for "enter" or "escape"
    if isequal(get(hObject,'CurrentKey'),'escape')
        btnCancelar_Callback(hObject, eventdata, handles);
    end    

    if isequal(get(hObject,'CurrentKey'),'return')
        btnAceptar_Callback(hObject, eventdata, handles);
    end    


function handles = cargarLsTrn(handles)
    imTips = get(handles.cbTipoImg,'String');
    if isempty(imTips) || isempty(strtrim(imTips)), return; end;
    imTip = get(handles.cbTipoImg,'Value');
    imTip = imTips(imTip);
    
    ms = []; k = 0;
    handles.entrenamientos = {};
    handles.infos = {};
    lis = dir ([handles.rutaTrn filesep '*.trn']);
    for i=1:numel(lis)
        nombre = [handles.rutaTrn filesep lis(i).name];
        trn = load(nombre,'-mat','info');
        if strcmp(trn.info.tipoImgs, imTip)
            k = k + 1;
            ms {k} = trn.info.descrip;
            handles.entrenamientos{k} = nombre;
            handles.infos{k} = trn.info;
        end
        clear trn;
    end
    if isempty (ms), ms = ' '; end
    guidata(handles.dlg, handles);
    set (handles.lsEntrenamientos,'String',ms);
    set (handles.lsEntrenamientos,'Value',1);
    cargarInfoTrn(handles)
       

function cargarInfoTrn(handles)
    trn = get(handles.lsEntrenamientos,'Value');
    if isempty(handles.infos)
        t = [];
    else
        info = handles.infos{trn};
        ubi = handles.entrenamientos{trn};
        prefix = '<HTML><b>';
        sufix = '</b>';
        t = {[prefix ptrLgGetString('infoTrn_Name')   ': ' sufix info.descrip], ...
            [prefix ptrLgGetString('infoTrn_Method') ': ' sufix info.met_name], ...
            [prefix ptrLgGetString('infoTrn_Date')   ': ' sufix info.date], ...
            [prefix ptrLgGetString('infoTrn_Dir')    ': ' sufix ubi], '', ...
            [prefix '<u>' ptrLgGetString('infoTrn_Images') sufix], ...
            [prefix ptrLgGetString('infoTrn_Mod')    ': ' sufix info.tipoImgs], ...
            [prefix ptrLgGetString('infoTrn_Number') ': ' sufix num2str(info.nImgs)], ...
            [prefix ptrLgGetString('infoTrn_OSize')  ': ' sufix num2str(info.tamaImgsOri)], ...
            [prefix ptrLgGetString('infoTrn_RSize')  ': ' sufix num2str(info.tamaImgsRed)], ...
            [prefix ptrLgGetString('infoTrn_IntTh')  ': ' sufix num2str(round(info.umbral)), ...
             ptrLgGetString('infoTrn_IntThSuf')]};
    end
    
    set (handles.edInfo, 'String',t);


% --- Executes on button press in btnAceptar.
function btnAceptar_Callback(hObject, eventdata, handles)
    if isempty(handles.entrenamientos), return, end
    v_sel = get(handles.lsEntrenamientos,'Value');
    fname = handles.entrenamientos{v_sel};
    try
        trn = load(fname,'-mat');
        handles.output.ok = true;
        handles.output.trn = trn;
        handles.output.file = fname;
    catch e
        ptrDlgMessage([ptrLgGetString('selecTrn_LoadTrn') ' ' fname]);
        handles.output.ok = false;
        handles.output.trn = [];
        handles.output.file = '';
    end
    
    guidata(hObject, handles);
    uiresume(handles.dlg);

    
% --- Executes on button press in btnCancelar.
function btnCancelar_Callback(hObject, eventdata, handles)
    handles.output.ok = false;
    handles.output.trn = [];
    handles.output.file = '';
    guidata(hObject, handles);
    uiresume(handles.dlg);

% --- Executes on selection change in lsEntrenamientos.
function lsEntrenamientos_Callback(hObject, eventdata, handles)
    if isempty(handles.entrenamientos), return, end
    action = get (handles.dlg, 'SelectionType');
	if strcmp(action,'open'), 
        btnAceptar_Callback(hObject, eventdata, handles)
    else
        cargarInfoTrn(handles);
    end
