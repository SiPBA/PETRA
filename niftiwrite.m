function niftiwrite (str, filename)
    if (nargin < 2) || comprueba_param (str, filename) == 0,
        error (['La sintaxis correcta es: ' ... 
                'guardar_nifti(<estructura_nifti> <nombre_archivo>)']);
    end   
    
    [r n e] = fileparts(filename);
    if str.filetype < 2, 
        hdrfile = fullfile (r,  [n '.hdr']); 
        imgfile = fullfile (r,  [n '.img']);
        str.hdr.dime.vox_offset = 0;
    else
        hdrfile = fullfile (r,  [n '.nii']); 
        imgfile = fullfile (r,  [n '.nii']);
        str.hdr.dime.vox_offset = 352;
    end

    if str.filetype == 0
        guardar_cab_ana (str, hdrfile);
    else
        guardar_cab_nifti (str, hdrfile);
    end
    guardar_img_nifti (str, imgfile);   
end

 
function valido = comprueba_param (str, filename)
    valido = 0;
    if ~isstruct (str), return; end
    if ~ischar (filename), return; end
    if ~isfield (str, 'hdr'), return; end
    if ~isfield (str, 'img'), return; end
    if ~isfield (str, 'filetype'), return; end
    if ~isfield (str, 'machine'), return; end   
    valido = 1;
end


function cad = ajustar_cad (cad, tama)
    if numel(cad) >= tama, 
        cad = cad (1:tama);
    else
        cad = [cad char(zeros(1,tama-numel(cad)))];
    end
end


function guardar_cab_nifti (str, hdrfile)
    str.hdr.hk.sizeof_hdr = 348;
    fid = fopen(hdrfile, 'w+', str.machine);
    if fid < 0,
    	error(['No se puede abrir ' hdrfile]);
    end

    fseek(fid,0,'bof');

    % header_key -> 0-40  ->  40 bytes
    fwrite (fid, str.hdr.hk.sizeof_hdr(1),       'int32');
    fwrite (fid, ajustar_cad (str.hdr.hk.data_type, 10), 'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hk.db_name, 18),   'uchar');
    fwrite (fid, str.hdr.hk.extents(1),          'int32');
    fwrite (fid, str.hdr.hk.session_error(1),    'int16');
    fwrite (fid, str.hdr.hk.regular(1),          'uchar');
    fwrite (fid, str.hdr.hk.dim_info(1),         'uchar');

	% image_dimension -> 40-148 -> 108 bytes
    fwrite (fid, str.hdr.dime.dim(1:8),          'int16');
    fwrite (fid, str.hdr.dime.intent_p1(1),      'float32');
    fwrite (fid, str.hdr.dime.intent_p2(1),      'float32');
    fwrite (fid, str.hdr.dime.intent_p3(1),      'float32');
    fwrite (fid, str.hdr.dime.intent_code(1),    'int16');
    fwrite (fid, str.hdr.dime.datatype(1),       'int16');
    fwrite (fid, str.hdr.dime.bitpix(1),         'int16');
    fwrite (fid, str.hdr.dime.slice_start(1),    'int16');
    fwrite (fid, str.hdr.dime.pixdim(1:8),       'float32');
    fwrite (fid, str.hdr.dime.vox_offset(1),     'float32');
    fwrite (fid, str.hdr.dime.scl_slope(1),      'float32');
    fwrite (fid, str.hdr.dime.scl_inter(1),      'float32');
    fwrite (fid, str.hdr.dime.slice_end(1),      'int16');
    fwrite (fid, str.hdr.dime.slice_code(1),     'uchar');
    fwrite (fid, str.hdr.dime.xyzt_units(1),     'uchar');
    fwrite (fid, str.hdr.dime.cal_max(1),        'float32');
    fwrite (fid, str.hdr.dime.cal_min(1),        'float32');
    fwrite (fid, str.hdr.dime.slice_duration(1), 'float32');
    fwrite (fid, str.hdr.dime.toffset(1),        'float32');
    fwrite (fid, str.hdr.dime.glmax(1),          'int32');
    fwrite (fid, str.hdr.dime.glmin(1),          'int32');

    % data_history -> % 148-348 -> 200 bytes 
    fwrite (fid, ajustar_cad (str.hdr.hist.descrip, 80),  'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.aux_file, 24), 'uchar');
    fwrite (fid, str.hdr.hist.qform_code,        'int16');
    fwrite (fid, str.hdr.hist.sform_code,        'int16');
    fwrite (fid, str.hdr.hist.quatern_b,         'float32');
    fwrite (fid, str.hdr.hist.quatern_c,         'float32');
    fwrite (fid, str.hdr.hist.quatern_d,         'float32');
    fwrite (fid, str.hdr.hist.qoffset_x,         'float32');
    fwrite (fid, str.hdr.hist.qoffset_y,         'float32');
    fwrite (fid, str.hdr.hist.qoffset_z,         'float32');
    fwrite (fid, str.hdr.hist.srow_x(1:4),       'float32');
    fwrite (fid, str.hdr.hist.srow_y(1:4),       'float32');
    fwrite (fid, str.hdr.hist.srow_z(1:4),       'float32');
    fwrite (fid, ajustar_cad (str.hdr.hist.intent_name, 16), 'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.magic, 4),        'uchar');

    % Comprueba tamaño de la cabecera
    tcab = ftell(fid);
    if ~isequal(tcab,348),
        warning('El tamaño de la cabecera no es 348 bytes');
    end
    
    fclose(fid);
end
    

function guardar_cab_ana (str, hdrfile)
    str.hdr.hk.sizeof_hdr = 348;
    fid = fopen(hdrfile, 'w', str.machine);
    if fid < 0,
    	error(['No se puede abrir ' hdrfile]);
    end

    fseek(fid,0,'bof');

    % header_key -> 0-40  ->  40 bytes
    fwrite (fid, str.hdr.hk.sizeof_hdr(1),    'int32');
    fwrite (fid, ajustar_cad (str.hdr.hk.data_type, 10), 'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hk.db_name, 18),   'uchar');
    fwrite (fid, str.hdr.hk.extents(1),       'int32');
    fwrite (fid, str.hdr.hk.session_error(1), 'int16');
    fwrite (fid, str.hdr.hk.regular(1),       'uchar');
    fwrite (fid, str.hdr.hk.hkey_un0(1),      'uchar');

	% image_dimension -> 40-148 -> 108 bytes
    fwrite (fid, str.hdr.dime.dim(1:8),      'int16');
    fwrite (fid, ajustar_cad (str.hdr.dime.vox_units, 4),  'uchar');
    fwrite (fid, ajustar_cad (str.hdr.dime.cal_units, 8),  'uchar');
    fwrite (fid, str.hdr.dime.unused1(1),    'int16');
    fwrite (fid, str.hdr.dime.datatype(1),   'int16');
    fwrite (fid, str.hdr.dime.bitpix(1),     'int16');
    fwrite (fid, str.hdr.dime.dim_un0(1),    'int16');
    fwrite (fid, str.hdr.dime.pixdim(1:8),   'float32');
    fwrite (fid, str.hdr.dime.vox_offset(1), 'float32');
    fwrite (fid, str.hdr.dime.roi_scale(1),  'float32');
    fwrite (fid, str.hdr.dime.funused1(1),   'float32');
    fwrite (fid, str.hdr.dime.funused2(1),   'float32');
    fwrite (fid, str.hdr.dime.cal_max(1),    'float32');
    fwrite (fid, str.hdr.dime.cal_min(1),    'float32');
    fwrite (fid, str.hdr.dime.compressed(1), 'int32');
    fwrite (fid, str.hdr.dime.verified(1),   'int32');
    fwrite (fid, str.hdr.dime.glmax(1),      'int32');
    fwrite (fid, str.hdr.dime.glmin(1),      'int32');

    % data_history -> % 148-348 -> 200 bytes 
    fwrite (fid, ajustar_cad (str.hdr.hist.descrip, 80),   'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.aux_file, 24),  'uchar');
    fwrite (fid, str.hdr.hist.orient(1),       'uchar');
    fwrite (fid, str.hdr.hist.originator(1:5), 'int16');
    fwrite (fid, ajustar_cad (str.hdr.hist.generated, 10), 'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.scannum, 10),   'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.patient_id, 10),'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.exp_date, 10),  'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.exp_time, 10),  'uchar');
    fwrite (fid, ajustar_cad (str.hdr.hist.hist_un0, 3),   'uchar');
    fwrite (fid, str.hdr.hist.views(1),      'int32');
    fwrite (fid, str.hdr.hist.vols_added(1), 'int32');
    fwrite (fid, str.hdr.hist.start_field(1),'int32');
    fwrite (fid, str.hdr.hist.field_skip(1), 'int32');
    fwrite (fid, str.hdr.hist.omax(1),       'int32');
    fwrite (fid, str.hdr.hist.omin(1),       'int32');
    fwrite (fid, str.hdr.hist.smax(1),       'int32');
    fwrite (fid, str.hdr.hist.smin(1),       'int32');

    % Comprueba tamaño de la cabecera
    tcab = ftell(fid);
    if ~isequal(tcab,348),
        warning('El tamaño de la cabecera no es 348 bytes');
    end
    
    fclose(fid);
end
   

function guardar_img_nifti(str, imgfile)
    if str.filetype == 2
        fid = fopen(imgfile, 'a', str.machine);
    else
        fid = fopen(imgfile, 'w', str.machine);
    end
    if fid < 0,	error(['No se puede abrir ' imgfile]); end
    
    % Rellena con 1s
    fseek(fid,0,'eof');
    relleno = str.hdr.dime.vox_offset - ftell(fid);
    if relleno > 0, fwrite (fid, zeros(1, relleno), 'uint8'); end
    
    % Determina precision (ps) y numero de capas (nl)
    datatype = uint16(str.hdr.dime.datatype);
    [ps, nl] = get_type (datatype);
    if isempty (ps), error ('Tipo de datos no válido'); end
    
    % Si hay varias capas (para colores)
    if datatype == 128 || datatype == 2304
         img = permute(str.img, [4 1 2 3 5 6 7 8]);
         img = img(:);

    % Numeros complejos (2 capas, una para parte real y otra para imag)
    elseif datatype == 32 || datatype == 1792 || datatype == 2048
        img = zeros(2*numel(str.img));
        img (1:2:end) = real(str.img);
        img (2:2:end) = imag(str.img);

    else
        img = str.img(:);
    end
    
    fwrite(fid, img, ps);
    fclose(fid);
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
