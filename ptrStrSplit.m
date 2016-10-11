% Split a string into substrings
%
% PARAMS:
% - str        -> String to be divided
% - separator  -> Characters used as delimiter to split the string
%
% OUTPUT:
% - out        -> Cell array with substrings
%
function out = ptrStrSplit (str, separator)
    if nargin<2, separator = ' '; end
    cuts = strfind (str, separator);
    cuts = [1-numel(separator) cuts numel(str)+1];
    
    for i=2:numel(cuts)
        s = str(cuts(i-1)+numel(separator):cuts(i)-1);
        if numel(s)== 0, s=''; end
        out{i-1} = s;
    end
end

