function train = entrenar(trn, stacks, params)
    pathOri = path;
    if ~isdeployed
        addpath (params.pathMethods);
        addpath ([params.pathMethods filesep trn.met]);
        addpath (params.pathClassifiers);
    end

    % Crea lista con los clasificadores disponibles
    clasifs = {};
    lis = dir ([params.pathClassifiers filesep '*.m']);
    for i=1:numel(lis), clasifs{i} = lis(i).name(1:end-2); end

    % Llama al metodo
    args.labels = trn.labels;
    args.imgs = stacks;
    args.clasifs = clasifs;
    args.mascara = trn.mascara;
    if isfield(trn, 'train')
        args.feats = trn.train.feats;
        args.options = trn.train.options;
    end
    try
        [error, msj, train] = feval (['run_' trn.met], 'train', args);
        path (pathOri);
        if error~=0, ptrDlgMessage (msj,'$all_Error'); train = []; end
    catch e
        ptrDlgMessage (e.message,'$all_Error');
        path (pathOri);
        train = [];
    end
end


