function icon = ptrLoadIcon(params, name, bgColor)
    if nargin<3, bgColor = []; end
    if ismethod(bgColor,'getColorComponents')
        bgColor = double(bgColor.getColorComponents([]));
    end
    
    try
        icons = imread (params.iconsFile, 'BackgroundColor', bgColor);
        num = find(strcmp(params.iconsOrder,name));
        icon = icons(:,24*(num-1)+1:24*num,:);
        icon = imresize(icon,[20 20]);
    catch e
        icon = [];
    end
    
end