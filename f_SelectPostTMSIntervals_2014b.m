function [data, v_TSBrush, todo, par] = f_SelectPostTMSIntervals_2014b( ...
    data, v_TSBrush, todo, par)

global cbh v_ChanSel hLine;

if strcmp(todo, 'plot')
    
    scnsize = get(0,'ScreenSize');
    h_FigBrush = figure('position', scnsize);
    v_TSBrush = [];
    subplot(5,1, [1 2 3 4]);
    hold on;
    s_TargetSR = par.srateSS;
    s_SSBy = par.srate/s_TargetSR;
    dataSS = data(:,1:s_SSBy:end);
    nChan = size(dataSS,1);
    v_x = (1:size(data,2))/par.srate;
    v_xSS = v_x(1:s_SSBy:end);
    par.xSS = {v_xSS};
    cbh = zeros(1,nChan);
    
    
    
    h_Axes0 = gca;
    v_Ax0 = h_Axes0.Position;
    delete h_Axes0
    
    % increase height of figure
    h_Axes = axes('position', [v_Ax0(1) v_Ax0(2)-v_Ax0(4)/8 v_Ax0(3) v_Ax0(4)+v_Ax0(4)/8]);
    hold on;
    v_Ax = h_Axes.Position;

    
    s_FigHeight = h_Axes.Position(4);
    s_BoxSpace = s_FigHeight/(nChan);
    s_BoxSz = 0.85*s_BoxSpace;
    s_BoxGap = 0.15*s_BoxSpace;
    s_ShiftTraceBy = 30;
    tmp_All = zeros(nChan, length(v_xSS));
    hLine = gobjects(1, nChan);
    for iChan = 1:nChan
        tmp = detrend(dataSS(iChan,:));
        %         tmp = dataSS(iChan,:);
        tmp_All(iChan,:) = tmp;
        if iChan == 1
            yL(2) = median(tmp)+s_ShiftTraceBy*3;
        end
        
        v_PosBox(1) = v_Ax(1)+v_Ax(3)+s_BoxGap;
        v_PosBox(2) = v_Ax(2)+ v_Ax(4) - (s_BoxSz+s_BoxGap)*iChan;
        v_PosBox(3) = s_BoxSz;
        v_PosBox(4) = s_BoxSz;
        input.iChan= iChan;
        input.x = v_xSS;
        input.data = tmp_All;
        input.shift = s_ShiftTraceBy;
        
        if std(tmp,[],2)>80
            hLine(iChan) = plot(v_xSS, tmp-s_ShiftTraceBy*(iChan-1), 'r');
            cbh(iChan) = uicontrol('Style','checkbox', 'units', 'normalized',...
                'String',par.ChanLabels(iChan).labels, ...
                'Value',0,'Position',v_PosBox,...
                'Callback',{@checkBoxCallback,input});
            v_ChanSel(iChan) = 0;
        elseif max(abs(tmp(:))) < 5 % to eliminate flat channels
            hLine(iChan) = plot(v_xSS, tmp-s_ShiftTraceBy*(iChan-1), 'r');
            cbh(iChan) = uicontrol('Style','checkbox', 'units', 'normalized',...
                'String',par.ChanLabels(iChan).labels, ...
                'Value',0,'Position',v_PosBox,...
                'Callback',{@checkBoxCallback,input});
            v_ChanSel(iChan) = 0;
        else
            hLine(iChan) = plot(v_xSS, tmp-s_ShiftTraceBy*(iChan-1), 'k');
            cbh(iChan) = uicontrol('Style','checkbox', 'units', 'normalized',...
                'String',par.ChanLabels(iChan).labels, ...
                'Value',1,'Position',v_PosBox,...
                'Callback',{@checkBoxCallback,input});
            v_ChanSel(iChan) = 1;
        end
        
        annotation('textbox', ...
                [v_PosBox(1)+v_PosBox(3)+0.001, v_PosBox(2)+v_PosBox(4)+0.001, 0, 0],...
                'string', par.ChanLabels(iChan).labels);
        
        
        
    end
    yL(1) = -s_ShiftTraceBy*nChan;
    %     ylim([-2000 500]);
    ylim(yL);
    xlim([0 v_xSS(end)]);
    xlabel('time [s]');
    ylabel('channels');
    
    
    title(sprintf('Burst %d / %d', par.iInt, par.nInt), 'fontsize', 20);
    %     axis tight;
    set(gcf,'toolbar','figure');
    
    % GUI buttons
    
    st_BrushGUI.return = uicontrol(h_FigBrush,...
        'Style','togglebutton',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'String','Return ',...
        'Units','Normalized',...
        'Position',[0.38 0.05 0.1 0.05],...
        'Max',1,...
        'Min',0,...
        'Callback', '[data, v_TSBrush, todo, par] =  f_SelectPostTMSIntervals_2014b(data, v_TSBrush, ''return'', par);');
    
    
    st_BrushGUI.remove = uicontrol(h_FigBrush,...
        'Style','togglebutton',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'String','Remove ',...
        'Units','Normalized',...
        'Position',[0.49 0.05 0.1 0.05],...
        'Max',1,...
        'Min',0,...
        'Callback', '[data, v_TSBrush, todo, par] =  f_SelectPostTMSIntervals_2014b(data, v_TSBrush, ''remove'', par);');
    
    
    st_BrushGUI.redo = uicontrol(h_FigBrush,...
        'Style','togglebutton',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'String','Still dirty ',...
        'Units','Normalized',...
        'Position',[0.6 0.05 0.1 0.05],...
        'Max',1,...
        'Min',0,...
        'Callback', '[data, v_TSBrush, todo, par] =  f_SelectPostTMSIntervals_2014b(data, v_TSBrush, ''replot'', par);');
    
    
    
    st_BrushGUI.goon = uicontrol(h_FigBrush,...
        'Style','togglebutton',...
        'BackgroundColor', [0.8 0.8 0.8],...
        'HorizontalAlignment','center',...
        'FontSize',14,...
        'String','Clean ',...
        'Units','Normalized',...
        'Position',[0.71 0.05 0.1 0.05],...
        'Max',1,...
        'Min',0,...
        'Callback', '[data, v_TSBrush, todo, par] =  f_SelectPostTMSIntervals_2014b(data, v_TSBrush, ''clean'', par);');
    
    brush on;
    
    
elseif strcmp(todo, 'replot')
    
    % check for brushing 2014b Mat-version
    xBrushMin = zeros(1,numel(hLine));
    xBrushMax = zeros(1,numel(hLine));
    for iLine = 1:numel(hLine)
        brushedIdx = logical(hLine(iLine).BrushData);
        brushedXData = hLine(iLine).XData(brushedIdx);
        if ~isempty(brushedXData)
            xBrushMin(iLine) = min(brushedXData);
            xBrushMax(iLine) = max(brushedXData);
        end
    end
    v_NonZeroMin = find(xBrushMin); % finds non-zero elements, so that min is not 0
    v_NonZeroMax = find(xBrushMin);
    startBrush = min(xBrushMin(v_NonZeroMin));
    stopBrush = max(xBrushMax(v_NonZeroMax));    
    
    % finds indices of brushed data
    if ~isempty(startBrush) % && ~isempty(find(~isnan(v_Brush(:))))
        tmpBrush = [startBrush stopBrush]; % new 2014b version
        
        subplot(5,1, [1 2 3 4]);
        hold on;
        yAx = get(gca, 'ylim');
        
        % plot patch object to mark rejected data
        h_pa = patch([tmpBrush(1) tmpBrush(1)  tmpBrush(2) tmpBrush(2)], [yAx(1) yAx(2) yAx(1) yAx(2)], 'g');
        alpha(h_pa, 0.2);
        title(sprintf('Burst %d / %d', par.iInt, par.nInt), 'fontsize', 20);
        axis tight;
        brush on;
        v_TSBrush = [v_TSBrush; tmpBrush];
        clear tmpBrush
    else disp('do nothing');
        
    end
    tmpBrush = [];
    todo = 'replot';
    
    
    
elseif strcmp(todo, 'clean')
    
    % check for brushing 2014b Mat-version
    xBrushMin = zeros(1,numel(hLine));
    xBrushMax = zeros(1,numel(hLine));
    for iLine = 1:numel(hLine)
        brushedIdx = logical(hLine(iLine).BrushData);
        brushedXData = hLine(iLine).XData(brushedIdx);
        if ~isempty(brushedXData)
            xBrushMin(iLine) = min(brushedXData);
            xBrushMax(iLine) = max(brushedXData);
        end
    end
    v_NonZeroMin = find(xBrushMin); % finds non-zero elements, so that min is not 0
    v_NonZeroMax = find(xBrushMin);
    startBrush = min(xBrushMin(v_NonZeroMin));
    stopBrush = max(xBrushMax(v_NonZeroMax));
    
    if ~isempty(startBrush)
        tmpBrush = [startBrush stopBrush]; % new 2014b version
        % plot patch object to mark rejected data
        subplot(5,1, [1 2 3 4]);
        hold on;
        yAx = get(gca, 'ylim');
        % plot patch object to mark rejected data
        h_pa = patch([tmpBrush(1) tmpBrush(1)  tmpBrush(2) tmpBrush(2)], [yAx(1) yAx(2) yAx(1) yAx(2)], 'g');
        alpha(h_pa, 0.2);
        
        
        title(sprintf('Burst %d / %d', par.iInt, par.nInt), 'fontsize', 20);
        axis tight;
        brush on;
        v_TSBrush = [v_TSBrush; tmpBrush];
        pause(2);
    else disp('do nothing');
        tmpBrush = [];
        v_TSBrush = [v_TSBrush; tmpBrush];
    end
    close(gcf)
    todo = 'clean';
elseif strcmp(todo, 'remove')
    close(gcf)
elseif strcmp(todo, 'return')
    close(gcf)
end

end



function checkBoxCallback(hObject,eventData,input)
global cbh v_ChanSel;
iChan = input.iChan;
tmp_All = input.data;
s_ShiftTraceBy = input.shift;
value = hObject.Value;
if value == 0
    plot(input.x, tmp_All(iChan,:)-s_ShiftTraceBy*(iChan-1), 'r');
elseif value == 1
    plot(input.x, tmp_All(iChan,:)-s_ShiftTraceBy*(iChan-1), 'k');
end

v_ChanSel = zeros(1,size(tmp_All,1));
for i= 1:size(tmp_All,1)
    tmp = get(cbh(i));
    v_ChanSel(i) = tmp.Value;
end
if isempty(v_ChanSel)
    disp('channel selection is empty for some reason.');
    disp('halted within function. check code.');
end

end
