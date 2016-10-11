% Join strings contained in a cell array
%
% PARAMS:
% - strings   -> Cell array containing substrings
% - separator -> Separator inserted between two substrings
%
% OUTPUT:
% - out       -> Final string
%
function out = ptrStrJoin (strings, separator)
    if nargin<2, separator = ' '; end

    out = strings{1};
    for i=2:numel(strings)
        out = [out separator strings{i}];
    end
end
