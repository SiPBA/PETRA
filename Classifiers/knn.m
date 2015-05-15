function res = knn (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = knn_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = knn_class(trn,data);
    else
        res = -1;
    end
    
    
function trn = knn_train (data,labels,params)
    k = get_params (params, 3);
    trn = [];
    trn.k = k; if(isnan(k)),trn.k=5;end
    trn.data = data;
    
    
function res = knn_class (trn, data)
    class = knnclassify(data, trn.trn.data, trn.labels, trn.trn.k);
    res.accuracy = class;
    