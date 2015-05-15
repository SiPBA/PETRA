function [error, msj, feats, options] = vaf (args)
    error = 0; msj= ''; feats = []; options = []; 
    P = size(args.imgs, 1);
    h = waitbar(0,'Realizando Vaf ...');
    for i=1:P
        waitbar(i/P);
        img = squeeze (args.imgs(i,:,:,:));
        data = vaf_img (img, args.params);
        if isempty(feats), feats = zeros (P, numel (data)); end
        feats (i,:) = data;
    end
    close(h);

    
function feats = vaf_img (img, params)
    VS = get_params (params, 1);

    if VS == 1, 
        feats = img (:);
    else
        [Z Y X] = size(img);
        re_size = [floor(Z/VS) floor(Y/VS) floor(X/VS)];

        for i=1:Z
            median(i,:,:) = imresize(squeeze(img(i,:,:)),[re_size(2) re_size(3)]);
        end
        for j=1:re_size(2)
            medians(:,j,:) = imresize(squeeze(median(:,j,:)), [re_size(1) re_size(3)]);
        end
        feats = medians (:);
    end

    % Normalizacion
    feats = feats - min(feats);
    feats = feats ./ max(feats);

    
    