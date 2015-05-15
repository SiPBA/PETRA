function varargout = get_params (params, varargin)
    delimiter = ',';
    num = nargout;
    if num < 1, num = 1; end
    params = strtrim(params);
    if numel(params)>0, res = strsplit (params, delimiter); else res={}; end
    
    out = cell(num,1);
    for i=1:num
        if numel(varargin)>=i, default = varargin{i}; else default = ''; end
        if numel(res)>=i,
            if iscell(res)
                out{i} = strtrim (res{i});
                if isnumeric(default), out{i} = str2double(out{i}); end
            else
                out{i} = res(i);
            end
        else
            out{i} = default;
        end
    end
    varargout = out;
        
        