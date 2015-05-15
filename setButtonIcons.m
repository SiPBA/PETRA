function setButtonIcons (h, fpath)

    % If h is not a button handle, find buttons
    if strcmp(class(handle(h)), 'uicontrol')
        hBtns = h;
    else
        hBtns = findobj(h, 'Style','pushbutton')';
        hBtns = [hBtns findobj(h, 'Style','togglebutton')'];
    end
    
    % For each button....
    for hb = hBtns
        str = get(hb,'String');
        if length(str)<5 || ~strcmp(str(1:4),'ico:'), continue, end
        
        %Get icons name (one or more)
        spacePos = strfind (str,' ');
        if isempty(spacePos)
            endPos = numel(str);
        else
            endPos = spacePos(1)-1;
        end
        fnames = strsplit(str(5:endPos), ':');
        set (hb,'String',str(endPos+2:end));

        % Load icons. Show the first one and save the other ones
        for ic = 1:numel(fnames)
            fname = [fpath filesep fnames{ic}];
            try
                ico = imread (fname,'BackgroundColor', [1 1 1]);
                ico = imresize(ico,[20 20]);
            catch e
                ico = [];
            end
            icons{ic} = ico;
        end
        set(hb, 'CData', icons{1});
        if numel(icons)>1, set(hb,'UserData',struct('icons',{icons})); end
    end
end

