function ico = ptrLoadIcon(params, name, bgColor)
    if nargin<3, bgColor = []; end

    [p, n, e] = fileparts(name);
    if isempty(e), e = '.png'; end
    name = [params.pathIcons filesep n e];
    if ismethod(bgColor,'getColorComponents')
        bgColor = double(bgColor.getColorComponents([]));
    end
    
    try
        ico = imread (name, 'BackgroundColor', bgColor);
        ico = imresize(ico,[20 20]);
    catch e
        ico = [];
    end
    
end