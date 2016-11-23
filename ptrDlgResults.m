%
% Show classification results
%
function ptrDlgResults(ptrData, res)
    sizeWin = [800,620];

    f = figure('Name', ptrLgGetString('resClas_Title'), ...
        'NumberTitle', 'off', ...
        'visible','off',...
        'WindowStyle','normal', ...
        'Position', [1 1 sizeWin(1) sizeWin(2)], ...
        'MenuBar', 'none', ...
        'Resize', 'on', ...
        'DockControls', 'off', ...
        'UserData', sizeWin);

    ptrCenterWindow(f);

    % Toolbar
    toolbar.toolbar = uitoolbar('Parent', f);
    %bgColor = get(0, 'factoryUicontainerBackgroundColor');
    drawnow;
    jToolbar = get(get(toolbar.toolbar,'JavaContainer'),'ComponentPeer');    
    bgColor = get (jToolbar,'Background');
    
    % Toolbar buttons
    toolbar.imgTools.button(1) = uitoggletool('Parent', toolbar.toolbar, ...
            'CData', ptrLoadIcon(ptrData.params,'zoom_in',bgColor), ...
            'Visible', 'on', ...
            'Tag','Toolbar.ImageTool', ...
            'ClickedCallback', {'ptrPlotTools','zoomIn'});

    toolbar.imgTools.button(2) = uipushtool('Parent', toolbar.toolbar, ...
            'CData', ptrLoadIcon(ptrData.params,'zoom_reset',bgColor), ...
            'Visible', 'on', ...
            'Tag','Toolbar.ImageTool', ...
            'ClickedCallback', {'ptrPlotTools','zoomReset'});
        
    toolbar.imgTools.button(3) = uitoggletool('Parent', toolbar.toolbar, ...
            'CData', ptrLoadIcon(ptrData.params,'zoom_out',bgColor), ...
            'Visible', 'on', ...
            'Tag','Toolbar.ImageTool', ...
            'ClickedCallback', {'ptrPlotTools','zoomOut'});

    toolbar.imgTools.button(4) = uitoggletool('Parent', toolbar.toolbar, ...
            'CData', ptrLoadIcon(ptrData.params,'hand',bgColor), ...
            'Visible', 'on', ...
            'Tag','Toolbar.ImageTool', ...
            'ClickedCallback', {'ptrPlotTools','hand'});
       
    toolbar.imgTools.button(5) = uitoggletool('Parent', toolbar.toolbar, ...
            'CData', ptrLoadIcon(ptrData.params,'rotate',bgColor), ...
            'Visible', 'on', ...
            'Tag','Toolbar.ImageTool', ...
            'ClickedCallback', {'ptrPlotTools','rotate'});
    
        
    % Create interface
    footerHeight = 45;
    h.footer = uipanel('Parent',f,'Units','Pixels', 'BorderType', 'line',...
             'Position', [0 0 sizeWin(1) footerHeight]);
         
    h.mainPanel = uipanel('Parent',f,'Units','Pixels', 'BorderType', 'none',...
             'Position', [0 footerHeight sizeWin(1) sizeWin(2)-footerHeight]);
         
    str = [ptrLgGetString('resClas_Estimation') ' ' res.args.clases{res.class+1}];
    uicontrol('Parent', h.footer, ...
            'String', str, ...
            'Style','text', ...
            'Units','pixels', ...
            'Position',[9 15 floor(sizeWin(1)/2)-18 20], ...
            'FontUnits','pixels', ...
            'FontName', 'Helvetica', ...
            'FontSize',16, ...
            'HorizontalAlignment','left');

    comps = num2cell(res.comps);
    h.cmb1 = uicontrol('Parent', h.footer, ...
            'String', comps, ...
            'Style','popupmenu', ...
            'Units','pixels', ...
            'Position',[sizeWin(1)-100*3-21 5 100 30], ...
            'FontUnits','pixels', ...
            'FontName', 'Helvetica', ...
            'FontSize',12, ...
            'HorizontalAlignment','left');

    h.cmb2 = uicontrol('Parent', h.footer, ...
            'String', {ptrLgGetString('resClas_None') comps{:}}, ...
            'Style','popupmenu', ...
            'Value',min(3,numel(comps)+1), ...
            'Units','pixels', ...
            'Position',[sizeWin(1)-100*2-14 5 100 30], ...
            'FontUnits','pixels', ...
            'FontName', 'Helvetica', ...
            'FontSize',12, ...
            'HorizontalAlignment','left');
        
    h.cmb3 = uicontrol('Parent', h.footer, ...
            'String', {ptrLgGetString('resClas_None') comps{:}}, ...
            'Style','popupmenu', ...
            'Units','pixels', ...
            'Position',[sizeWin(1)-100-7 5 100 30], ...
            'FontUnits','pixels', ...
            'FontName', 'Helvetica', ...
            'FontSize',12, ...
            'HorizontalAlignment','left');
    
         
    showResults(h, res);
    
    set(h.cmb1,'Callback', @(hObj,event) showResults(h, res));
    set(h.cmb2,'Callback', @(hObj,event) showResults(h, res));
    set(h.cmb3,'Callback', @(hObj,event) showResults(h, res));
    
    set(f,'ResizeFcn',@(hObj,even) resizeWindow(f, h));
    set(f,'Visible','on');
end


function resizeWindow (f, handles)
    currentPos = get(f,'Position'); 
    oldSize = get(f,'UserData');
    diff = oldSize - currentPos(3:4);

    if any(diff ~= 0)
        set(f,'UserData',currentPos(3:4));

        pos = get(handles.mainPanel, 'Position');
        set(handles.mainPanel, 'Position', pos - [0 0 diff]);        
        pos = get(handles.footer, 'Position');
        set(handles.footer, 'Position', pos - [0 0 diff(1) 0]);
        pos = get(handles.cmb1, 'Position');
        set(handles.cmb1, 'Position', pos - [diff(1) 0 0 0]);
        pos = get(handles.cmb2, 'Position');
        set(handles.cmb2, 'Position', pos - [diff(1) 0 0 0]);
        pos = get(handles.cmb3, 'Position');
        set(handles.cmb3, 'Position', pos - [diff(1) 0 0 0]);
    end
end


function showResults(handles, res)
    % Delete existing axes
    for obj = get(handles.mainPanel,'Children')
        delete(obj);
    end

    % Compute vector of components
    ls = get(handles.cmb1,'String');
    comps(1) = str2double(ls{get(handles.cmb1,'Value')});
    ls = get(handles.cmb2,'String');
    comps(2) = str2double(ls{get(handles.cmb2,'Value')});
    ls = get(handles.cmb3,'String');
    comps(3) = str2double(ls{get(handles.cmb3,'Value')});
    comps = unique(comps(~isnan(comps))); 
    nComps = numel(comps);
    
    % Show components in brain form
    if numel(size(res.args.train.options))==4
        for k=1:nComps

            % Create axes
            pos = [0.05 0.05+(k-1)/nComps 0.40 (1-0.1*nComps)/nComps];
            hAxes(k) = axes(...
                'Parent', handles.mainPanel, ...
                'Position', pos);

            % Show data
            eign = squeeze(res.args.train.options(comps(k),:,:,:));
            for i=1:size(eign,1), stack(:,:,1,i)=eign(i,:,:); end
            montage (stack,'DisplayRange', [min(stack(:)),max(stack(:))]);
            colorbar;

            % Show title
            set(hAxes(k), 'XAxisLocation','top');
            hl = xlabel(sprintf('Comp. %d (Score = %.02f)', comps(k), ...
                res.feats(1,comps(k))));
            set(hl,'Position',get(hl,'Position') + [0 50 0]);

        end
        colormap (res.args.colormap);
    end
    
    % Create scatter
    hScatter = axes(...
        'Parent',handles.mainPanel,...
        'Box','on',...
        'Units','normalized', ...
        'Position',[0.55 0.1 0.43 0.85]);
    
    showPlot(hScatter, res, comps);
end

function showPlot(h, res, comps)
    nComps = numel(comps);

    % Get data
    tstFeats = zeros(1,3);
    trnFeats = zeros(size(res.args.train.feats,1),3);
    for k=1:nComps
        tstFeats(1,k) = res.feats(1,comps(k));
        trnFeats(:,k) = res.args.train.feats(:,comps(k));
    end


    % Show test image
    if nComps==3
        plot3(tstFeats(:,1), tstFeats(:,2), tstFeats(:,3), ...
            'MarkerFaceColor', 'k', 'Marker', 'o', 'MarkerEdgeColor', 'k', ...
            'LineStyle','none','DisplayName','TEST IMAGE');
    else
        plot(tstFeats(:,1), tstFeats(:,2), ...
            'MarkerFaceColor', 'k', 'Marker', 'o', 'MarkerEdgeColor', 'k', ...
            'LineStyle','none','DisplayName','TEST IMAGE');        
    end
    
    % Show training images
    hold on
    style = {'.b','.r','.m','.y'};
    nClasses = unique(res.args.train.labels);
    for i=1:numel(res.args.clases)
        data = trnFeats(res.args.train.labels==nClasses(i),:);
        if nComps==3
            plot3(data(:,1), data(:,2), data(:,3),...
                style{mod(i-1,numel(style))+1},...
                'DisplayName',res.args.clases{i});
        else
            plot(data(:,1), data(:,2),...
                style{mod(i-1,numel(style))+1},...
                'DisplayName',res.args.clases{i});
        end
    end    
    legend ('show','Location','Best')
    grid on;
    axis tight;
    
    
    % Show hyperplane
    lims = axis(h);    
    if nComps==2
        [X,Y] = meshgrid(linspace(lims(1),lims(2)),linspace(lims(3),lims(4)));
        Z = computeHyperplane([X(:),Y(:)], res.args, comps);
        if ~isempty(Z), contour(X,Y,reshape(Z,size(X)),[0 0],'k'); end
        
    elseif nComps==3
        [Xc,Yc,Zc] = meshgrid(linspace(lims(1),lims(2)),linspace(lims(3),lims(4)),linspace(lims(5),lims(6)));
        Z = computeHyperplane([Xc(:),Yc(:),Zc(:)], res.args, comps);
        if ~isempty(Z)
            hpatch = patch(isosurface(Xc,Yc,Zc,reshape(Z,size(Xc)),0));
            isonormals(Xc,Yc,Zc,reshape(Z,size(Xc)),hpatch)
            set(hpatch,'FaceColor','red','EdgeColor','none')
            view([-126,36]);
            camlight left;
            set(gcf,'Renderer','zbuffer');
            lighting phong;
        end
    end
    hold off;

end



function Z = computeHyperplane(Xnew,args,comps)
    Z = [];
    clasif = args.train.clasif;

    if strcmp(clasif,'svm')
        svm = args.train.rclasif.trn;
        svm.SupportVectors = svm.SupportVectors(:,comps);
        if ~isempty(svm.ScaleData)
            for c = 1:size(Xnew, 2)
                Xnew(:,c) = svm.ScaleData.scaleFactor(c)*(Xnew(:,c) +  ...
                            svm.ScaleData.shift(c));
            end
        end

        sv = svm.SupportVectors;
        alphaHat = svm.Alpha;
        bias = svm.Bias;
        kfun = svm.KernelFunction;
        kfunargs = svm.KernelFunctionArgs;

        Z = (feval(kfun,sv,Xnew,kfunargs{:})'*alphaHat(:)) + bias;
    end
end


