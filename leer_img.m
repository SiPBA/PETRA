function [stack, str]= leer_img(nombre, tipoImg, ruta, orientar)
    if nargin<4, orientar=true; end
    str = []; stack = [];
    
    tipo.rf = tipoImg;
    [~,~, e] = fileparts(nombre); 
    tipo.fmt=lower(e(2:end)); 

    if strcmp(tipo.fmt,'bmp')
        if nargin<3, ruta = fileparts(nombre); end
        lis=dir([ruta filesep '*.bmp']);
        num=numel(lis);
        if num==0, return; end
        for i=1:num, stack(i,:,:)= imread([ruta filesep lis(i).name]); end

        vs = [1 1 1];
        stack = entre0y1(double(stack));
        if orientar, 
            stack=orientation(stack,tipo.rf); 
            for i=1:size(stack,2), 
                stackps (:,size(stack,2)-i+1,:) = rot90(squeeze(stack(:,i,:)),3); 
            end
        else 
            stackps=stack;
        end
        %origin = [size(stackps,1)/2, size(stackps,2)/2,size(stackps,3)/2];
        str = nifticreate (stackps, 2, vs); %, origin); quiza habría que modificar el header para especificar el centro, como lo hace save_nii_hdr
        
    elseif strcmp(tipo.fmt,'ima')
        if nargin<3, ruta = fileparts(nombre); end
        lis=dir([ruta filesep '*.IMA']);
        num=numel(lis);
        if num==0, return; end
        for i=1:num, stack(i,:,:)= dicomread([ruta filesep lis(i).name]); end

        vs = [1 1 1];
        stack = entre0y1(double(stack));
        if orientar, 
            stack=orientation(stack,tipo.rf); 
            for i=1:size(stack,2), 
                stackps (:,size(stack,2)-i+1,:) = rot90(squeeze(stack(:,i,:)),3); 
            end
        else 
            stackps=stack;
        end
        %origin = [size(stackps,1)/2, size(stackps,2)/2,size(stackps,3)/2];
        str = nifticreate (stackps, 2, vs); %, origin); quiza habría que modificar el header para especificar el centro, como lo hace save_nii_hdr
        

    elseif strcmp(tipo.fmt,'dcm')
        img = dicomread(nombre);
        info = dicominfo(nombre);
        
        vs = [1 1 1];
        if isfield(info,'PixelSpacing'), 
            vs(1)= info.PixelSpacing(1);
            vs(2)= info.PixelSpacing(2);
        end
        if isfield(info,'SliceThickness'),
            vs(3) = info.SliceThickness;
        end
        if ismatrix(img)
            clear img
            ruta = fileparts(nombre);
            lis=dir([ruta filesep '*.dcm']);
            num=numel(lis);
            if num==0, return; end
            for i=1:num, img(i,:,:)= dicomread([ruta filesep lis(i).name]); end
        end
        
        stack = entre0y1(double(squeeze(img)));
        if orientar, 
            [stack,ord]=orientation(stack,tipo.rf); 
            for i=1:size(stack,2), 
                stackps (:,size(stack,2)-i+1,:) = rot90(squeeze(stack(:,i,:)),3); 
            end
        else 
            stackps=stack;
            ord=[1 2 3];
        end 
        [~,ordsort]=sort(abs(ord));
        %origin = [size(stack,3)/2, size(stack,2)/2,size(stack,1)/2];
        vsn(3)=vs(ordsort(1));vsn(2)=vs(ordsort(2));vsn(1)=vs(ordsort(3));
        str = nifticreate (stackps, 2, vsn);%, origin); Lo mismo aqui

        

    elseif strcmp(tipo.fmt,'nii') || strcmp (tipo.fmt, 'hdr')
        str = niftiread(nombre);
        stack = entre0y1(double(str.img));
        if orientar, stack=orientation(stack,tipo.rf); end
        
    elseif strcmp(tipo.fmt,'a00') 
        if nargin<3, ruta = fileparts(nombre); end       
        cd(ruta)
        info = interfileinfo(nombre) ;
        stack = interfileread(nombre);
        stack = entre0y1(double(stack));
        vs(1)=info.ScalingFactorMmPixel1;
        vs(2)=info.ScalingFactorMmPixel2;
        vs(3)=info.SliceThicknessPixels;
        str=nifticreate(stack,2,vs);
        
        if orientar, stack=orientation(stack,tipo.rf); end
    
    elseif strcmp(tipo.fmt,'mat') 
        vs = [1 1 1];
        stack = tipo.stack ;       
        stack = entre0y1(double(stack));
       if orientar, 
            stack=orientation(stack,tipo.rf); 
            for i=1:size(stack,2), 
                stackps (:,size(stack,2)-i+1,:) = rot90(squeeze(stack(:,i,:)),3); 
            end
        else 
            stackps=stack;
        end
        %origin = [size(stackps,1)/2, size(stackps,2)/2,size(stackps,3)/2];
        str = nifticreate (stackps, 2, vs); %, origin); quiza habría que modificar el header para especificar el centro, como lo hace save_nii_hdr
        

        
    end
    
    %% Lee  el archivo xml en caso de que la imagen sea de ADNI
%     [ruta_tmp,nombre_tmp]=fileparts(nombre);
%     adni=~isempty(regexp(nombre_tmp,'ADNI','ONCE'));
%     ppmi=~isempty(regexp(nombre_tmp,'PPMI','ONCE'));
%     if or(adni,ppmi)
%         listxml=dir([ruta_tmp '*.xml']);
%         try 
%         i=1;
%         while isempty(regexp(listxml(i).name,nombre_tmp(end-10:end), 'once'))
%             i=i+1;
%             if i==numel(listxml)
%                 break
%             end
%         end
%         file=nombre_tmp;
%         filexml=listxml(i).name;
%         [infor]=read_info(file,filexml,ruta_tmp);
%         if isfield(infor.project.subject,'subjectInfo')
%             clases=infor.project.subject.subjectInfo(1).CONTENT;
%             subject_id=infor.project.subject.subjectIdentifier;
%         else
%             clases=infor.project.subject.researchGroup;
%             subject_id=infor.project.subject.subjectIdentifier;
%         end
%         str.class_label=clases;
%         str.subject_id=subject_id;
%         str.adnic.adni=adni;
%         str.adnic.ppmi=ppmi;
%         catch
%             msgbox('los archivos xml deben estar contenidos en el mismo directorio si quiere leer la info')
%         end
%     end
    
    %%
    
    if isstruct (str), str.format = tipo.fmt; end
end

function [in]=read_info(brain_op,bnamxml_op,directorio)
    if strcmp(brain_op(end-3:end),bnamxml_op(end-7:end-4))
        name_xml=bnamxml_op;
    else
        return
    end
    inform='info.xml';
    copyfile([directorio  name_xml],inform)
    in=xml_read(inform);fprintf('.')
    delete(inform);
    clear name_xml
end

function img = entre0y1(img)
    img(isnan(img))=0;
    img = img - min(img(:));
    img = img / max(img(:));
end
