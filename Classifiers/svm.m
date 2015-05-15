function res = svm (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = svm_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = svm_class(trn,data);
    else
        res = -1;
    end
    
    
function trn = svm_train (data,labels,params)
    groups = sort(unique(labels));
    if numel(groups)>2
        labels(labels >= groups(2)) = groups(2);
        msgbox('Sólo se tendrán en cuenta las dos primeras clases','Aviso');
    end

    [kernel, sigma] = get_params (params, 'linear', 3);
    if strcmp(kernel, 'rbf')
        trn = svmtrain(data,labels,'Kernel_Function',kernel,'RBF_Sigma',sigma);
    else
        trn = svmtrain(data,labels,'Kernel_Function',kernel);
    end
    
function res = svm_class (trn, data)
    class = svmclassify(trn.trn, data);
    res.accuracy = class;
