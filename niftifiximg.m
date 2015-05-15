

function img = niftifiximg (str)
    img = double(str.img);
    if str.filetype == 0, return; end

    % Escalado
    slope = str.hdr.dime.scl_slope;
    inter = str.hdr.dime.scl_inter;
    if slope ~= 0, img = slope * img + inter; end
    
    % Maximo y minimo
    %minimo = str.hdr.dime.glmin;
    %maximo = str.hdr.dime.glmax;
    %img = img + (minimo - min(img(:)));
    %img = img * (maximo / max(img(:)));

    orientacion = get_orient(str.hdr);

    if ~isequal (orientacion, [1 2 3])
        indices = 1:prod (str.hdr.dime.dim(2:4));
        indices = reshape (indices, str.hdr.dime.dim(2:4));

        % Calcula rotaciones y volteos
        rotacion = mod(orientacion + 2, 3) + 1;
        volteos = orientacion - rotacion;

        % Voltea la img en la dimension que corresponda
        for i = 1:3
            if volteos(i), indices = flipdim (indices, i); end
        end

        [aux, rotacion] = sort(rotacion);
        indices = permute(indices, rotacion);
        indices = indices(:);
        dims = str.hdr.dime.dim(2:4);
        dims = dims (rotacion);
        dims = [dims str.hdr.dime.dim(5:8)];
        dims (dims<1) = 1;

        [ps, nl] = get_type (str.hdr.dime.datatype);
        if nl > 1
            for i=1:nl
                aux = reshape (img(:,:,:,i), [numel(indices) dims(4:7)]);
                aux = aux (indices, :);
                img(:,:,:,i) = reshape(aux, dims);
            end
        else
            img = reshape (img, [numel(indices) dims(4:7)]);
            img = img (indices, :);
            img = reshape(img, dims);
        end
    end    
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
   
    
function orientacion = get_orient (hdr)
    R = [];
    if hdr.hist.sform_code > 0   % Method 3
        R = [hdr.hist.srow_x(1:3)
             hdr.hist.srow_y(1:3)
             hdr.hist.srow_z(1:3)];

        T = [hdr.hist.srow_x(4)
             hdr.hist.srow_y(4)
             hdr.hist.srow_z(4)];
       
    elseif hdr.hist.qform_code > 0  % Method 2
        b = hdr.hist.quatern_b;
        c = hdr.hist.quatern_c;
        d = hdr.hist.quatern_d;
        if b*b+c*c+d*d > 1, 
            a = 0; 
        else
            a = sqrt(1.0-(b*b+c*c+d*d));
        end

        qfac = hdr.dime.pixdim(1);
        i = hdr.dime.pixdim(2);
        j = hdr.dime.pixdim(3);
        k = qfac * hdr.dime.pixdim(4);

        R = [a*a+b*b-c*c-d*d     2*b*c-2*a*d        2*b*d+2*a*c
             2*b*c+2*a*d         a*a+c*c-b*b-d*d    2*c*d-2*a*b
             2*b*d-2*a*c         2*c*d+2*a*b        a*a+d*d-c*c-b*b];

        T = [hdr.hist.qoffset_x
             hdr.hist.qoffset_y
             hdr.hist.qoffset_z];
    end
    
    orientacion = [1 2 3];
    if ~isempty (R)
        
        % Asegura que R tenga solo un valor distinto de 0 por fila
        if ~isequal(R(R~=0), sum(R)')
            aux = sort(abs(R(:)));
            th = aux (end-2) * 0.5;
            R (abs(R)<th) = 0;
            if ~isequal(R(R~=0), sum(R)')
                warning('Transformación afin ignorada');
                return
            end
        end
        
        % Calcula la orientacion
        invR = inv (R);
        for i = 1:3
            switch find(invR(i,:)) * sign(sum(invR(i,:)))
            case 1,    orientacion (i) = 1;	% Left to Right
            case 2,    orientacion (i) = 2;	% Posterior to Anterior
            case 3,    orientacion (i) = 3;	% Inferior to Superior
            case -1,   orientacion (i) = 4;	% Right to Left
            case -2,   orientacion (i) = 5;	% Anterior to Posterior
            case -3,   orientacion (i) = 6;	% Superior to Inferior
            otherwise, orientacion (i) = 0; 
            end
        end
    end
    
end


function r = isdiag(m)
    if isequal (m(m~=0), diag(m)), r = true; else r = false; end
end
    