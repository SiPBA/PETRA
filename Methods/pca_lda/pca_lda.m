function [error, msj, feats, options] = pca_lda (args)
    error = 0; msj = ''; feats = []; options = args.options;

    if isempty (options)
        [pc, m] = get_params (args.params, 7, 1);
        if pc > numel(args.labels)
            error = 1;
            msj = ['El n�mero de componentes principales debe ser menor' ...
                ' que el n�mero de im�genes de entrenamiento'];
            return
        end
 
        tr_data = args.imgs (:,:);
        mask = args.mask ;
        tr_data = tr_data(:,mask);
        [pca_data, data_mean, U] = HD_pca(tr_data, pc);

        options.U = U;
        options.data_mean = data_mean;
        
        LDA_train_labels = args.labels(:) + ones(numel(args.labels),1);
        data_struct = struct('X', pca_data ,'y', LDA_train_labels);
        LDA_model = lda(data_struct, m);
        options.LDA_model = LDA_model;
        feats = real(linproj (pca_data, LDA_model))';
    else
        tr_data = args.imgs(:,:);
        mask = args.mask ;
        tr_data = tr_data(:,mask);
        pca_test = (options.U * (tr_data - options.data_mean)')';
        feats = real(linproj (pca_test', options.LDA_model))';
    end
    
    
        
        
        
function [pca_data, data_mean, U] = HD_pca (data, k)
    [Obs] = size(data,1);
    data_mean = mean(data,1);
    datazm = data - repmat(data_mean,Obs,1);
    L = datazm * datazm';
    [V, D] = eigs(L, k);  % Columnas de V, autovectores de L
    U = V' * datazm;
    pca_data = U * datazm';

    
    
function model = lda(data,new_dim)
    data=c2s(data);
    [dim,num_data] = size(data.X);
    nclass = max( data.y );

    if nargin < 2, new_dim = dim; end

    mean_X = mean( data.X, 2);
    Sw=zeros(dim,dim);
    Sb=zeros(dim,dim);

    for i = 1:nclass,
      inx_i = find( data.y==i);
      X_i = data.X(:,inx_i);

      mean_Xi = mean(X_i,2);
      Sw = Sw + cov( X_i', 1);
      Sb = Sb + length(inx_i)*(mean_Xi-mean_X)*(mean_Xi-mean_X)';
    end

    [V,D]=eig( inv( Sw )*Sb );
    [D,inx] = sort(diag(D),1,'descend');
    model.W = V(:,inx(1:new_dim));
    model.eigval = diag(D);

    model.b = -model.W'*mean_X;

    model.Sw = Sw;
    model.Sb = Sb;
    model.mean_X = mean_X;

    model.fun = 'linproj';

    return;    

    
function out1=linproj(arg1, model)
    if isstruct(arg1),
      [dim,num_data]=size(arg1.X);

      out1.X = model.W'*arg1.X + model.b(:)*ones(1,num_data);
      out1.y = arg1.y;

    else
      [dim,num_data]=size(arg1);
       out1 = model.W'*arg1 + model.b(:)*ones(1,num_data);
    end

    return;    


function out=c2s(in)
    if iscell(in),
      out = struct(in{:});
    else
      out = in;
    end

    return;    

