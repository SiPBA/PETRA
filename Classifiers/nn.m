function res = nn (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = nn_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = nn_class(trn,data);
    else
        res = -1;
    end
    
    
function trn = nn_train (data,labels,params)
    net = newp(data', labels');
    trn = train(net, data', labels');    
    
function res = nn_class (trn, data)
    class = sim(trn.trn, data');
    res.accuracy = class;
