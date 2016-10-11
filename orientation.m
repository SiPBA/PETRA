function [imgs_o,ov,cm_sum_mean_vert,vari_vert,ocheckhorz,vari_horz]=orientation(imgs,tiporf)

%Calcula la orientacion de la imagen img de tamaño XxYxZ.
%devuelve un vector de 3 componentes con valores comprendidos entre -3 y 3
%y la imagen orientada correctamente, de forma que:


A=size(imgs);
posdim=[1 2 3];
BW=zeros(A);
level=graythresh(imgs(:,:));
if level==0;
    level=0.1;
end

for i=1:A(3)
    
    imint=im2bw(imgs(:,:,i),level);
    se = strel('disk',1);
    imintop=imopen(imint,se);
    BW(:,:,i)=imfill(squeeze(imintop),'holes');
    
end

%%%%%%%%%%%
% Encuentra las lineas:
% dim1 = la linea oreja-oreja
% dim2 = la linea frente-cogote
% dim3 = la linea coronilla-cuello
%%%%%%%%%%%%

cc=bwconncomp(BW);
stats=regionprops(cc);fprintf('.')
[~,rg]=max([stats.Area]);

reBoundingBox(1)=stats(rg).BoundingBox(2);
reBoundingBox(2)=stats(rg).BoundingBox(1);
reBoundingBox(3)=stats(rg).BoundingBox(3);
reBoundingBox(4)=stats(rg).BoundingBox(5);
reBoundingBox(5)=stats(rg).BoundingBox(4);
reBoundingBox(6)=stats(rg).BoundingBox(6);


%% Encuentra el eje mayor (coincidirá con la linea frente-cogote)
%%ax,ax1,vga1,vga2,ccoerf1,ccoerf2,pes,

[~,x]=max(reBoundingBox);
dim2=(x-3==posdim);

%% Encuentra el eje  con la linea oreja-oreja)
%%


dimes=find(~dim2);

Ct=squeeze(sum(imgs,find(dim2)));
windowt=Ct(ceil(reBoundingBox(dimes(1))):floor(reBoundingBox(dimes(1))+reBoundingBox(dimes(1)+3)),ceil(reBoundingBox(dimes(2))):floor(reBoundingBox(dimes(2))+(reBoundingBox(dimes(2)+3))));
ccr1=normxcorr2(flipdim(windowt,1),Ct);
ccr2=normxcorr2(flipdim(windowt,2),Ct);
ccoerf1=max(ccr1(:));
ccoerf2=max(ccr2(:));

if ccoerf1>ccoerf2
    canddim=1; 
else
    canddim=2;  
end
 dim1=[false false false];
 dim1(dimes(canddim))=true;


%% Encuentra el eje restante (coincidirá con la linea coronilla-cuello)
%%


dim3=~or(dim1,dim2);

% Perumta la imagen de modo que la direccion Z sea la 1 la oreja-oreja la 3

ori_vect(3)=posdim(dim1);
ori_vect(2)=posdim(dim2);
ori_vect(1)=posdim(dim3);
fprintf('.')
ov=ori_vect;

if ~all(ori_vect==posdim)
    imgs_op=permute(imgs,ori_vect);
    BWN=permute(BW,ori_vect);
else
    imgs_op=imgs;
    BWN=BW;
end


% ORIENTACION AXIAL: Determina si la orientacion del eje frente-cogote es correcta

BWS2=squeeze(sum(BWN,1));
s2=sum(BWS2,2);vari_horz=s2(s2>0); 
N=5;
x=-numel(vari_horz):numel(vari_horz); y=gaussmf(x,[numel(vari_horz)/N 0]);
corcruzf=xcorr(flipud(vari_horz),y);
corcruz =xcorr(vari_horz,y);
mpic=max(corcruz);
[~,maxdif]=max(corcruz(corcruz>mpic/100)-corcruzf(corcruzf>mpic/100));%gradient(xcorr(flipud(vari_horz),vari_horz)));%max(vari_horz-flipud(vari_horz));
[~,mindif]=min(corcruz(corcruz>mpic/100)-corcruzf(corcruzf>mpic/100));%gradient(xcorr(flipud(vari_horz),vari_horz)));%min(vari_horz-flipud(vari_horz));


BWS2p=squeeze(sum(imgs_op,1));
s2o=max(BWS2p,[],2);
ax= find(s2==max(s2),1)-find(s2o==max(s2o),1); %diferencia basada en el maximo central comparado con el máximo en los estriados

if tiporf == 303 %SPECT DaTSCAN
    ocheckhorz=(ax<=0);
else
    ocheckhorz=((maxdif-mindif)<=0);
end


% ORIENTACION SAGITAL: Determina la orientacion del eje coronilla-cuello

for i=ceil(reBoundingBox(find(dim3))):floor(reBoundingBox(find(dim3)))+reBoundingBox(find(dim3)+3)-1
    gradient_vert(i,:,:)=BWN(i+1,:,:)-BWN(i,:,:);    
    vari_vert(i)=var(gradient_vert(i,abs(gradient_vert(i,:))>0));
end

cm_sum_mean_vert= (mean(cumsum(fliplr(vari_vert)))>=mean(cumsum(vari_vert)));%(mean(find(area==max(area)))>(numel(area)/2));
ocheckvert=(~cm_sum_mean_vert);





if ocheckvert % si es positivo quiere decir que la linea es coronilla-cuello
    imgs_op=flipdim(imgs_op,1);
    imgs_op=flipdim(imgs_op,3);
    ov(2)=-ov(2);
end
if ocheckhorz
    imgs_op=flipdim(imgs_op,2);
    imgs_op=flipdim(imgs_op,3);
    ov(3)=-ov(3);
end

imgs_o=imgs_op;



fprintf('. \n')
end


