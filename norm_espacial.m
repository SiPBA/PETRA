function [error, img, str] = norm_espacial (stack, str, imagetype, pathTpl)
    
    error = 0;
    okimgstip={'PET FDG', 'SPECT ECD', 'SPECT DaTSCAN'};
    cl = find(strncmpi(imagetype, okimgstip,numel(imagetype)));
    flags=[];
    
    ruta_img = [tempdir 'tmp_norm.nii'];
    ruta_imn = [tempdir 'wtmp_norm.nii'];
    ruta_mat = [tempdir 'tmp_mat.mat'];
    
    
    switch cl
        case 1
            plantilla=([pathTpl filesep 'PET.nii']);
            WI='';
        case 2
            plantilla=([pathTpl filesep 'SPECT.nii']);
            WI='';
        case 3
            plantilla=([pathTpl filesep 'DATSCAN.nii']);
            WI=ruta_img;
            flags.smosrc=6;
            flags.smoref=6;
            %flags.reg=50; % Apaga la parte no lineal de la normalización
        otherwise
            ptrDlgMessage('$main_NoTemplate','$all_Error');
            return;
    end
    

    % Prepara imagen
    vs = abs ([str.hdr.dime.pixdim(4) str.hdr.dime.pixdim(3) str.hdr.dime.pixdim(2)]);
    stackps=zeros(size(stack,3),size(stack,2),size(stack,1));
    for i=1:size(stack,2), 
        stackps (:,size(stack,2)-i+1,:) = flipud(rot90(squeeze(stack(:,i,:)),3)); 
    end
    strtmp = nifticreate (stackps, 2, vs);
    niftiwrite (strtmp, ruta_img); %quizá sea necesario marcar el origen...
    
    % Normaliza
    global defaults
    if isempty(defaults), spm_defaults; end
    defaults.analyze.flip = 1; % Evita warning
    try
    params = spm_normalise (plantilla, ruta_img, ruta_mat,'',WI,flags);
    wflags.bb=[-78 -112  -51;  78   76   85]; % fija un tamaño estandar para todas las imagenes normalizadas (69x95x79)
    spm_write_sn (ruta_img, params,wflags);
    catch e
        ptrDlgMessage (e.message,'$all_Error');
        error=1;
        return
    end
    
    [img, str] = leer_img (ruta_imn, imagetype);

    % Borra archivos temporales
    old_state = recycle ('off');
    delete (ruta_img);
    delete (ruta_mat);
    recycle (old_state);

