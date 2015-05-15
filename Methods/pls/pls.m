function [error, msj, feats, options] = plsb(args)
error = 0; msj = ''; options = args.options; nComp = args.params;
if isfield(args,'labels'), if isrow(args.labels), args.labels=args.labels'; end, end

if isempty (options)
    y=args.imgs;
    y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));
    eignbr = plsregress(y_cent,args.labels>0,nComp);
    eignbr=eignbr';
    [s1 s2 s3 s4]= size(args.imgs);
    options=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
   
end

feats= args.imgs(:,:)*options(1:nComp,:)';
end