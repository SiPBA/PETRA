function [error, msj, feats, options] = pls (args)
    error = 0; msj = ''; feats = []; options = args.options;

    if isempty (options)
        nComp = size(args.imgs,1)-2;
        [nComp, th] = get_params (args.params, nComp, 0.5);
                
        mediaNorm = squeeze(mean(args.imgs(args.labels==0,:,:,:),1));
        th= th * max(args.imgs(:));
        mascara = mediaNorm > th;
        voxels = args.imgs(:,mascara);
        
        [xl, yl, xs, ys, beta, aux, mse, stats] = plsregress (voxels, ...
            args.labels, nComp);

        options.ncomp = nComp;
        options.w = stats.W;
        options.media = mean (voxels, 1);
        options.mascara = mascara;
        
        feats = extractFeats (args.labels, voxels, nComp);

    else
        voxels = args.imgs(:,options.mascara);
        voxels = bsxfun(@minus, voxels, options.media);
        
        feats = zeros (size(voxels,1), size(options.w,2));
        for i=1:size(voxels,1)
            feats(i,:) = voxels(i,:) * options.w;
        end
    end
        
    
    
function XS = extractFeats (Y, X, ncomp)
    P = size(X,1);
    XS = zeros(P,ncomp);
    meanX = mean(X,1);
    X0 = bsxfun(@minus, X, meanX);

    hw = waitbar(0,'Extrayendo características ...',...
        'WindowStyle','modal','Resize','off');
    for p=1:P
        train = true(P,1);
        train(p)= false;
        [XL,YL,XSp,YS,BETA,PCTVAR,MSE,stats] = plsregress(X(train,:),Y(train),ncomp); 
        XS(p,:) = X0(p,:) * stats.W;
        waitbar(p/P);
    end    
    close (hw);

