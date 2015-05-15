function representar_results2(comps, res, hScatter, hEBs)

if numel(size(res.args.train.options))==4
    for c=1:numel(comps)
        eign = squeeze(res.args.train.options(comps(c),:,:,:));
        %for i=1:size(eign,1), stack(:,:,1,size(eign,1)-i+1)=eign(i,:,:); end
        for i=1:size(eign,1), stack(:,:,1,i)=eign(i,:,:); end
        axes (hEBs(c));
        montage (stack,'DisplayRange', [min(stack(:)),max(stack(:))]);
        set(hEBs(c),'XAxisLocation','top');
        colorbar;
        colormap (res.args.colormap);
        xlabel(['Comp. ' num2str(comps(c)) ...
                ' (Score = ' num2str(res.feats(1,comps(c))) ')']);
        hlabel = get(hEBs(c),'XLabel');
        set(hlabel,'Position',get(hlabel,'Position') + [0 50 0])
    end
end
       
    axes (hScatter);
    args=res.args;
    args.strix1=res.strix1;
    args.strix2=res.strix2;
    if numel(comps) == 1
        feats(1,1) = res.feats(1,comps(1));
        feats(1,2) = 0;
        args.train.featsn(:,1)=args.train.feats(:,comps(1));
        args.train.featsn(1:size(res.args.train.feats,1),2)=0;
        scaterplot (args, feats, numel(unique(comps)));
    elseif numel(comps) == 2
        feats(1,1) = res.feats(1,comps(1));
        feats(1,2) = res.feats(1,comps(2));
        args.train.featsn(:,1)=args.train.feats(:,comps(1));
        args.train.featsn(:,2)=args.train.feats(:,comps(2));
        scaterplot (args, feats, numel(unique(comps)));
    elseif numel(comps) == 3
        feats(1,1) = res.feats(1,comps(1));
        feats(1,2) = res.feats(1,comps(2));
        feats(1,3) = res.feats(1,comps(3));
        args.train.featsn(:,1)=args.train.feats(:,comps(1));
        args.train.featsn(:,2)=args.train.feats(:,comps(2));        
        args.train.featsn(:,3)=args.train.feats(:,comps(3));
        scaterplot (args, feats, numel(unique(comps)));
    end
    
    return;

    if num==1 % Scatter 2D
        axes (h);
        args=res.args;
        args.strix1=res.strix1;
        args.strix2=res.strix2;
        scaterplot (args, res.feats, 2)
        
    elseif num==2 % Scatter 3D
        axes (h);
        args=res.args;
        args.strix1=res.strix1;
        args.strix2=res.strix2;
        scaterplot (res.args, res.feats, 3)
        
    elseif num==3 % Eigenbrain 1
        eign1=squeeze(res.args.train.options(1,:,:,:));
        %for i=1:size(eign,1), stack(:,:,1,size(eign,1)-i+1)=eign(i,:,:); end
        for i=1:size(eign1,1), stack(:,:,1,i)=eign1(i,:,:); end
        axes (h);
        montage (stack,'DisplayRange', [min(stack(:)),max(stack(:))]);
        colorbar
        colormap (res.args.colormap);
        xlabel(['Score = ' num2str(res.feats(1,1))]);
        
    elseif num==4 % Eigenbrain 2
        eign2=squeeze(res.args.train.options(2,:,:,:));
        %for i=1:size(eign,1), stack(:,:,1,size(eign,1)-i+1)=eign(i,:,:); end
        for i=1:size(eign2,1), stack2(:,:,1,i)=eign2(i,:,:); end
        axes (h);
        montage (stack2,'DisplayRange', [min(stack2(:)),max(stack2(:))]);
        colorbar
        colormap (res.args.colormap);
        xlabel(['Score = ' num2str(res.feats(1,2))]);
        
    else
        msgbox('Figura no implementada','Error');
    end
end


function scaterplot(args,feats,dim)



if dim<3
    nclases = unique(args.train.labels);
    
    estilos = {'.b','.r','.m','.y'};
    for i=1:numel(args.clases)
        h1=plot(args.train.featsn(args.train.labels==nclases(i),1),...
            args.train.featsn(args.train.labels==nclases(i),2),...
            estilos{mod(i-1,numel(estilos))+1},...
            'DisplayName',args.clases{i});
        if i==1, hold on; end
    end
    plot(feats(:,1),feats(:,2),'MarkerFaceColor','k','Marker','o',...
        'MarkerEdgeColor','k','LineStyle','none','DisplayName','TEST IMAGE');
    legend ('show','Location','Best');
    
    hAxis = get(h1,'parent');
    lims = axis(hAxis);
    [X,Y] = meshgrid(linspace(lims(1),lims(2)),linspace(lims(3),lims(4)));
    Xorig = X; Yorig = Y;
    
    if strcmp(args.strix2,'Votes Map')
        plot([0 1],[1 0],'k')
    elseif dim==1
        hold off
    else
        [~ , Z] = deci([X(:),Y(:)],args,dim);
        contour(Xorig,Yorig,reshape(Z,size(X)),[0 0],'k');
        hold off
    end
    xlabel(args.strix1);
    ylabel(args.strix2);
elseif dim==3
    nclases = unique(args.train.labels);
    plot3(feats(:,1),feats(:,2),feats(:,3),'MarkerFaceColor','k','Marker','o',...
        'MarkerEdgeColor','k','LineStyle','none','DisplayName','TEST IMAGE');
    hold on
    estilos = {'.b','.r','.m','.y'};
    for i=1:numel(args.clases)
        h1=plot3(args.train.featsn(args.train.labels==nclases(i),1),...
            args.train.featsn(args.train.labels==nclases(i),2),...
            args.train.featsn(args.train.labels==nclases(i),3),...
            estilos{mod(i-1,numel(estilos))+1},...
            'DisplayName',args.clases{i});
    end
    
    legend ('show','Location','Best')
    
    hAxis = get(h1,'parent');
    lims = axis(hAxis);
    [Xc,Yc,Zc] = meshgrid(linspace(lims(1),lims(2)),linspace(lims(3),lims(4)),linspace(lims(5),lims(6)));
    
    [~ , Z] = deci([Xc(:),Yc(:),Zc(:)],args,dim);
    
    hpatch = patch(isosurface(Xc,Yc,Zc,reshape(Z,size(Xc)),0));
    isonormals(Xc,Yc,Zc,reshape(Z,size(Xc)),hpatch)
    set(hpatch,'FaceColor','red','EdgeColor','none')
    view([-126,36]);
    axis tight
    camlight left;
    set(gcf,'Renderer','zbuffer');
    lighting phong;
    grid;
    hold off;
    
else
    return
end
end

function [out,f] = deci(Xnew,args,dim)
%SVMDECISION evaluates the SVM decision function

%   Copyright 2004-2006 The MathWorks, Inc.
%   $Revision: 1.1.12.4 $  $Date: 2006/06/16 20:07:18 $
clasif=args.train.clasif;

if strcmp(clasif,'svm')
    args.train.rclasif.trn.SupportVectors=args.train.rclasif.trn.SupportVectors(:,1:dim);
    svm_struct=args.train.rclasif.trn;
    if ~isempty(svm_struct.ScaleData)
        for c = 1:size(Xnew, 2)
            Xnew(:,c) = svm_struct.ScaleData.scaleFactor(c)*(Xnew(:,c) +  svm_struct.ScaleData.shift(c));
        end
    end
    
    sv = svm_struct.SupportVectors;
    alphaHat = svm_struct.Alpha;
    bias = svm_struct.Bias;
    kfun = svm_struct.KernelFunction;
    kfunargs = svm_struct.KernelFunctionArgs;
    
    f = (feval(kfun,sv,Xnew,kfunargs{:})'*alphaHat(:)) + bias;
    out = sign(f);
    % points on the boundary are assigned to class 1
    out(out==0) = 1;
    
elseif strcmp(clasif,'knn')
    Xc=Xnew(:,1);Yc=Xnew(:,2);Zc=Xnew(:,3);
    N=size(Xc,1);
    for xc=1:N
        for yc=1:N
            for zc=1:N
                f(xc,yc,zc)= knnclassify([Xc(xc,yc,zc) Yc(xc,yc,zc) Zc(xc,yc,zc)],args.train.feats,args.train.labels);
            end
        end
    end
elseif strcmp(clasif,'da')
    Xc=Xnew(:,1);Yc=Xnew(:,2);Zc=Xnew(:,3);
    N=size(Xc,1);
    for xc=1:N
        for yc=1:N
            for zc=1:N
                f(xc,yc,zc)= classify([Xc(xc,yc,zc) Yc(xc,yc,zc) Zc(xc,yc,zc)],args.train.feats,args.train.labels);
            end
        end
    end
end

end