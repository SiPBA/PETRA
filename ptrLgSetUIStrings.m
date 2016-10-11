
function ptrLgSetUIStrings (h)
    global petraParams
    %langStrings = petraParams.langStrings.(petraParams.opc.langSelected);
    langStrings = petraParams.langStrings;
    
    showMsg = false;
    properties = {'String','Title','TooltipString','Name'};

    for p=1:numel(properties)
        property = properties{p};
        lis = findobj(h, '-property', property);
        for i=1:numel(lis)
            
            try
            value = get(lis(i), property);
            if ~ischar(value), continue, end;
            value = strtrim (value);
            userData = get(lis(i), 'UserData');
            if isempty(userData), userData = []; end
            
            if numel(value) > 0 && strcmp(value(1),'$')
                string = langStrings.(value(2:end));
                set(lis(i), property, string);

                userData.(['LangCode' property]) = value(2:end);
                userData.(['LangValue' property]) = string;
                set(lis(i), 'UserData', userData);

            elseif isfield(userData,['LangCode' property]) && ...
                    strcmp(userData.(['LangValue' property]), value)
                code = userData.(['LangCode' property]);
                string = langStrings.(code);
                set(lis(i), property, string);

                userData.(['LangValue' property]) = string;
                set(lis(i), 'UserData', userData);
            end
                
            catch e
                showMsg = true;
            end
        end
    end

    if showMsg, ptrDlgMessage(langStrings.('all_lang_error')); end
end
