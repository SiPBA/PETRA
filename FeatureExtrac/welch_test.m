function [error, msj, feats, options] = welch_test (args)
    error = 0; msj = ''; feats = []; options = args.options;
    [th, percentil, scaling] = get_params (args.params, 0.08, 70, 2);

    if scaling > 1
        [xi,yi,zi] = meshgrid (1:scaling:size(args.imgs,3), ...
                               1:scaling:size(args.imgs,2), ...
                               1:scaling:size(args.imgs,4));
        for p = 1:size(args.imgs, 1);
            ims (p,:,:,:) = interp3(squeeze(args.imgs(p,:,:,:)),xi,yi,zi);
        end
        args.imgs = ims;
        clear ims;
    end

    if isempty (options)
        Imean_nor = squeeze (mean (args.imgs((args.labels == 0),:,:,:)));
        Imean_dta = squeeze (mean (args.imgs((args.labels == 1),:,:,:)));
        Imean_nor_dta = Imean_nor - Imean_dta;
        mask = Imean_nor_dta > th;

        Istd_nor = squeeze(std(args.imgs((args.labels == 0),:,:,:)));
        Istd_dta = squeeze(std(args.imgs((args.labels == 1),:,:,:)));
        Nnor = sum(args.labels == 0);
        Ndta = sum(args.labels == 1);
        Imagen_meanstd = Imean_nor_dta ./ sqrt(Istd_nor.^2/Nnor + Istd_dta.^2/Ndta);

        threshold = prctile(Imagen_meanstd(:), percentil);
        mask = (Imagen_meanstd > threshold) & (Imean_nor_dta > th);
        options.mask = mask;
    end

    feats(:,1) = mean(args.imgs(:,options.mask(:,:,:))')';
    feats(:,2) = std(args.imgs(:,options.mask(:,:,:))')';        

        
        