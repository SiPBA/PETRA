function str = niftiread (filename)

    str.machine = get_machine (filename);

    % Lee cabecera
    [str.filetype, str.hdr] = leer_cab_nifti(filename, str.machine);

    % Lee imagen
    str.img = leer_img_nifti (str, filename);
end



function machine = get_machine (filename)
    machine = 'ieee-le';
    fid = fopen(filename,'r',machine);  % supone machine='ieee-le'
    if fid < 0, error(['No se puede abrir ' filename]); end
    
    fseek(fid,0,'bof');
    if fread(fid,1,'int32') ~= 348     % machine no es correcto
        fclose(fid);
        machine = 'ieee-be';           % prueba machine='ieee-be' 
        fid = fopen(filename,'r',machine);
        fseek(fid,0,'bof');
        if fread(fid,1,'int32') ~= 348
            fclose(fid);
            fid = -1;
            error (['Archivo ' filename ' no válido']);
        end
    end
    fclose(fid);
end



function [filetype, hdr] = leer_cab_nifti (filename, machine)
    % Abre el archivo
    fid = fopen (filename, 'r', machine);
    if fid < 0, error(['No se puede abrir ' filename]); end
    fseek (fid,0,'bof');

    % Obtiene tipo
    fseek (fid, 344, 'bof');
    type = deblank(fread(fid,4,'uchar=>char')');    
    fseek (fid,0,'bof');
    
    filetype = 0;
    if strcmp(type, 'ni1'), filetype = 1; end
    if strcmp(type, 'n+1'), filetype = 2; end

    if filetype == 0
        hdr = leer_cab_ana (fid);
    else
        hdr = leer_cab_nii (fid);
    end
    fclose(fid);
end



function hdr = leer_cab_nii (fid)   
    % header_key -> 0-40  ->  40 bytes
    hdr.hk.sizeof_hdr    = fread(fid, 1,'int32')';	% vale 348
    hdr.hk.data_type     = deblank(fread(fid,10,'uchar=>char')');
    hdr.hk.db_name       = deblank(fread(fid,18,'uchar=>char')');
    hdr.hk.extents       = fread(fid, 1,'int32')';
    hdr.hk.session_error = fread(fid, 1,'int16')';
    hdr.hk.regular       = fread(fid, 1,'uchar=>char')';
    hdr.hk.dim_info      = fread(fid, 1,'uchar')';
    
	% image_dimension -> 40-148 -> 108 bytes
    hdr.dime.dim        = fread(fid,8,'int16')';
    hdr.dime.intent_p1  = fread(fid,1,'float32')';
    hdr.dime.intent_p2  = fread(fid,1,'float32')';
    hdr.dime.intent_p3  = fread(fid,1,'float32')';
    hdr.dime.intent_code = fread(fid,1,'int16')';
    hdr.dime.datatype   = fread(fid,1,'int16')';
    hdr.dime.bitpix     = fread(fid,1,'int16')';
    hdr.dime.slice_start = fread(fid,1,'int16')';
    hdr.dime.pixdim     = abs(fread(fid,8,'float32')');
    hdr.dime.vox_offset = fread(fid,1,'float32')';
    hdr.dime.scl_slope  = fread(fid,1,'float32')';
    hdr.dime.scl_inter  = fread(fid,1,'float32')';
    hdr.dime.slice_end  = fread(fid,1,'int16')';
    hdr.dime.slice_code = fread(fid,1,'uchar')';
    hdr.dime.xyzt_units = fread(fid,1,'uchar')';
    hdr.dime.cal_max    = fread(fid,1,'float32')';
    hdr.dime.cal_min    = fread(fid,1,'float32')';
    hdr.dime.slice_duration = fread(fid,1,'float32')';
    hdr.dime.toffset    = fread(fid,1,'float32')';
    hdr.dime.glmax      = fread(fid,1,'int32')';
    hdr.dime.glmin      = fread(fid,1,'int32')';
        
    % data_history -> % 148-348 -> 200 bytes 
    hdr.hist.descrip     = deblank(fread(fid,80,'uchar=>char')');
    hdr.hist.aux_file    = deblank(fread(fid,24,'uchar=>char')');
    hdr.hist.qform_code  = fread(fid,1,'int16')';
    hdr.hist.sform_code  = fread(fid,1,'int16')';
    hdr.hist.quatern_b   = fread(fid,1,'float32')';
    hdr.hist.quatern_c   = fread(fid,1,'float32')';
    hdr.hist.quatern_d   = fread(fid,1,'float32')';
    hdr.hist.qoffset_x   = fread(fid,1,'float32')';
    hdr.hist.qoffset_y   = fread(fid,1,'float32')';
    hdr.hist.qoffset_z   = fread(fid,1,'float32')';
    hdr.hist.srow_x      = fread(fid,4,'float32')';
    hdr.hist.srow_y      = fread(fid,4,'float32')';
    hdr.hist.srow_z      = fread(fid,4,'float32')';
    hdr.hist.intent_name = deblank(fread(fid,16,'uchar=>char')');
    hdr.hist.magic       = deblank(fread(fid,4,'uchar=>char')');
end



function hdr = leer_cab_ana (fid)
    % header_key -> 0-40  ->  40 bytes
    hdr.hk.sizeof_hdr    = fread(fid, 1,'int32')';	% should be 348!
    hdr.hk.data_type     = deblank(fread(fid,10,'uchar=>char')');
    hdr.hk.db_name       = deblank(fread(fid,18,'uchar=>char')');
    hdr.hk.extents       = fread(fid, 1,'int32')';
    hdr.hk.session_error = fread(fid, 1,'int16')';
    hdr.hk.regular       = fread(fid, 1,'uchar=>char')';
    hdr.hk.hkey_un0      = fread(fid, 1,'uchar=>char')';
    
	% image_dimension -> 40-148 -> 108 bytes
    hdr.dime.dim        = fread(fid,8,'int16')';
    hdr.dime.vox_units  = deblank(fread(fid,4,'uchar=>char')');
    hdr.dime.cal_units  = deblank(fread(fid,8,'uchar=>char')');
    hdr.dime.unused1    = fread(fid,1,'int16')';
    hdr.dime.datatype   = fread(fid,1,'int16')';
    hdr.dime.bitpix     = fread(fid,1,'int16')';
    hdr.dime.dim_un0    = fread(fid,1,'int16')';
    hdr.dime.pixdim     = fread(fid,8,'float32')';
    hdr.dime.vox_offset = fread(fid,1,'float32')';
    hdr.dime.roi_scale  = fread(fid,1,'float32')';
    hdr.dime.funused1   = fread(fid,1,'float32')';
    hdr.dime.funused2   = fread(fid,1,'float32')';
    hdr.dime.cal_max    = fread(fid,1,'float32')';
    hdr.dime.cal_min    = fread(fid,1,'float32')';
    hdr.dime.compressed = fread(fid,1,'int32')';
    hdr.dime.verified   = fread(fid,1,'int32')';
    hdr.dime.glmax      = fread(fid,1,'int32')';
    hdr.dime.glmin      = fread(fid,1,'int32')';
        
    % data_history -> % 148-348 -> 200 bytes 
    hdr.hist.descrip     = deblank(fread(fid,80,'uchar=>char')');
    hdr.hist.aux_file    = deblank(fread(fid,24,'uchar=>char')');
    hdr.hist.orient      = fread(fid, 1,'char')';
    hdr.hist.originator  = fread(fid, 5,'int16')';
    hdr.hist.generated   = deblank(fread(fid,10,'uchar=>char')');
    hdr.hist.scannum     = deblank(fread(fid,10,'uchar=>char')');
    hdr.hist.patient_id  = deblank(fread(fid,10,'uchar=>char')');
    hdr.hist.exp_date    = deblank(fread(fid,10,'uchar=>char')');
    hdr.hist.exp_time    = deblank(fread(fid,10,'uchar=>char')');
    hdr.hist.hist_un0    = deblank(fread(fid, 3,'uchar=>char')');
    hdr.hist.views       = fread(fid, 1,'int32')';
    hdr.hist.vols_added  = fread(fid, 1,'int32')';
    hdr.hist.start_field = fread(fid, 1,'int32')';
    hdr.hist.field_skip  = fread(fid, 1,'int32')';
    hdr.hist.omax        = fread(fid, 1,'int32')';
    hdr.hist.omin        = fread(fid, 1,'int32')';
    hdr.hist.smax        = fread(fid, 1,'int32')';
    hdr.hist.smin        = fread(fid, 1,'int32')';
end



function img = leer_img_nifti (str, filename)
    if str.filetype == 2;
        imgname = filename;
        offset = str.hdr.dime.vox_offset;
    else
        [r n] = fileparts (filename);
        imgname = fullfile(r, [n '.img']);
        offset = 0;
    end
    
    fid = fopen (imgname, 'r', str.machine);
    if fid < 0, error(['No se puede abrir ' imgname]); end
    fseek (fid, offset, 'bof');

    % Determina precision (ps) y numero de capas (nl)
    datatype = uint16(str.hdr.dime.datatype);
    [ps, nl] = get_type (datatype);
    if isempty (ps), error ('Tipo de datos no válido'); end
    
    % Lee todos los voxeles
    str.hdr.dime.dim (str.hdr.dime.dim < 1) = 1;
    nbytes = prod (str.hdr.dime.dim(2:8)) * nl;
    [img, count] = fread (fid, nbytes, ['*' ps]);
    if count < nbytes, error(['Archivo ' imgname ' truncado']); end
    
    % Si hay varias capas (para colores)
    if datatype == 128 || datatype == 2304
        img = reshape(img, [nl str.hdr.dime.dim(2:8)]);
        img = permute(img, [2 3 4 1 5 6 7 8]);

    % Numeros complejos (2 capas, una para parte real y otra para imag)
    elseif datatype == 32 || datatype == 1792 || datatype == 2048
        parte_real = 1:2:numel(img);
        parte_imag = 2:2:numel(img);
        img = complex (img(parte_real), img(parte_imag));
        img = reshape(img, str.hdr.dime.dim(2:8));
        
    else
        img = reshape(img, str.hdr.dime.dim(2:8));
    end
    
    fclose (fid);
end



function [ps, nl] = get_type (datatype)
    switch datatype
    % ANALYZE 7.5 type codes
    case    1, ps = 'ubit1';           nl = 1;  % binary (1 bit/voxel)
    case    2, ps = 'uint8';           nl = 1;  % unsigned char (8 bits/voxel)
    case    4, ps = 'int16';           nl = 1;  % signed short (16 bits/voxel)
    case    8, ps = 'int32';           nl = 1;  % signed int (32 bits/voxel)
    case   16, ps = 'float32';         nl = 1;  % float (32 bits/voxel)
    case   32, ps = 'float32';         nl = 2;  % complex (64 bits/voxel)
    case   64, ps = 'float64';         nl = 1;  % double (64 bits/voxel)
    case  128, ps = 'uint8';           nl = 3;  % RGB triple (24 bits/voxel)
    % new codes for NIFTI
    case  256, ps = 'int8';            nl = 1;  % signed char (8 bits)
    case  512, ps = 'uint16';          nl = 1;  % unsigned short (16 bits)
    case  768, ps = 'uint32';          nl = 1;  % unsigned int (32 bits)
    case 1024, ps = 'int64';           nl = 1;  % long long (64 bits)
    case 1280, ps = 'uint64';          nl = 1;  % unsigned long long (64 bits)
    case 1536, ps = 'bit128=>float64'; nl = 1;  % long double (128 bits)
    case 1792, ps = 'float64';         nl = 2;  % double pair (128 bits)
    case 2048, ps = 'bit128=>float64'; nl = 2;  % long double pair (256 bits)
    case 2304, ps = 'uint8';           nl = 4;  % RGBA (32 bits/voxel)
    otherwise, ps = '';                nl = 1;
    end
end   
 
 