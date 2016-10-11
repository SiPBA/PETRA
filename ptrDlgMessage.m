% Show a message in a modal window. It is similar to msgbox.
%
% PARAMS:
% - msg    -> Message string
% - title  -> Window title (optional, default = '')
%

function ptrDlgMessage(msg, title)
    if nargin<1, msg = ''; end
    if nargin<2, title = ''; end

    if ~isempty(msg) && strcmp(msg(1),'$'), msg = ptrLgGetString(msg(2:end)); end
    if ~isempty(title) && strcmp(title(1),'$'), title = ptrLgGetString(title(2:end)); end
    try
        okString = ptrLgGetString('all_OkBtn');
    catch e
        okString = 'OK';
    end

    % Define text font
    font.FontUnits = 'pixels';
    font.FontSize = 12;
    font.FontName = 'Helvetica';
    font.FontWeight = 'normal';

    % Calculate textbox size
    auxi = uicontrol(font,'Style','text','Position',[20 50 360 60]);
    [msg, textPos] = textwrap(auxi, ptrStrSplit(msg,'\n'));
    textPos(3) = max(textPos(3), 360); % Minimum 360
    textPos(4) = max(textPos(4),  60); % Minimum  60
    delete (auxi);


    f = figure('Name', title, 'NumberTitle', 'off','visible','off', ...
               'WindowStyle','modal');

    pos = get(f, 'Position');
    pos (3) = textPos(3) + 40;
    pos (4) = textPos(4) + 60;

    set (f, 'Position', pos);
    set (f, 'MenuBar', 'none');
    set (f, 'Resize', 'off');
    set (f, 'WindowStyle', 'modal');

    ptrCenterWindow(f);

    pan = uipanel('Parent',f, 'BorderType', 'none',...
                  'Units','pixels','Position',[1 1 pos(3) pos(4)]);
              
    textCtl = uicontrol(font, 'Parent',pan, ...
                  'String',msg, ...
                  'Style','text', ...
                  'Units','pixels', ...
                  'Position',textPos, ...
                  'HorizontalAlignment','left');
              
    btnOk = uicontrol('Parent',pan, ...
                  'String',okString,...
                  'Units','pixels', ...
                  'Position', [(pos(3)-90)/2 10 90 30], ...
                  'FontUnits', 'pixels', ...
                  'FontName', 'Helvetica', ...
                  'FontSize', 11, ...
                  'FontWeight', 'bold',...
                  'Callback', 'uiresume(gcbf)');
              
    set(f,'Visible','on');
    uiwait(f);
    if ishandle(f), close(f); end
end


