%
% Crea un cuadro de diálogo genérico para seleccionar elementos de una
% lista.
%
% PARAMS:
%  - ls -> Lista de elementos (cell)
%  - dft -> Posición en 'ls' del elemento seleccionado por defecto
%  - title -> Título de la ventana
%
function varargout = dlgSelec(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @dlgSelec_OpeningFcn, ...
                       'gui_OutputFcn',  @dlgSelec_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);

    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT

function dlgSelec_OpeningFcn(hObject, eventdata, handles, varargin)
    ptrLgSetUIStrings(hObject);
    handles.output.ok = false;
    handles.output.selection = [];

    handles.valueList = varargin{1};
    dft = varargin{2};
    title = varargin{3};

    set (handles.dlg ,'Name', title);
    set (handles.ls, 'String', handles.valueList);
    set (handles.ls, 'Value', dft);
    
    ptrCenterWindow(hObject);

    % Update handles structure
    guidata(hObject, handles);

    % Make the GUI modal
    set(handles.dlg,'WindowStyle','modal')

    % UIWAIT makes dlgEntrenar wait for user response (see UIRESUME)
    uiwait(handles.dlg);


function varargout = dlgSelec_OutputFcn(hObject, eventdata, handles)
    % Get default command line output from handles structure
    varargout = struct2cell(handles.output);

    % The figure can be deleted now
    delete(handles.dlg);


function dlg_CloseRequestFcn(hObject, eventdata, handles)
    btnCancelar_Callback(hObject, eventdata, handles);


function dlg_KeyPressFcn(hObject, eventdata, handles)
    % Check for "enter" or "escape"
    if isequal(get(hObject,'CurrentKey'),'escape')
        btnCancelar_Callback(hObject, eventdata, handles);
    end    

    if isequal(get(hObject,'CurrentKey'),'return')
        btnAceptar_Callback(hObject, eventdata, handles);
    end    


function ls_Callback(hObject, eventdata, handles)
    action = get (handles.dlg, 'SelectionType');
	if strcmp(action,'open'), 
        btnAceptar_Callback(hObject, eventdata, handles)
    end

    
function btnAceptar_Callback(hObject, eventdata, handles)
    if isempty(handles.valueList), return, end
    v_sel = get(handles.ls, 'Value');
    handles.output.selection = v_sel;
    handles.output.ok = true;
    guidata(hObject, handles);
    uiresume(handles.dlg);


function btnCancelar_Callback(hObject, eventdata, handles)
    handles.output.ok = false;
    handles.output.selection = '';
    guidata(hObject, handles);
    uiresume(handles.dlg);


