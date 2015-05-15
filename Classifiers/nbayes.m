function res = nbayes (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = nbayes_train(data,labels);
    elseif strcmp (option, 'classify')
        res = nbayes_class(trn,data);
    else
        res = -1;
    end
    
            
function trn = nbayes_train (data,labels)    
    trn = NaiveBayes.fit(data, labels);
    
function res = nbayes_class (trn, data)
    class = double(predict(trn.trn, data));
    res.accuracy = class;
