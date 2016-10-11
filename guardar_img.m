function ok = guardar_img (stack, str, fmt, desti)
    [n x y] = size(stack); ok = false;
    if strcmp(fmt,'bmp')
        if exist(desti,'dir')~=7, mkdir(desti); end;
        for i=1:n
            img=im2uint8(squeeze(stack(i,:,:)));
            suf=['000' num2str(i)];
            suf=suf(numel(suf)-3:end);
            imwrite(img,[desti filesep 'img' suf '.bmp'],'bmp');
            ok = true;
        end
    else
        if strcmp(fmt,'dcm')
            X = zeros(y,x,1,n);
            for i=1:n
                X(:,:,1,i)=imrotate(squeeze(stack(i,:,:)),90);
            end
            warning ('off','MATLAB:intConvertNonIntVal');
            X=uint8((X/max(X(:))).*255);
            warning ('on','MATLAB:intConvertNonIntVal');
            dicomwrite (X,desti);
            ok = true;

        elseif strcmp(fmt,'nii')
%             img = im2uint16(squeeze(stack));
%             vs = abs (str.hdr.dime.pixdim (2:4));
%             for i=1:size(stack,2), stackps (:,i,:) = rot90(squeeze(img(:,i,:)),3); end
%             for i=1:size(stackps,3), stackpss (:,:,i) = rot90(squeeze(stackps(:,:,i)),2); end
%             strnew = nifticreate(stackpss, 2, vs);
            niftiwrite (str, desti);
            ok = true;

        elseif strcmp(fmt,'hdr')
            img = im2uint16(squeeze(stack));
            vs = abs (str.hdr.dime.pixdim (2:4));
            for i=1:size(stack,2), stackps (:,i,:) = rot90(squeeze(img(:,i,:)),3); end
            for i=1:size(stackps,3), stackpss (:,:,i) = rot90(squeeze(stackps(:,:,i)),2); end
            strnew = nifticreate(stackpss, 1, vs);
            niftiwrite (strnew, desti);
            ok = true;

        elseif strcmp(fmt,'a75')
            img = im2uint8(squeeze(stack));
            vs = abs (str.hdr.dime.pixdim (2:4));
            for i=1:size(stack,2), stackps (:,i,:) = rot90(squeeze(img(:,i,:)),3); end
            for i=1:size(stackps,3), stackpss (:,:,i) = rot90(squeeze(stackps(:,:,i)),2); end
            strnew = nifticreate(stackpss, 0, vs);
            niftiwrite (strnew, desti);
            ok = true;

        end
    end
