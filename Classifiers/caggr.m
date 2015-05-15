function res = caggr (option, data, labels, trn, params)
    if strcmp (option, 'train')
        res = caggr_train(data,labels,params);
    elseif strcmp (option, 'classify')
        res = caggr_class(trn,data);
    else
        res = -1;
    end
end
    
    
function trn = caggr_train (data,labels,params)
[kernel, Th] = get_params (params, 'linear', 0.7);
index=find(data.cprecision>Th);[Z Y X]=size(data.cprecision);
[cir3 cir2 cir1]=ind2sub([Z Y X], index);
cir=[cir3 cir2 cir1];
trn.cir=cir;
for j=1:size(cir,1)
  
    cir3=cir(j,1);cir2=cir(j,2);cir1=cir(j,3);
    tr_data_sq=circshift(data.sq,[0 cir(j,:)]);
    indexado=find(tr_data_sq(1,:)>0 & data.imgs(1,:)>0);
    if any(indexado)
        if strcmp(kernel, 'rbf')
            sigma = str2double(params{2});
            if isnan (sigma), sigma = 3; end
            cp = svmtrain(data.imgs(:,indexado),labels,'Kernel_Function',kernel,'RBF_Sigma',sigma);
        else
            cp = svmtrain(data.imgs(:,indexado),labels,'Kernel_Function',kernel);
        end
        trn.cp(cir3,cir2,cir1)=cp;
    else
        trn.cp(cir3,cir2,cir1)=[];
    end

end

end

function res = caggr_class (trn, data)
cont=0;
class=[];
for j=1:size(trn.trn.cir,1)

    cir3=trn.trn.cir(j,1);cir2=trn.trn.cir(j,2);cir1=trn.trn.cir(j,3);
    tr_data_sq=circshift(data.sq,[0 trn.trn.cir(j,:)]);
    indexado=find(tr_data_sq(1,:)>0 & data.imgs(1,:)>0);

    if any(indexado)
        if ~isempty(trn.trn.cp(cir3,cir2,cir1))
        cont=cont+1;
        class(cont) = svmclassify(trn.trn.cp(cir3,cir2,cir1), data(:,indexado));
        end
    end

end


res.accuracy = double(mean(class)>0.5);
end
