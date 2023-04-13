function print_in_A4(page_format, absolute_filename, export_to, restype, pos)

if nargin < 4
    pos = [2.5 2.5 25 15];
    if page_format == 0
        set(gcf, 'PaperPosition', [0 0 29.7 21.0]);
        set(gcf, 'PaperOrientation', 'portrait');
    else
        set(gcf, 'PaperPosition', [0 0 21.0 29.7]);
        set(gcf, 'PaperOrientation', 'landscape');
    end
    
    restype = 0;
end


%set(gcf, 'PaperType', 'custom');
%set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [20 30]);

if nargin == 4
    pos = [];
    if page_format == 0
        set(gcf, 'PaperPosition', [0 0 29.7 21.0]);
        set(gcf, 'PaperOrientation', 'portrait');
    else
        set(gcf, 'PaperPosition', [0 0 21.0 29.7]);
        set(gcf, 'PaperOrientation', 'landscape');
    end
    
else
    
    set(gcf, 'PaperPosition', pos);
    
    if page_format == 0
        set(gcf, 'PaperOrientation', 'portrait');
    elseif page_format ==1
        set(gcf, 'PaperOrientation', 'landscape');
    elseif page_format ==2
        set(gcf, 'PaperOrientation', 'rotated');
    end
end

if restype == 0
    
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/154096
    set(gcf, 'inverthardcopy', 'on');
    print(export_to, '-r300', '-painters', absolute_filename);
    
elseif restype == 1
    
    % http://www.mathworks.com/matlabcentral/newsreader/view_thread/154096
    set(gcf, 'inverthardcopy', 'on');
    print(export_to, '-r300', '-opengl', absolute_filename);
    
elseif restype == 3
    set(gcf,'color','white')
    set(gcf,'inverthardcopy','off')
    print(export_to, '-r300', '-painters', absolute_filename);
    
    
    disp('')
end
%set(gcf, 'inverthardcopy', 'off');
disp(['saved figure into file: ' absolute_filename ]);



end

%% EOF