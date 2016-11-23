function params = ptrParamsLoad()
    params = [];

    params.pathMain = fileparts(which('petra'));
    if isdeployed, params.pathMain = pwd; end

    params.langFile = [params.pathMain filesep 'lang.csv'];
    params.colormapsFile = [params.pathMain filesep 'colormaps.cmp'];
    params.optionsFile = [params.pathMain filesep 'options.cfg'];
    params.licenceFile = [params.pathMain filesep 'licence.txt'];
    params.creditsFile = [params.pathMain filesep 'credits.txt'];
    params.iconsFile = [params.pathMain filesep 'icons.png'];
    
    params.iconsOrder = {'open','save','close','go_left','go_right',...
                         'play','stop','question','sliceAll','sliceOne',...
                         'hand','rotate','zoom_in','zoom_out','zoom_reset'};

    params.pathMethods = [params.pathMain filesep 'Methods'];
    params.pathTrn = [params.pathMain filesep 'Trainings'];
    params.pathTpl = [params.pathMain filesep 'Templates'];
    params.pathFeatureExtrac = [params.pathMain filesep 'FeatureExtrac'];
    params.pathClassifiers = [params.pathMain filesep 'Classifiers'];
    
    params.statusBarHeight = 28;
    params.displayModeFcn = {'ptrDsList','ptrDsGrid','ptrDsSecuence'};
    params.displayModeCb = {'ptrCbList','ptrCbGrid','ptrCbSecuence'};
    
    params.version = 'v. 1.0';
    params.relDate = '2013';
    
    % Load configuration options
    if exist(params.optionsFile, 'file') == 2
        options = load (params.optionsFile, '-mat');
        for i=fieldnames(options)', params.(i{1}) = options.(i{1}); end
    end
    
    % Options not loaded are asigned their default value
    if ~isfield(params, 'displayMode'), params.displayMode = 1; end
    if ~isfield(params, 'colormapName'), params.colormapName = 'iron'; end
    if ~isfield(params, 'langSelected'), params.langSelected = 'EN'; end
    if ~isfield(params, 'mainWinSize'), params.mainWinSize = [600 600]; end
    if ~isfield(params, 'mainWinPos'), 
        set (0, 'Units', 'pixels');
        screenSize = get (0, 'ScreenSize');
        params.mainWinPos = [round((screenSize(3) - params.mainWinSize(1))/2) ...
                             round((screenSize(4) - params.mainWinSize(2))/2)]; 
    end
    if ~isfield(params, 'dir') || ~exist(params.dir, 'dir')
        params.dir = [params.pathMain filesep 'Examples'];
    end
   
    % Load language file
    [params.langData, params.langStrings] = ptrLgLoad(params.langFile);
    
    % Save laguage strings in global variable
    global petraParams;
    petraParams.langStrings = params.langStrings.(params.langSelected);

    % Load colormaps
    params.colormaps = load (params.colormapsFile, '-mat');
    params.colormap = params.colormaps.(params.colormapName);
    
    % List-View params
    params.listView.sliceAxesW = 150;
    params.listView.sliceAxesH = 150;
    params.listView.volPanelW = params.listView.sliceAxesW * 3 + 10 * 4;
    params.listView.volPanelH = params.listView.sliceAxesH + 10*4 + 18*2;
    params.listView.volPanelMarginW = 10;
    params.listView.volPanelMarginH = 10;
    params.listView.volsColumns = 1;
    params.listView.volsRows = 1;
    
    % Image modalities supported
    %params.imgTypes = {'SPECT ECD' 'SPECT DaTSCAN' 'PET FDG' 'MRI'};
    params.imgTypes = {...
        101 'Structural MRI (gray and white matter and CSF)'; ...
        102 'Structural MRI (only gray matter)'; ...
        103 'Structural MRI (only white matter)'; ...
        301 '99mTc-HMPAO SPECT'; ...
        302 '99mTc-ECD SPECT'; ...
        303 '123I-Ioflupane SPECT (DaTSCAN)'; ...
        401 '18F-FDG PET'; ...
        402 '18F-DMFP PET'};

    % Bug flag
    [v,d] = version();
    params.bugNestedPanels = year(d) < 2015;
    
end
