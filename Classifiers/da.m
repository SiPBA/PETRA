function res = da (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = da_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = da_class(trn,data);
    else
        res = -1;
    end
    
    
function trn = da_train (data,labels,params)
    kernel = get_params (params, 'linear');
    trn = [];
    trn.kernel = kernel;
    trn.data = data;
    
    
function res = da_class (trn, data)
    class = classify(data, trn.trn.data, trn.labels, trn.trn.kernel);
    res.accuracy = class;
