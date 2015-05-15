
function string = ptrLgGetString (code)
    global petraParams
    langStrings = petraParams.langStrings;

    try
        string = langStrings.(code);
    catch e
        ptrDlgMessage([langStrings.('all_lang_error') ': ' code]);
        string = '';
    end
end











