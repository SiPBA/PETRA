function res = rtrees (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = rtrees_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = rtrees_class(trn,data);
    else
        res = -1;
    end
    
    
function trn = rtrees_train (data, labels, params)
    str_labels (find (labels==0)) = {'NORMAL'};
    str_labels (find (labels==1)) = {'DTA'};
    trn = classregtree(data, str_labels');
    
    
function res = rtrees_class (trn, data)
    class = strcmp(eval(trn.trn, data), 'DTA');
    res.accuracy = class;
