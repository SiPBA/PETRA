function varargout = dlgEntrenar(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @dlgEntrenar_OpeningFcn, ...
                       'gui_OutputFcn',  @dlgEntrenar_OutputFcn, ...
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


function dlgEntrenar_OpeningFcn(hObject, eventdata, handles, varargin)
    ptrLgSetUIStrings(hObject);
    ptrCenterWindow(hObject);
    
    handles.params = varargin{1};
    handles.paramTrn.stacks = double(varargin{2});
    handles.paramTrn.etiqs = varargin{3};
    handles.paramTrn.clases = varargin{4};
    handles.paramTrn.tipoImgs = varargin{5};
    
    handles.paramTrn.tama = size(squeeze(handles.paramTrn.stacks(1,:,:,:)));
    handles.paramTrn.umbral = 0;
    handles.paramTrn.scale = 1;
    
    handles.output.ok = false;
    handles.dirTrn = handles.params.pathTrn;
    
    %Get methods (fill the list)
    handles.methods = [];
    ms = [];
    lis = dir (handles.params.pathMethods);
    for i=1:numel(lis)
        if lis(i).name(1) ~= '.' && lis(i).isdir
            nameFile = [handles.params.pathMethods filesep lis(i).name ...
                        filesep 'nfo_name.txt'];
            if exist(nameFile,'file')
                name = textread(nameFile,'%s');
                ms{numel(ms)+1} = strjoin({name{:}},' ');
                handles.methods{numel(ms)} = lis(i).name;
            end
        end
    end
    handles.methodsName = ms;
    if isempty (ms), ms = ' '; end
    set (handles.cbMetodo,'String',ms);

    % Save handle and wait for response
    guidata(hObject, handles);
    set(handles.dlg,'WindowStyle','modal')
    uiwait(handles.dlg);



function varargout = dlgEntrenar_OutputFcn(hObject, eventdata, handles)
    varargout = struct2cell(handles.output);
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
    
    
function btnCancelar_Callback(hObject, eventdata, handles)
    handles.output.ok = false;
    guidata(hObject, handles);
    uiresume(handles.dlg);

    
function btnAceptar_Callback(hObject, eventdata, handles)
    if isempty (handles.methods)
        ptrDlgMessage('$dlgEntrenar_NoMethodError', '$all_Error');
        return
    end
    
    % Lee campos
    handles.paramTrn.des = strtrim(get(handles.txtDescrip,'String'));
    handles.paramTrn.met = handles.methods{get(handles.cbMetodo,'Value')};
    handles.paramTrn.met_name = handles.methodsName{get(handles.cbMetodo,'Value')};
 
    % Comprueba valores
    if strcmp(handles.paramTrn.des,'')
        ptrDlgMessage('$dlgEntrenar_NoNameError', '$all_Error');
        return
    end
    

    trn = createTrn (handles.params, handles.paramTrn);
    if isempty(trn.train), return, end

    trnFile = compute_unique_name(handles.dirTrn);
    save(trnFile, '-struct', eval([char(39) 'trn' char(39)]));
    ptrDlgMessage([ptrLgGetString('dlgEntrenar_Created') ' ' trnFile], ...
        '$dlgEntrenar_CreatedTitle');

    handles.output.ok = true;
    guidata(hObject, handles);
    uiresume(handles.dlg);
    


function trn = createTrn(params, paramTrn)    
    % Aplica mascara
    media = entre0y1(squeeze(mean(paramTrn.stacks)));
    if paramTrn.umbral==0, 
        paramTrn.umbral = graythresh(media(:,:)); 
        paramTrn.umbral = paramTrn.umbral*100; 
    end
    mascara = media >= double(paramTrn.umbral)/100;
    if isempty(find(mascara, 1))
        mascara = media >= 0;
        paramTrn.umbral = 0;
    end
    for p=1:size(paramTrn.stacks,1)
        paramTrn.stacks(p,:,:,:) = squeeze(paramTrn.stacks(p,:,:,:)) .* mascara;
    end
    
    trn = [];
    trn.labels = paramTrn.etiqs;
    trn.clases = paramTrn.clases;
    trn.sc = paramTrn.scale;
    trn.mascara = mascara;
    trn.met = paramTrn.met;
    trn.info.descrip = paramTrn.des;
    trn.info.met_name = paramTrn.met_name;
    trn.info.date = datestr(now);
    trn.info.nImgs = size(paramTrn.stacks,1);
    trn.info.tipoImgs = paramTrn.tipoImgs;
    trn.info.tamaImgsOri = paramTrn.tama;
    trn.info.tamaImgsRed = size(trn.mascara);
    trn.info.umbral = paramTrn.umbral;
    trn.img_x = (squeeze(media(floor(size(media,1)/2),:,:)));
    trn.img_y = (squeeze(media(:,floor(size(media,2)/2),:)));
    trn.img_z = (squeeze(media(:,:,floor(size(media,3)/2))));
    trn.train = entrenar(trn, paramTrn.stacks, params);


function name = compute_unique_name(dire)
    name = '';
    k = 1;
    lis = dir([dire '/*.trn']);
    while strcmp(name, '')
        name = sprintf('trn_%03d.trn',k);
        for i=1:numel(lis)
            if lis(i).name(1:7) == name(1:7)
                name = '';
                k = k+1;
                break
            end
        end
    end
    name = [dire filesep name];
    
