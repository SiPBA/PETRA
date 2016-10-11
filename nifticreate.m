function str = nifticreate (img, filetype, voxel_size, originator, datatype)
    if nargin<5, datatype = 0; end
    if nargin<4, originator = size(img)/2; end
    if nargin<3, voxel_size = [1 1 1]; end
    if nargin<2, filetype = 2; end
    if nargin<1, error('Sintaxis: str = nifticreate (<Voxel_matrix>,...)'); end

    
    dim = size(img);
    dim = [numel(dim) dim ones(1,7-numel(dim))];
    voxel_size = [3 voxel_size ones(1,7-numel(voxel_size))];
    originator = [originator zeros(1,5-numel(originator))];

    if datatype == 0,
        switch class(img)
            case 'uint8',  datatype = 2;    bitpix = 8;
            case 'int8',   datatype = 256;  bitpix = 8;
            case 'uint16', datatype = 512;  bitpix = 16;
            case 'int16',  datatype = 4;    bitpix = 16;
            case 'uint32', datatype = 768;  bitpix = 32;
            case 'int32',  datatype = 8;    btipix = 32;
            case 'single', datatype = 16;   bitpix = 32;
            case 'double', datatype = 64;   bitpix = 64;
            otherwise, error('Tipo de datos no válido'); 
        end
    else
        switch datatype,
            case {1},                  bitpix = 1;
            case {2, 256},             bitpix = 8;
            case {4, 512},             bitpix = 16;
            case {128},                bitpix = 24;
            case {8, 16, 768, 2304},   bitpix = 32;
            case {32, 64, 1024, 1280}, bitpix = 64;
            case {1536, 1792},         bitpix = 128;
            case {2048},               bitpix = 256;
            otherwise, error('Tipo de datos no válido'); 
        end
    end
    
    glmax = max(img(:));
    glmin = min(img(:));
     
    if filetype == 0,
        if datatype > 128, error('Tipo de datos no válido'); end
        str.hdr = crear_cab_ana (dim,datatype,bitpix,voxel_size, ...
                  originator, glmax, glmin);
    elseif filetype == 1,
        str.hdr = crear_cab_nifti (dim, datatype, bitpix, voxel_size, ...
                  originator, 0, glmax, glmin, 'ni1');
    else
        str.hdr = crear_cab_nifti (dim, datatype, bitpix, voxel_size, ...
                  originator, 352, glmax, glmin, 'n+1');
    end
    
    str.machine = 'ieee-be';
    str.filetype = filetype;
    str.img = img;
end



function hdr = crear_cab_nifti (dim, datatype, bitpix, voxel_size, ...
               originator, vox_offset, glmax, glmin, magic)
    % header_key -> 0-40  ->  40 bytes
    hdr.hk.sizeof_hdr       = 348;
    hdr.hk.data_type        = '';
    hdr.hk.db_name          = '';
    hdr.hk.extents          = 0;
    hdr.hk.session_error    = 0;
    hdr.hk.regular          = 'r';
    hdr.hk.dim_info         = 0;

	% image_dimension -> 40-148 -> 108 bytes
    hdr.dime.dim            = dim;
    hdr.dime.intent_p1      = 0;
    hdr.dime.intent_p2      = 0;
    hdr.dime.intent_p3      = 0;
    hdr.dime.intent_code    = 0;
    hdr.dime.datatype       = datatype;
    hdr.dime.bitpix         = bitpix;
    hdr.dime.slice_start    = 0;
    hdr.dime.pixdim         = voxel_size;
    hdr.dime.vox_offset     = vox_offset;
    hdr.dime.scl_slope      = 0;
    hdr.dime.scl_inter      = 0;
    hdr.dime.slice_end      = 0;
    hdr.dime.slice_code     = 0;
    hdr.dime.xyzt_units     = 0;
    hdr.dime.cal_max        = 0;
    hdr.dime.cal_min        = 0;
    hdr.dime.slice_duration = 0;
    hdr.dime.toffset        = 0;
    hdr.dime.glmax          = glmax;
    hdr.dime.glmin          = glmin;
   
    % data_history -> % 148-348 -> 200 bytes 
    hdr.hist.descrip         = '';
    hdr.hist.aux_file        = 'none';
    hdr.hist.qform_code      = 0;
    hdr.hist.sform_code      = 0;
    hdr.hist.quatern_b       = 0;
    hdr.hist.quatern_c       = 0;
    hdr.hist.quatern_d       = 0;
    hdr.hist.qoffset_x       = originator(1);
    hdr.hist.qoffset_y       = originator(2);
    hdr.hist.qoffset_z       = originator(3);
    hdr.hist.srow_x          = [voxel_size(2) 0 0 originator(1)];
    hdr.hist.srow_y          = [0 voxel_size(3) 0 originator(2)];
    hdr.hist.srow_z          = [0 0 voxel_size(4) originator(3)];
    hdr.hist.intent_name     = '';
    hdr.hist.magic           = magic;
end


function hdr = crear_cab_ana (dim, datatype, bitpix, voxel_size, ...
               originator, glmax, glmin)
    % header_key -> 0-40  ->  40 bytes
    hdr.hk.sizeof_hdr       = 348;
    hdr.hk.data_type        = '';
    hdr.hk.db_name          = '';
    hdr.hk.extents          = 0;
    hdr.hk.session_error    = 0;
    hdr.hk.regular          = 'r';
    hdr.hk.hkey_un0         = '0';

	% image_dimension -> 40-148 -> 108 bytes
    hdr.dime.dim            = dim;
    hdr.dime.vox_units      = 'mm';
    hdr.dime.cal_units      = '';
    hdr.dime.unused1        = 0;
    hdr.dime.datatype       = datatype;
    hdr.dime.bitpix         = bitpix;
    hdr.dime.dim_un0        = 0;
    hdr.dime.pixdim         = voxel_size;
    hdr.dime.vox_offset     = 0;
    hdr.dime.roi_scale      = 1;
    hdr.dime.funused1       = 0;
    hdr.dime.funused2       = 0;
    hdr.dime.cal_max        = 0;
    hdr.dime.cal_min        = 0;
    hdr.dime.compressed     = 0;
    hdr.dime.verified       = 0;
    hdr.dime.glmax          = glmax;
    hdr.dime.glmin          = glmin;
    
    % data_history -> % 148-348 -> 200 bytes 
    hdr.hist.descrip        = '';
    hdr.hist.aux_file       = 'none';
    hdr.hist.orient         = 0;
    hdr.hist.originator     = originator;
    hdr.hist.generated      = '';
    hdr.hist.scannum        = '';
    hdr.hist.patient_id     = '';
    hdr.hist.exp_date       = '';
    hdr.hist.exp_time       = '';
    hdr.hist.hist_un0       = '';
    hdr.hist.views          = 0;
    hdr.hist.vols_added     = 0;
    hdr.hist.start_field    = 0;
    hdr.hist.field_skip     = 0;
    hdr.hist.omax           = 0;
    hdr.hist.omin           = 0;
    hdr.hist.smax           = 0;
    hdr.hist.smin           = 0;
end
    
    
    
    
    
    

