function [error, imgNorm, hdrNorm] = ptrNormSpa (img, hdr, imgType, pathTpl)
    
    error = 1; imgNorm = []; hdrNorm = [];
    
    pathImg = [tempdir 'tmp_norm.nii'];
    pathImgNorm = [tempdir 'wtmp_norm.nii'];
    pathMat = [tempdir 'tmp_norm_sn.mat'];
    
    % Select template
    weight = ''; smosrc = 8; smoref = 0;
    switch imgType
        case 401
            template = [pathTpl filesep 'PET.nii'];
        case 402
            template = [pathTpl filesep 'DMFP.nii'];
        case 301
            template = [pathTpl filesep 'SPECT.nii'];
        case 302
            template = [pathTpl filesep 'SPECT.nii'];
        case 303
            template = [pathTpl filesep 'DATSCAN.nii'];
            weight = pathImg;
            smosrc = 6;
            smoref = 6;
        otherwise
            ptrDlgMessage('$main_NoTemplate','$all_Error');
            return;
    end
    
    % Create NIFTI file
    vs = abs (hdr.hdr.dime.pixdim(4:-1:2));
    imgFlip=zeros(size(img,3),size(img,2),size(img,1));
    for i=1:size(img,2), 
        imgFlip (:,size(img,2)-i+1,:) = flipud(rot90(squeeze(img(:,i,:)),3)); 
    end
    strtmp = nifticreate (imgFlip, 2, vs);
    niftiwrite (strtmp, pathImg);


    % Create SPM job
    norm.estwrite.subj(1).source{1} = [pathImg ',1'];
    norm.estwrite.subj(1).wtsrc = '';
    norm.estwrite.subj(1).resample{1} = [pathImg ',1'];
    norm.estwrite.eoptions.template = {template};
    norm.estwrite.eoptions.weight = weight;
    norm.estwrite.eoptions.smosrc = smosrc;
    norm.estwrite.eoptions.smoref = smoref;
    norm.estwrite.eoptions.regtype = 'mni';
    norm.estwrite.eoptions.cutoff = 25;
    norm.estwrite.eoptions.nits = 16;
    norm.estwrite.eoptions.reg = 1;
    norm.estwrite.roptions.preserve = 0;
    norm.estwrite.roptions.bb = [-78 -112 -51'; 78 76 85];
    norm.estwrite.roptions.vox = [2 2 2];
    norm.estwrite.roptions.interp = 1;
    norm.estwrite.roptions.wrap = [0 0 0];
    norm.estwrite.roptions.prefix = 'w';
    
    SPMver = spm('version');
    if strncmp(SPMver, 'SPM8', 4)
        matlabbatch{1}.spm.spatial.normalise = norm;
    elseif strncmp(SPMver, 'SPM12', 5)
        matlabbatch{1}.spm.tools.oldnorm = norm;
    else
        ptrDlgMessage('$main_InvalidSPM','$all_Error');
        return;
    end
    
    % Perform normalization
    try
        spm('defaults','pet');
        spm_jobman('initcfg');
        spm_jobman('run', matlabbatch);
        [imgNorm, hdrNorm] = leer_img (pathImgNorm, imgType);
    catch e
        ptrDlgMessage (e.message,'$all_Error');
        return
    end

    % Delete temp files
    old_state = recycle ('off');
    delete (pathImg);
    delete (pathImgNorm);
    delete (pathMat);
    recycle (old_state);
    error = 0;

