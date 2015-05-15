function [error, msj, feats, options] = fe_pca(args)
error = 0; msj = ''; feats = []; options = args.options;nComp=args.params;

if isempty (options)
    y=args.imgs;
    y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));
    try
        [pca,eignbr]=princomp(y_cent');
    catch
        
        [eignbr,pca]=princomp(y_cent,'econ');
    end
    eignbr=eignbr';
    [s1 s2 s3 s4]= size(args.imgs);
    options=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
   
end

feats= args.imgs(:,:)*options(:,:)';
if nComp < size(feats,2), feats = feats(:,1:nComp); options=options(1:nComp,:,:,:); end
end