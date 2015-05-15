function ptrParamsUnload(params)
    opt.displayMode = params.displayMode;
    opt.colormapName = params.colormapName;
    opt.langSelected = params.langSelected;
    opt.dir = params.dir;
    %opt.mainWinSize = params.mainWinSize;
    
    save (params.optionsFile, '-struct', 'opt');
    clear global petraParams
end
