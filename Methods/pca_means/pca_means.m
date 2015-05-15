
% Devuelve una matriz feats de tama�o PxN, donde P es el n�mero de
% pacientes y N el n�mero de clases diferentes en labels (args.labels ser�
% un vector con 0 en caso Normal, 1 en caso ADT-1, 2 en caso ADT-2, etc...)
function [error, msj, feats, options] = pca_means(args)
error = 0; msj = ''; options = args.options;

if isempty (options)
    clases = unique(args.labels);
    for clase=1:numel(clases)
        y(clase, :) = mean(args.imgs(args.labels==clases(clase),:));
    end
     y_cent=bsxfun(@minus,double(y(:,:)),mean(y(:,:)));  
    [coeff, eignbr] = princomp(y_cent');
    eignbr=eignbr';
    [s1 s2 s3 s4]= size(args.imgs);
    options=reshape(eignbr, size(eignbr,1), s2 ,s3,s4);
end

feats = args.imgs(:,:) * options(:,:)';



