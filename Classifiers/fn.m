function res = fn (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = fn_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = fn_class(trn,data);
    else
        res = -1;
    end
    
    
function trn = fn_train (data,labels,params)
    net = newff(data', labels', 3);
    trn = train(net, data', labels');    
    
function res = fn_class (trn, data)
    class = sim(trn.trn, data')>0.5;
    res.accuracy = class;
    