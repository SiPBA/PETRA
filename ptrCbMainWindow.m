function ptrCbMainWindow (hObject, eventdata, action, varargin)
    func = eval(['@' action]);
    ptrData = guidata (hObject);
    func (hObject, ptrData, varargin{:});
end


function selectImg (hObject, ptrData, varargin)
    if nargin<3, i = ptrData.current.img; else i = varargin{1}; end
    v = get(hObject,'Value');
    ptrData.images(i).selected = v;
    guidata(hObject,ptrData);
    ptrStatusBar(hObject, 'updateTxt');    
end


function imgOpen (hObject, ptrData, varargin)
    tipos = {'*.hdr;*.HDR;*.nii;*.NII;*.dcm;*.DCM;*.bmp;*.BMP;*.IMA;*.ima;*.A00',...
         [ptrLgGetString('main_AllFormats') ' (*.hdr, *.nii, *.dcm, *.bmp, *.ima)'];
         '*.hdr;*.HDR', 'Analyze/NIfTI (*.hdr/img)';
         '*.nii;*.NII', 'NIfTI (*.nii)';
         '*.dcm;*.DCM', 'DICOM multivolumen (*.dcm)';
         '*.bmp;*.BMP', 'Bitmap (*.bmp)';
         '*.ima;*.IMA', 'IMA multivolumen (*.ima)';
         '*.A00', 'Interfile multivolumen (*.A00)'};
     
    [names fPath] = uigetfile(tipos, ... 
                          ptrLgGetString('main_LoadImages'), ... 
                          ptrData.params.dir, ... 
                          'Multiselect', 'on');
    if ischar(names) names = {names}; end
    if ~iscell(names) && names == 0, return; end

    % Ask for modality
    idx = ptrDlgSelec(ptrData.params.imgTypes(:,2), 1, ...
                 ptrLgGetString('main_SelectMod'));
    if ~idx, return; end
    type = ptrData.params.imgTypes{idx,1};

    % Read images
    set(ptrData.handles.win,'Pointer','watch')
    for i=1:numel(names)
        ptrStatusBar (hObject, 'updateProgress', (i-1)/numel(names), ...
            '$main_LoadingImages');
        [stack, str] = leer_img ([fPath filesep names{i}], type);
        [p, name, ext] = fileparts(names{i});

        img.volume = stack;
        img.hdr = str;
        img.filePath = fPath;
        img.fileName = name;
        img.fileExt = ext;
        img.class = '';
        img.selected = 0;
        img.type = type;
        images(i) = img;
    end
    set(ptrData.handles.win,'Pointer','arrow')
    
    % Store images in ptrData
    if ~isfield(ptrData,'images') ptrData.images = []; end
    ptrData.current.img = numel(ptrData.images) + 1;
    ptrData.images = [ptrData.images images];
    ptrData.params.dir = fPath; % Save current dir
    guidata(hObject,ptrData);
    
    % Repaint the panel
    ptrSetMainPanel(ptrData);    

    % Update status bar
    ptrStatusBar (hObject, 'updateTxt');
end


function imgClose (hObject, ptrData, varargin)
    if isempty(varargin)
        % Get selected images
        sel = getSelectedIdx (ptrData);
        if isempty(sel), 
            ptrDlgMessage('$main_NoImSel','$all_Warning'); 
            return; 
        end
    else
        sel = [varargin{1}];
    end
    
    noSel = setdiff(1:numel(ptrData.images), sel);
    ptrData.images = ptrData.images(noSel);
    ptrData.current.img = 1;
    guidata(hObject, ptrData);
    
    % Repaint the panel
    ptrSetMainPanel(ptrData);    
end


function imgNormSpa (hObject, ptrData, varargin)
    % Get selected images
    sel = getSelectedIdx (ptrData);
    if isempty(sel), 
        ptrDlgMessage('$main_NoImSel','$all_Warning'); 
        return; 
    end

    % Check if SPM is installed
    if isempty(which('spm')) && ~isdeployed
        ptrDlgMessage('$main_NoSPM', '$all_Error');
        return
    end
    
    % For each image ... normalize
    set(ptrData.handles.win,'Pointer','watch')
    for i=1:numel(sel)
        ptrStatusBar (hObject, 'updateProgress', (i-1)/numel(sel), ...
            '$main_Nomalizing');
        [error, vol, hdr] = ptrNormSpa (ptrData.images(sel(i)).volume, ...
                                        ptrData.images(sel(i)).hdr, ...
                                        ptrData.images(sel(i)).type, ...
                                        ptrData.params.pathTpl);
        if ~error,
            ptrData.images(sel(i)).volume = vol;
            ptrData.images(sel(i)).hdr = hdr;
        end
    end
    set(ptrData.handles.win,'Pointer','arrow')

    % Save results
    guidata (hObject, ptrData);
    
    % Update UI
    fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
    feval (fcn, hObject, [], 'updateData', 'slices', sel);

    % Update statusbar 
    ptrStatusBar (hObject, 'updateTxt');
end


function imgNormInt (hObject, ptrData, varargin)
    % Get selected images
    sel = getSelectedIdx (ptrData);
    if isempty(sel), 
        ptrDlgMessage('$main_NoImSel','$all_Warning'); 
        return; 
    end
    
    % Get type
    if strcmpi (varargin{1}, 'Max')
        fcn = @ptrNormIntMax;
    else
        fcn = @ptrNormIntGlobal;
    end
    
    % For each image... normalize
    set(ptrData.handles.win,'Pointer','watch')
    for i=1:numel(sel)
        ptrStatusBar (hObject, 'updateProgress', (i-1)/numel(sel), ...
            '$main_Nomalizing');
        ptrData.images(sel(i)).volume = fcn (ptrData.images(sel(i)).volume);
    end
    set(ptrData.handles.win,'Pointer','arrow')

    % Save results
    guidata (hObject, ptrData);
    
    % Update UI
    fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
    feval (fcn, hObject, [], 'updateData', 'slices', sel);

    % Update statusbar 
    ptrStatusBar (hObject, 'updateTxt');
end


function imgMarkAs (hObject, ptrData, varargin)
    % Get selected images
    sel = getSelectedIdx (ptrData);
    if isempty(sel), 
        ptrDlgMessage('$main_NoImSel','$all_Warning'); 
        return; 
    end

    for i=sel
        ptrData.images(i).class = varargin{1};
    end
    
    % Save results
    guidata (hObject, ptrData);
    
    % Update UI
    fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
    feval (fcn, hObject, [], 'updateData', 'class', sel);
end


function imgSave (hObject, ptrData, varargin)
    % Get selected images
    sel = getSelectedIdx (ptrData);
    if isempty(sel), 
        ptrDlgMessage('$main_NoImSel','$all_Warning'); 
        return; 
    end
    
    % Show help (keywords)
    ptrDlgMessage('$main_SaveHelp','$main_SavingImages')
    
    % Get path, names and format
    fmts = {'*.nii', 'NIfTI (*.nii)';
             '*.hdr', 'NIfTI (2 archivos) (*.hdr)';
             '*.hdr', 'Analyze 7.5 (2 archivos) (*.hdr)';
             '*.dcm', 'DICOM multivolumen (*.dcm)';
             '*.bmp', 'Mapas de bits (*.bmp)'};
    title = ptrLgGetString('main_SaveDglTitle');
    if numel(sel) == 1,
        dftName = [ptrData.images(sel(1)).filePath filesep ...
            ptrData.images(sel(1)).fileName];
    else
        dftName = [ptrData.params.dir filesep '#name_modified.nii'];
    end 
    [nombre, ruta, tipo] = uiputfile(fmts, title, dftName);
    if isequal(nombre,0), return; end
    if tipo == 3, fmt = 'a75'; else fmt = fmts{tipo}(3:end); end

    % Save images
    names = {};
    for i=1:numel(sel)
        ptrStatusBar (hObject, 'updateProgress', (i-1)/numel(sel), ...
            '$main_SavingImages');
        [p, n, e] = fileparts (nombre);
        
        n = strrep(n, '#name', ptrData.images(sel(i)).fileName);
        n = strrep(n, '#class', ptrData.images(sel(i)).class);
        n = strrep(n, '#number', num2str(sel));
        
        if any(strcmp(names, n)), n = [n '_' num2str(i)]; end
        names{i} = n;
        desti = [ruta filesep n e];
        
        ok = guardar_img (ptrData.images(sel(i)).volume, ...
                          ptrData.images(sel(i)).hdr, fmt, desti);
        if ok,
            [p, n, e] = fileparts(desti);
            ptrData.images(sel(i)).filePath = p;
            ptrData.images(sel(i)).fileName = n;
            ptrData.images(sel(i)).fileExt = e;
            ptrData.params.dir = fileparts (p);
            guidata(hObject, ptrData);
        end
    end

    % Update UI
    fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
    feval (fcn, hObject, [], 'updateData', 'name', sel);

    % Update statusbar 
    ptrStatusBar (hObject, 'updateTxt');
end


function imgClassify (hObject, ptrData, varargin)
    if nargin<3, 
        im = ptrData.images(ptrData.current.img);
    else
        im = ptrData.images(varargin{1});
    end
    
    % Check if a training is loaded
    if ~isfield(ptrData, 'train') || ~isfield(ptrData.train, 'trn'), 
        ptrDlgMessage('$main_NoTraining', '$main_ClassUnable');
        return
    end
    
    % Check images' modality and size match with the training
    if ptrData.train.trn.info.tipoImgs ~= im.type,
        ptrDlgMessage('$main_DifImgType', '$main_ClassUnable');
        return
    end   
    if any(ptrData.train.trn.info.tamaImgsRed ~= size(im.volume)),
        ptrDlgMessage('$main_DifImgSize', '$main_ClassUnable');
        return
    end
    
    pathOri = path;
    if ~isdeployed
        addpath ([ptrData.params.pathMethods filesep ptrData.train.trn.met]);
        addpath (ptrData.params.pathFeatureExtrac);
        addpath (ptrData.params.pathClassifiers);
    end

    % Call method fucntion
    args.imgs(1,:,:,:) = im.volume .* ptrData.train.trn.mascara;
    args.train = ptrData.train.trn.train;
    args.clases = ptrData.train.trn.clases;
    args.mascara = ptrData.train.trn.mascara;
    args.met = ptrData.train.trn.met;
    args.colormap = ptrData.params.colormap;
    try
        [error, msj, res] = feval (['run_' ptrData.train.trn.met], 'classify', args);
        path (pathOri);
        if error~=0, ptrDlgMessage (msj,'$main_ClassUnable'); return; end
    catch e
        ptrDlgMessage (e.message, '$ppal_ClassUnable');
        path (pathOri);
        return;
    end
    
    if isfield(res, 'figFunction')
        [trnFlag, trn] = dlgResClasif (ptrData.train.trn.clases, res.class, ...
                      ptrData.params, res.comps, res.figFunction, res, ...
                      ptrData.train.trn, ptrData.train.fileName);
                  
        % Update training if the image has been added
        if trnFlag, 
            ptrData.train.trn = trn;
            guidata(hObject, ptrData);
        end
    else
        if size(res.args.train.options,1)==1
            res.dimplot=1;
        elseif size(res.args.train.options,1)==2
            res.dimplot=2;
        else
            prompt = {langGetString('ppal_ScattDim')};
            dlg_title = langGetString('ppal_ResultVisual');
            num_lines = 1;
            def = {'2'};
            answer = inputdlg(prompt,dlg_title,num_lines,def);
            res.dimplot=str2double(answer{1});
        end

        representar_results(res);
    end
end


function trnCreate (hObject, ptrData, varargin)

    % Check if there are selected images 
    sel = getSelectedIdx (ptrData);
    if isempty(sel),
        ptrDlgMessage('$main_NoImgTrn','$all_Error');
        return; 
    end
    
    % Check if only one modality of images
    type = unique(cell2mat({ptrData.images(sel).type}));
    if numel(type)>1
        ptrDlgMessage('$main_ManyTypes','$all_Error');
        return;
    end
    type = type(1);
    
    % Check if two classes
    classes = unique({ptrData.images(sel).class});
    if numel(classes) ~= 2
        ptrDlgMessage('$main_IncorrectClasses', '$all_Error');
        return;
    end
    
    % Ask for name and method
    [name, methodName, methodPath] = ptrDlgCreateTraining(...
        ptrData.params.pathMethods);
    if name==-1, return; end
    
    % Create volumes matrix and label vector
    set(ptrData.handles.win,'Pointer','watch')
    num = numel(sel);
    for i=1:num
        ptrStatusBar (hObject, 'updateProgress', (i-1)/(2*num), ...
            '$main_PreparingData');
        volumes (i,:,:,:) = ptrData.images(sel(i)).volume;
        labels(i) = double(~strcmpi(ptrData.images(sel(i)).class,'CTL'));
    end
    volumes = double(volumes);
    meanVol = squeeze(mean(volumes));
    sizeVol = size(meanVol);
    th = graythresh(meanVol(:,:));
    mask = meanVol >= th;
    if isempty(find(mask, 1)), th = 0; mask = meanVol >= 0; end
    for i=1:num
        ptrStatusBar (hObject, 'updateProgress', (num+i-1)/(2*num), ...
            '$main_PreparingData');
        volumes(i,:,:,:) = squeeze(volumes(i,:,:,:)) .* mask;
    end

    % Create training structure
    ptrStatusBar(ptrData.handles.win, 'updateProgress', -1, ...
        '$dlgEntrenar_Creating');
    trn = [];
    trn.labels = labels;
    trn.clases = classes;
    trn.sc = 1;
    trn.mascara = mask;
    trn.met = methodPath;
    trn.info.descrip = name;
    trn.info.met_name = methodName;
    trn.info.date = datestr(now);
    trn.info.nImgs = size(volumes,1);
    trn.info.tipoImgs = type;
    trn.info.tamaImgsOri = sizeVol;
    trn.info.tamaImgsRed = sizeVol;
    trn.info.umbral = uint8(th*100);
    trn.img_x = (squeeze(meanVol(floor(sizeVol(1)/2),:,:)));
    trn.img_y = (squeeze(meanVol(:,floor(sizeVol(2)/2),:)));
    trn.img_z = (squeeze(meanVol(:,:,floor(sizeVol(3)/2))));
    trn.train = ptrCreateTraining(trn, volumes, ...
        ptrData.params.pathMethods, ptrData.params.pathClassifiers);
    
    % If success, compute unique filename and save
    if ~isempty(trn.train)
        lis = dir([ptrData.params.pathTrn filesep '*.trn']); k = 1;
        while true
            fileName = sprintf('trn_%03d.trn',k); k = k+1;
            if ~any(strcmp({lis(:).name}, fileName)), break; end
        end
        fileName = [ptrData.params.pathTrn filesep fileName];
        save(fileName, '-struct', eval([char(39) 'trn' char(39)]));
        ptrDlgMessage([ptrLgGetString('dlgEntrenar_Created') ' ' fileName],...
            '$dlgEntrenar_CreatedTitle');
    end
    
    set(ptrData.handles.win,'Pointer','arrow')
    ptrStatusBar(ptrData.handles.win, 'updateTxt');
end


function trnLoad (hObject, ptrData, varargin)
    trnFile = ptrDlgSelecTrn(ptrData.params.imgTypes, ...
        ptrData.params.pathTrn);
    if trnFile == 0, return, end

    ptrData.train.trn = load(trnFile, '-mat');
    ptrData.train.fileName = trnFile;
    ptrData.train.name = ptrData.train.trn.info.descrip;
    guidata(hObject, ptrData);
    
    % Enable 'Show details' option in menu
    set(ptrData.handles.menu.trn.item(3), 'Enable', 'on');
    
    % Update statusbar 
    ptrStatusBar (hObject, 'updateTxt');
    
end


function trnDetails (hObject, ptrData, varargin)
    if ~isfield(ptrData, 'train'), return; end
    ptrInfoTrn(ptrData.train, ptrData.params);
end


function changeLang (hObject, ptrData, varargin)
    idx = getCheckedItemMenu (ptrData.handles.menu.lang, hObject);
    ptrData.params.langSelected = ptrData.params.langData(idx).code;
    guidata(hObject, ptrData);
    
    global petraParams
    petraParams.langStrings = ...
        ptrData.params.langStrings.(ptrData.params.langSelected);
    
    set (ptrData.handles.win,'Visible','off');
    delete(ptrData.handles.toolbar.toolbar);
    delete(ptrData.handles.statusBar.statusBar);
    menus = fieldnames(ptrData.handles.menu);
    for i=1:numel(menus)
        delete(ptrData.handles.menu.(menus{i}).menu);
    end

    pos = get(ptrData.handles.win,'Position');
    ptrDsMainWindow(ptrData.handles.win);
    ptrSetMainPanel(ptrData);
    set (ptrData.handles.win,'Position',pos);
    set (ptrData.handles.win,'Visible','on');
    
end


function changeColormap (hObject, ptrData, varargin)
    idx = getCheckedItemMenu (ptrData.handles.menu.colormaps, hObject);

    names = fieldnames (ptrData.params.colormaps);
    ptrData.params.colormapName = names{idx};
    ptrData.params.colormap = ptrData.params.colormaps.(names{idx});
    guidata (hObject, ptrData);

    if isfield(ptrData, 'images') && numel(ptrData.images)>0
        colormap(ptrData.params.colormap);
        fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
        feval (fcn, hObject, [], 'changeColormap');
    end
end


function changeSelection (hObject, ptrData, varargin)
    if ~isfield(ptrData, 'images'), return, end
    switch varargin{1}
        case 'all'
            fcn = inline('1');
        case 'none'
            fcn = inline('0');
        case 'invert'
            fcn = inline('~x');
    end
    
    nImg = numel(ptrData.images);
    for i=1:nImg
        v = fcn(ptrData.images(i).selected);
        ptrData.images(i).selected = v;
    end
    
    guidata (hObject, ptrData);
    ptrStatusBar(hObject, 'updateTxt');
    
    % Update UI
    fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
    feval (fcn, hObject, [], 'updateData', 'check', 1:nImg);
end


function changeView (hObject, ptrData, varargin)
    idx = getCheckedItemMenu (ptrData.handles.menu.view, hObject);
    ptrData.params.displayMode = idx;
    guidata (hObject, ptrData);    
    ptrSetMainPanel(ptrData)    
end


function resizeWindow (hObject, ptrData, varargin)
    currentPos = get(ptrData.handles.win,'Position');
    diff = ptrData.params.mainWinSize - currentPos(3:4);

    if any(diff ~= 0)
        ptrData.params.mainWinSize = currentPos(3:4);
        guidata(hObject, ptrData);
            
        if isfield(ptrData.handles, 'mainPanel') 
           fcn = ptrData.params.displayModeCb{ptrData.params.displayMode};
           feval (fcn, hObject, [], 'changeWindowSize', diff);
        end
        ptrStatusBar(hObject, 'updateSize', diff);
    end
end


function idx = getSelectedIdx (ptrData)
    idx = [];
    if ~isfield(ptrData, 'images') || numel(ptrData.images)<1, return, end
    
    sel = zeros (numel(ptrData.images),1);
    for i=1:numel(sel)
        if ptrData.images(i).selected, sel(i) = 1; end
    end
    idx = find(sel)';
end


function idx = getCheckedItemMenu (hMenu, hItem, varargin)
    idx = 0;
    for i=1:numel(hMenu.item)
        set (hMenu.item(i), 'Checked', 'off');
        if hMenu.item(i) == hItem
            set (hMenu.item(i), 'Checked', 'on');
            idx = i;
        end
    end
end

