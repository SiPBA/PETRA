function [error, msj, res] = run_pls (action, args)
    error = 0;
    msj = '';

    if strcmp (action, 'train')

        %Parametros del metodo: (Se pueden pedir por pantalla)
        th = 0.5;    % Umbral de intensidad 
        sc = 2;      % Reduce imagenes por un factor sc
        nComp = 10;  % Num del scores pls usados
        
        %Aplica mascara
        mediaNorm = squeeze(mean(args.imgs(args.labels==0,:,:,:),1));
        th= th * max(args.imgs(:));
        mascara = mediaNorm > th;
        voxels = args.imgs(:,mascara);
        
        %Extrae PLS scores
        if min(size(voxels))<=nComp, nComp = min(size(voxels)) - 1; end
        [xl, yl, xs, ys, beta, aux, mse, stats] = plsregress (voxels, ...
            args.labels, nComp);

        %Calcula PLS brains
        [p,x,y,z] = size (args.imgs);
        plsb = reshape(xl', size(xl,2), size(voxels,2));
        plsb1 = zeros(x,y,z);
        plsb2 = zeros(x,y,z);
        plsb1(mascara) = plsb(1,:);
        plsb2(mascara) = plsb(2,:);
        
        %Clasifica
        groups = sort(unique(args.labels));
        if numel(groups)>2
            args.labels(args.labels >= groups(2)) = groups(2);
            msgbox('Sólo se tendrán en cuenta las dos primeras clases','Aviso');
        end
        svmStruct = svmtrain(xs,args.labels);

        res.ncomp = nComp;
        res.w = stats.W;
        res.media = mean (voxels, 1);
        res.mascara = mascara;
        res.clasif = svmStruct;

        res.graf.plsb1 = plsb1;
        res.graf.plsb2 = plsb2;
        res.graf.feats = xs(:,1:2);
        res.graf.labels = args.labels;
        
    elseif strcmp(action, 'classify')
        
        options = args.train;
        voxels = args.imgs (:,options.mascara);
        voxels = bsxfun(@minus, voxels, options.media);
        
        feats = zeros (size(voxels,1), size(options.w,2));
        for i=1:size(voxels,1)
            feats(i,:) = voxels(i,:) * options.w;
        end
        
        class = svmclassify(args.train.clasif,feats);
        
        % Muestra PLS brains y el resultado de la clasificacion
        %[p,x,y,z] = size (args.imgs);

        
        f = figure('Name','Diagnóstico estimado','MenuBar','none',...
                   'Toolbar','none') ;
        subplot (2,2,3)
        for i=1:size(args.train.graf.plsb1,1), 
            plsb1(:,:,1,i) = squeeze(args.train.graf.plsb1(i,:,:));
        end
        montage (plsb1,'DisplayRange', [min(plsb1(:)),max(plsb1(:))]);

        subplot (2,2,4)
        for i=1:size(args.train.graf.plsb2,1), 
            plsb2(:,:,1,i) = squeeze(args.train.graf.plsb2(i,:,:));
        end
        montage (plsb2,'DisplayRange', [min(plsb2(:)),max(plsb2(:))]);
        colormap (jet);
        
        subplot(2,2,[1 2])
        svmtrain(args.train.graf.feats,args.train.graf.labels,'showplot',true);
        title (['La clase estimada es ' args.clases{class+1}])
        res = [];
    end
        
        