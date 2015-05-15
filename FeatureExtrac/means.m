function [error, msj, feats, options] = means (args)
    error = 0; msj= ''; feats = []; options = []; 
    P = size(args.imgs, 1);
    h = waitbar(0,'Realizando Means ...');
    for i=1:P
        waitbar(i/P);
        img = squeeze (args.imgs(i,:,:,:));
        data = sum(img(:)) / numel(img);
        if isempty(feats), feats = zeros (P, numel (data)); end
        feats (i,:) = data;
    end
    close(h);

