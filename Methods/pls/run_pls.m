function [error, msj, res] = run_pls (action, args)
error = 0;
msj = '';

if strcmp (action, 'train')
    
    %Parametros del metodo: (Se pueden pedir por pantalla)
    nComp = 10;    % Numero de Componentes para la extrac. de caract.
    clasif = 'svm';  % Clasificador
    pclasif = '';    % Parametros del clasificador
    
    minComp = min(size(args.imgs))-1;
    if nComp>minComp, nComp = minComp; end
    
    % Aqui se puede aplicar mascara a las imagenes o reducir su
    % dimension. Esto antes se hac�a en ppal pero ya no se hace.
    
    % Extrae caracteristicas
    if ~isfield(args,'feats')
    args_met.imgs = args.imgs;
    args_met.labels = args.labels;
    args_met.params = nComp;
    args_met.options = [];
    [error, msj, feats, options] = pls (args_met);
    if error==1, return, end
    else
        feats=args.feats;
        options=args.options;
    end
    
    res.feats = feats;
    res.options = options;
    res.params = nComp;
    res.clasif = clasif;
    res.pclasif = pclasif;
    res.labels =  args.labels;
    
    % Entrenamiento del clasificador
    res.rclasif.trn = feval (clasif, 'train', feats, args.labels>0, '', pclasif);
    
    
elseif strcmp(action, 'classify')
    
    %Si se aplic� m�scara o se redujo la dimension de las imagenes,
    %aqu� tambi�n debe hacerse
    
    % Extrae caracteristicas

    args_met.imgs = args.imgs;
    args_met.params = args.train.params;
    args_met.options = args.train.options;
    [error, msj, feats] = pls (args_met);
    if error==1, return, end

    
    % Clasifica
    class = feval (args.train.clasif, 'classify', feats, '', ...
        args.train.rclasif, args.train.pclasif);
    class = class.accuracy;
    
    %Guarda el resultado 
    res.args = args;
    res.feats=feats;
    res.class=class;
    res.strix1='Plsbrain 1';
    res.strix2='Plsbrain 2';
    
    
    %res.figuras = {'Espacio de caracter�sticas en 2D', ...
    %               'Espacio de caracter�sticas en 3D', ...
    %               'Plsbrain 1', 'Plsbrain 2'};
    res.figFunction = 'representar_results2';
    res.comps = 1:size(res.feats,2);
end

