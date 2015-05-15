function [langs,strings] = ptrLgLoad (file)
    langs = []; strings = [];

    fid = fopen (file, 'r', 'n', 'UTF-8');
    tline = fgets(fid);
    data = regexp(tline,';','split');

    for l=1:numel(data)-2
        langs(l).code = data{l+2}(1:2);
        langs(l).name = data{l+2}(4:end);
        strings.(langs(l).code) = [];
    end
        
    while ~feof(fid)
        tline = fgets(fid);
        data = regexp(tline,';','split');
        if str2double(data{1}) ~= 1, continue, end
        
        for l=1:numel(data)-2
            strings.(langs(l).code).(strtrim(data{2})) = strtrim(data{l+2});
        end

    end
    fclose(fid);
    
end
