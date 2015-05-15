function representar_results(res)
f=figure('Name','Diagnostico estimado') ;%,'MenuBar','none',...
% 'Toolbar','none') ;
col=get(f,'Color');
args=res.args;
args.strix1=res.strix1;
args.strix2=res.strix2;
feats=res.feats;
class=res.class;
dim=res.dimplot;

% Reescala los datos para el plot
% for i=1:dim
% mi(i)=min(args.train.feats(:,i));
% args.train.feats(:,i)=args.train.feats(:,i)-mi(i);
% me(i)=max(args.train.feats(:,i));
% args.train.feats(:,i)=args.train.feats(:,i)./me(i);
% feats(:,i)=(feats(:,i)-mi(i))./me(i);
% end

if numel(size(args.train.options))==4
    subplot (4,2,[1 3])
    eign1=squeeze(args.train.options(1,:,:,:));
    %[eign1]=orientation(abs(eign1));
    for i=1:size(eign1,1), stack(:,:,size(eign1,1)-i+1)=eign1(i,:,:); end
    pcamb1(:,:,1,:) = stack ;
    montage (pcamb1,'DisplayRange', [min(pcamb1(:)),max(pcamb1(:))]);
    colorbar
    title (res.strix1)
    colormap (jet);
    xlabel(['Score = ' num2str(feats(1,1))]);
    
    if size(args.train.options,1)>1
        subplot (4,2,[5 7])
        eign2=squeeze(args.train.options(2,:,:,:));
        %[eign2]=orientation(abs(eign2));
        for i=1:size(eign2,1), stack2(:,:,size(eign2,1)-i+1)=eign2(i,:,:); end
        pcamb2(:,:,1,:) = stack2 ;
        montage (pcamb2,'DisplayRange', [min(pcamb2(:)),max(pcamb2(:))]);
        colorbar
        title (res.strix2)
        colormap (jet);
        xlabel(['Score = ' num2str(feats(1,2))]);
    end
end
subplot(4,2,[4 6 8])

scaterplot(args,feats, dim)

subplot(4,2,2,'Color','none','XColor',col,'YColor',col)
if class==0, text(0.5,0.5,{['La clase estimada es \color[rgb]{0 0 1}' args.clases{class+1}]},...
        'FontSize',14,'HorizontalAlignment','center','BackgroundColor',[1 1 1]) %title (['\fontsize{16} ])
elseif class==1,
    text(0.5,0.5,{['La clase estimada es \color[rgb]{1 0 0}' args.clases{class+1}]},...
        'FontSize',14,'HorizontalAlignment','center','BackgroundColor',[1 1 1])
end


end

function scaterplot(args,feats,dim)

if size(feats)==1
    feats(:,2)=feats(:,1);
    args.train.feats(:,2)=args.train.feats(:,1);
end

if dim<3
    nclases = unique(args.train.labels);
    
    hold on
    estilos = {'.b','.r','.m','.y'};
    for i=1:numel(args.clases)
        h1=plot(args.train.feats(args.train.labels==nclases(i),1),...
            args.train.feats(args.train.labels==nclases(i),2),...
            estilos{mod(i-1,numel(estilos))+1},...
            'DisplayName',args.clases{i});
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
        h1=plot3(args.train.feats(args.train.labels==nclases(i),1),...
            args.train.feats(args.train.labels==nclases(i),2),...
            args.train.feats(args.train.labels==nclases(i),3),...
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