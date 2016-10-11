function varargout = dlgResClasif(varargin)
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @dlgResClasif_OpeningFcn, ...
                       'gui_OutputFcn',  @dlgResClasif_OutputFcn, ...
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


function dlgResClasif_OpeningFcn(hObject, eventdata, handles, varargin)
    ptrLgSetUIStrings(hObject);
    ptrCenterWindow(hObject);
    handles.posFig = get (hObject,'Position');

    handles.clases = varargin{1};
    handles.clase = varargin{2};
    handles.params = varargin{3};
    handles.lsComps = varargin{4};
    handles.figFunction = str2func(varargin{5});
    handles.fcnParams = varargin{6};
    handles.trn = varargin{7};
    handles.trnFile = varargin{8};
    handles.numAxes = 0;

    str = [ptrLgGetString('resClas_Classes') ' ' ptrStrJoin(handles.clases,', ')];
    set(handles.etiClases,'String',str);
    str = [ptrLgGetString('resClas_Estimation') ' ' handles.clases{handles.clase+1}];
    set(handles.etiClase,'String',str);

    setButtonIcons (handles.dlg, handles.params.pathIcons);
    set(hObject,'DockControls','off');

    % Llena listas combo
    for i=1:numel(handles.lsComps), ms{i+1} = num2str(handles.lsComps(i)); end
    ms{1} = ptrLgGetString('resClas_None');
    set(handles.lbComp1,'String',ms(2:end));
    set(handles.lbComp2,'String',ms);
    set(handles.lbComp3,'String',ms);
    if numel(handles.lsComps)>1, set(handles.lbComp2,'Value',3); end

    handles.output.trnFlag = false;
    handles.output.trn = [];

    % Update handles structure
    guidata(hObject, handles);

    muestraFig (handles, hObject);
    
    % UIWAIT makes dlgResClasif wait for user response (see UIRESUME)
    uiwait(handles.dlg);

function closeRequestFcn(hObject, eventdata, handles)
    uiresume(handles.dlg);

function varargout = dlgResClasif_OutputFcn(hObject, eventdata, handles)
    varargout = struct2cell(handles.output);
    delete(hObject);


function muestraFig (handles, hObject)
    set(gcf,'Pointer','watch');
    ls = get(handles.lbComp1,'String');
    c1 = str2double(ls{get(handles.lbComp1,'Value')});
    ls = get(handles.lbComp2,'String');
    c2 = str2double(ls{get(handles.lbComp2,'Value')});
    ls = get(handles.lbComp3,'String');
    c3 = str2double(ls{get(handles.lbComp3,'Value')});

    comps = c1;
    if ~isnan(c2), comps = [comps c2]; end
    if ~isnan(c3), comps = [comps c3]; end
    
    numAxes = numel(comps);
    if handles.numAxes ~= numAxes
        handles.numAxes = numAxes;
        handles = fixAxes (handles);
    end
    handles.figFunction (comps, handles.fcnParams, handles.ejScatter, handles.ejEBs);
    set(gcf,'Pointer','arrow');
    guidata(hObject, handles);
        
        
function handles = fixAxes (handles)
    if isfield(handles,'ejEigenbrain1') && ~isempty(handles.ejEigenbrain1)
        delete (handles.ejEigenbrain1);
        handles.ejEigenbrain1 = [];
    end
    if isfield(handles,'ejEigenbrain2') && ~isempty(handles.ejEigenbrain2)
        delete (handles.ejEigenbrain2);
        handles.ejEigenbrain2 = [];
    end
    if isfield(handles,'ejEigenbrain3') && ~isempty(handles.ejEigenbrain3)
        delete (handles.ejEigenbrain3);
        handles.ejEigenbrain3 = [];
    end
    if isfield(handles,'ejScatter') && ~isempty(handles.ejScatter)
        delete (handles.ejScatter);
        handles.ejScatter = [];
    end
        
    if handles.numAxes==1
        handles.ejEigenbrain1 = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.02 0.05 0.40 0.9],...
        'Tag','ejEigenbrain1' );
    
        handles.ejScatter = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.55 0.1 0.43 0.85],...
        'Tag','ejEigenbrain1' );

        handles.ejEBs = [handles.ejEigenbrain1];
    elseif handles.numAxes==2
        handles.ejEigenbrain1 = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.02 0.52 0.40 0.43],...
        'Tag','ejEigenbrain1' );

        
        handles.ejEigenbrain2 = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.02 0.05 0.40 0.43],...
        'Tag','ejEigenbrain2' );

        handles.ejScatter = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.55 0.1 0.43 0.85],...
        'Tag','ejEigenbrain1' );
    
        handles.ejEBs = [handles.ejEigenbrain1, handles.ejEigenbrain2];
    elseif handles.numAxes==3
        handles.ejEigenbrain1 = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.02 0.67 0.30 0.26],...
        'Tag','ejEigenbrain1' );

        handles.ejEigenbrain2 = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.02 0.35 0.30 0.26],...
        'Tag','ejEigenbrain2' );

        handles.ejEigenbrain3 = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.02 0.03 0.30 0.26],...
        'Tag','ejEigenbrain3' );
    
        handles.ejScatter = axes(...
        'Parent',handles.pnFigura,...
        'Box','on',...
        'Position',[0.40 0.1 0.55 0.85],...
        'Tag','ejEigenbrain1' );

        handles.ejEBs = [handles.ejEigenbrain1, handles.ejEigenbrain2, ...
                 handles.ejEigenbrain3];
    else
        msgbox('Número de figuras incorrecto');
        handles.ejEBs = [];
    end


function dlg_ResizeFcn(hObject, eventdata, handles)
    if ~isfield(handles, 'posFig'), return; end
    posFig = get(handles.dlg,'Position');
    
    %Encabezado
    pos = get(handles.pnTitu,'Position');
    pos(2) = pos(2) + posFig(4) - handles.posFig(4);
    pos(3) = pos(3) + posFig(3) - handles.posFig(3);
    set (handles.pnTitu,'Position',pos);
    
    %Figura
    pos = get(handles.pnFigura,'Position');
    pos(3) = pos(3) + posFig(3) - handles.posFig(3);
    pos(4) = pos(4) + posFig(4) - handles.posFig(4);
    set (handles.pnFigura,'Position',pos);
    
    %Pie
    pos = get(handles.pnBtn,'Position');
    pos(3) = pos(3) + posFig(3) - handles.posFig(3);
    set (handles.pnBtn,'Position',pos);
    
    handles.posFig = posFig;
    guidata(hObject, handles);
    

function addTrain (handles)
    clase = ptrDlgSelec(handles.clases, handles.clase+1, ...
                      'Seleccione la clase');
    if clase == 0, return, end
    etiq = clase-1;
    trn = handles.trn;

    %Añadir a los viejos el nuevo featv
    trn.train.feats = [handles.fcnParams.feats; trn.train.feats];
    trn.info.nImgs = trn.info.nImgs + 1;

    %Añadir a los labels
    labels = trn.labels;
    if size(labels,1)<size(labels,2), labels = labels'; end
    trn.labels=[etiq; labels]; 

    %Generar entrenamiento y guardar resultado
    trn.train = entrenar(handles.rutas, trn, []);
    if isempty(trn.train), return, end
    save(handles.trnFile, '-struct', eval([char(39) 'trn' char(39)]));
    msgbox(['Se ha modificado ' handles.trnFile],'Proceso realizado');

    % Guarda resultados para devolverlos
    handles.output.trnFlag = true;
    handles.output.trn = trn;
    guidata(handles.dlg, handles);
    

function setButtonIcons (h, fpath)

    % If h is not a button handle, find buttons
    if strcmp(class(handle(h)), 'uicontrol')
        hBtns = h;
    else
        hBtns = findobj(h, 'Style','pushbutton')';
        hBtns = [hBtns findobj(h, 'Style','togglebutton')'];
    end
    
    % For each button....
    for hb = hBtns
        str = get(hb,'String');
        if length(str)<5 || ~strcmp(str(1:4),'ico:'), continue, end
        
        %Get icons name (one or more)
        spacePos = strfind (str,' ');
        if isempty(spacePos)
            endPos = numel(str);
        else
            endPos = spacePos(1)-1;
        end
        fnames = ptrStrSplit(str(5:endPos), ':');
        set (hb,'String',str(endPos+2:end));

        % Load icons. Show the first one and save the other ones
        for ic = 1:numel(fnames)
            fname = [fpath filesep fnames{ic}];
            try
                ico = imread (fname,'BackgroundColor', [1 1 1]);
                ico = imresize(ico,[20 20]);
            catch e
                ico = [];
            end
            icons{ic} = ico;
        end
        set(hb, 'CData', icons{1});
        if numel(icons)>1, set(hb,'UserData',struct('icons',{icons})); end
    end
    