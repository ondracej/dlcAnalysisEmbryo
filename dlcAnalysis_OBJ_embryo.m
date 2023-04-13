classdef dlcAnalysis_OBJ_embryo < handle
    
    
    properties (Access = public)
        
        PATH
        COORDS
        VID
    end
    
    methods
        
        
        function obj = definePaths(obj,analysisDir, ExperimentName)
            
            if ispc
                dirD = '\';
            else
                dirD = '/';
            end
            
            fps = 50;
            obj.VID.fps = fps;
            
            %% Find CSV files
            
            csvfiles = dir(fullfile(analysisDir, '*.csv'));
            nFiles = numel(csvfiles);
            fileNames = [];
            for j = 1:nFiles
                fileNames{j} = csvfiles(j).name;
            end
            
            list = {fileNames{1:end}};
            
            for j = 1:4
                switch j
                    case 1
                        prompt = 'Please select the "Baseline Pain" csv file';
                    case 2
                        prompt = 'Please select the "Post Pain" csv file';
                    case 3
                        prompt = 'Please select the "Baseline Touch" csv file';
                    case 4
                        prompt = 'Please select the "Post Touch" csv file';
                end
                
                
                [indx,tf] = listdlg('PromptString',prompt, 'ListString',list, 'SelectionMode','single', 'ListSize', [700 200]);
                
                SelectedFiles{j} = list{indx};
                
            end
            
            underscore = '_';
            bla = find(ExperimentName == underscore);
            ExperimentName(bla) = '-';
            
            obj.PATH.ExperimentName = ExperimentName;
            obj.PATH.analysisDir = analysisDir;
            
            BL_P_csv = SelectedFiles{1};
            pP_csv = SelectedFiles{2};
            BL_T_csv = SelectedFiles{3};
            pT_csv = SelectedFiles{4};
            
            obj.PATH.BL_P_csv = BL_P_csv;
            obj.PATH.pP_csv = pP_csv;
            
            obj.PATH.pT_csv = pT_csv;
            obj.PATH.BL_T_csv = BL_T_csv;
            
            %% Create plot Dirs
            
            obj.PATH.Plots = [analysisDir 'Plots' dirD];
            
            if exist(obj.PATH.Plots, 'dir') ==0
                mkdir(obj.PATH.Plots);
                disp(['Created directory: ' obj.PATH.Plots])
            end
            
            %             obj.PATH.pP_plots = [analysisDir 'pP_Plots' dirD];
            %
            %             if exist(obj.PATH.pP_plots, 'dir') ==0
            %                 mkdir(obj.PATH.pP_plots);
            %                 disp(['Created directory: ' obj.PATH.pP_plots])
            %             end
            %
            %             obj.PATH.pT_plots = [analysisDir 'pT_Plots' dirD];
            %
            %             if exist(obj.PATH.pT_plots, 'dir') ==0
            %                 mkdir(obj.PATH.pT_plots);
            %                 disp(['Created directory: ' obj.PATH.pT_plots])
            %             end
            
        end
        
        
        function [obj] = loadTrackedData(obj)
            
            for j = 1:4
                
                switch j
                    case 1
                        filename = [obj.PATH.analysisDir obj.PATH.BL_P_csv];
                        disp('Loading tracked data: baseline pain...')
                    case 2
                        filename = [obj.PATH.analysisDir obj.PATH.pP_csv];
                        disp('Loading tracked data: post Pain...')
                    case 3
                        filename = [obj.PATH.analysisDir obj.PATH.BL_T_csv];
                        disp('Loading tracked data: baseline touch...')
                        
                    case 4
                        filename = [obj.PATH.analysisDir obj.PATH.pT_csv];
                        disp('Loading tracked data: post Touch...')
                end
                %% Initialize variables.
                
                delimiter = ',';
                startRow = 2;
                
                %% Read columns of data as strings:
                % For more information, see the TEXTSCAN documentation.
                
                % This has to match the number of columns in the file
                % Use matlab2014 to import data if not sure
                formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';
                
                %% Open the text file.
                fileID = fopen(filename,'r');
                
                %% Read columns of data according to format string.
                % This call is based on the structure of the file used to generate this
                % code. If an error occurs for a different file, try regenerating the code
                % from the Import Tool.
                dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
                
                %% Close the text file.
                fclose(fileID);
                
                %% Convert the contents of columns containing numeric strings to numbers.
                % Replace non-numeric strings with NaN.
                raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
                for col=1:length(dataArray)-1
                    raw(1:length(dataArray{col}),col) = dataArray{col};
                end
                numericData = NaN(size(dataArray{1},1),size(dataArray,2));
                
                for col=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94]
                    %for col=1:size(dataArray, 2)
                    % Converts strings in the input cell array to numbers. Replaced non-numeric
                    % strings with NaN.
                    rawData = dataArray{col};
                    for row=1:size(rawData, 1)
                        % Create a regular expression to detect and remove non-numeric prefixes and
                        % suffixes.
                        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
                        try
                            result = regexp(rawData{row}, regexstr, 'names');
                            numbers = result.numbers;
                            
                            % Detected commas in non-thousand locations.
                            invalidThousandsSeparator = false;
                            if any(numbers==',')
                                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                                if isempty(regexp(thousandsRegExp, ',', 'once'))
                                    numbers = NaN;
                                    invalidThousandsSeparator = true;
                                end
                            end
                            % Convert numeric strings to numbers.
                            if ~invalidThousandsSeparator
                                numbers = textscan(strrep(numbers, ',', ''), '%f');
                                numericData(row, col) = numbers{1};
                                raw{row, col} = numbers{1};
                            end
                        catch me
                        end
                    end
                end
                
                
                %% Replace non-numeric cells with NaN
                R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
                raw(R) = {NaN}; % Replace non-numeric cells
                
                %% Allocate imported array to column variable names
                allCoords.bodyparts_scorer = cell2mat(raw(:, 1));
                
                %% Eye Stuff
                allCoords.uppereyelid.x = cell2mat(raw(:, 2));
                allCoords.uppereyelid.y = cell2mat(raw(:, 3));
                allCoords.uppereyelid.likelihood = cell2mat(raw(:, 4));
                
                allCoords.lowereyelid.x = cell2mat(raw(:, 5));
                allCoords.lowereyelid.y = cell2mat(raw(:, 6));
                allCoords.lowereyelid.likelihood = cell2mat(raw(:, 7));
                
                allCoords.eyecornerL.x = cell2mat(raw(:, 8));
                allCoords.eyecornerL.y = cell2mat(raw(:, 9));
                allCoords.eyecornerL.likelihood = cell2mat(raw(:, 10));
                
                allCoords.eyecornerM.x = cell2mat(raw(:, 11));
                allCoords.eyecornerM.y = cell2mat(raw(:, 12));
                allCoords.eyecornerM.likelihood = cell2mat(raw(:, 13));
                
                %% Beak stuff
                
                allCoords.upperbeak.x = cell2mat(raw(:, 14));
                allCoords.upperbeak.y = cell2mat(raw(:, 15));
                allCoords.upperbeak.likelihood = cell2mat(raw(:, 16));
                
                allCoords.lowerbeak.x = cell2mat(raw(:, 17));
                allCoords.lowerbeak.y = cell2mat(raw(:, 18));
                allCoords.lowerbeak.likelihood = cell2mat(raw(:, 19));
                
                allCoords.lowerbeakFeather.x = cell2mat(raw(:, 20));
                allCoords.lowerbeakFeather.y = cell2mat(raw(:, 21));
                allCoords.lowerbeakFeather.likelihood = cell2mat(raw(:, 22));
                
                allCoords.beakCorner.x = cell2mat(raw(:, 23));
                allCoords.beakCorner.y = cell2mat(raw(:, 24));
                allCoords.beakCorner.likelihood = cell2mat(raw(:, 25));
                
                allCoords.beakBase.x = cell2mat(raw(:, 26));
                allCoords.beakBase.y = cell2mat(raw(:, 27));
                allCoords.beakBase.likelihood = cell2mat(raw(:, 28));
                
                allCoords.nostrilR.x = cell2mat(raw(:, 29));
                allCoords.nostrilR.y = cell2mat(raw(:, 30));
                allCoords.nostrilR.likelihood = cell2mat(raw(:, 31));
                
                %%
                allCoords.front.x = cell2mat(raw(:, 32));
                allCoords.front.y = cell2mat(raw(:, 33));
                allCoords.front.likelihood = cell2mat(raw(:, 34));
                
                allCoords.elbow.x = cell2mat(raw(:, 35));
                allCoords.elbow.y = cell2mat(raw(:, 36));
                allCoords.elbow.likelihood = cell2mat(raw(:, 37));
                
                allCoords.knee.x = cell2mat(raw(:, 38));
                allCoords.knee.y = cell2mat(raw(:, 39));
                allCoords.knee.likelihood = cell2mat(raw(:, 40));
                
                allCoords.tarsusAbove.x = cell2mat(raw(:, 41));
                allCoords.tarsusAbove.y = cell2mat(raw(:, 42));
                allCoords.tarsusAbove.likelihood = cell2mat(raw(:, 43));
                
                allCoords.tarsus.x = cell2mat(raw(:, 44));
                allCoords.tarsus.y = cell2mat(raw(:, 45));
                allCoords.tarsus.likelihood = cell2mat(raw(:, 46));
                
                allCoords.tarsusBelow.x = cell2mat(raw(:, 47));
                allCoords.tarsusBelow.y = cell2mat(raw(:, 48));
                allCoords.tarsusBelow.likelihood = cell2mat(raw(:, 49));
                
                allCoords.tarsus1.x = cell2mat(raw(:, 50));
                allCoords.tarsus1.y = cell2mat(raw(:, 51));
                allCoords.tarsus1.likelihood = cell2mat(raw(:, 52));
                
                allCoords.tarsus2.x = cell2mat(raw(:, 53));
                allCoords.tarsus2.y = cell2mat(raw(:, 54));
                allCoords.tarsus2.likelihood = cell2mat(raw(:, 55));
                
                allCoords.metatarsus.x = cell2mat(raw(:, 56));
                allCoords.metatarsus.y = cell2mat(raw(:, 57));
                allCoords.metatarsus.likelihood = cell2mat(raw(:, 58));
                
                %% Foot
                allCoords.phalanxMedialis.x = cell2mat(raw(:, 59));
                allCoords.phalanxMedialis.y = cell2mat(raw(:, 60));
                allCoords.phalanxMedialis.likelihood = cell2mat(raw(:, 61));
                
                allCoords.phalanxDistalis.x = cell2mat(raw(:, 62));
                allCoords.phalanxDistalis.y = cell2mat(raw(:, 63));
                allCoords.phalanxDistalis.likelihood = cell2mat(raw(:, 64));
                
                %%
                allCoords.instrument.x = cell2mat(raw(:, 65));
                allCoords.instrument.y = cell2mat(raw(:, 66));
                allCoords.instrument.likelihood = cell2mat(raw(:, 67));
                
                %% Eggshell
                
                allCoords.esBluntEnd.x = cell2mat(raw(:, 68));
                allCoords.esBluntEnd.y = cell2mat(raw(:, 69));
                allCoords.esBluntEnd.likelihood = cell2mat(raw(:, 70));
                
                allCoords.esBluntHead.x = cell2mat(raw(:, 71));
                allCoords.esBluntHead.y = cell2mat(raw(:, 72));
                allCoords.esBluntHead.likelihood = cell2mat(raw(:, 73));
                
                allCoords.esHeadSide.x = cell2mat(raw(:, 74));
                allCoords.esHeadSide.y = cell2mat(raw(:, 75));
                allCoords.esHeadSide.likelihood = cell2mat(raw(:, 76));
                
                allCoords.esHeadPointed.x = cell2mat(raw(:, 77));
                allCoords.esHeadPointed.y = cell2mat(raw(:, 78));
                allCoords.esHeadPointed.likelihood = cell2mat(raw(:, 79));
                
                allCoords.esPointedEnd.x = cell2mat(raw(:, 80));
                allCoords.esPointedEnd.y = cell2mat(raw(:, 81));
                allCoords.esPointedEnd.likelihood = cell2mat(raw(:, 82));
                
                allCoords.esPointedBack.x = cell2mat(raw(:, 83));
                allCoords.esPointedBack.y = cell2mat(raw(:, 84));
                allCoords.esPointedBack.likelihood = cell2mat(raw(:, 85));
                
                allCoords.esBackSide.x = cell2mat(raw(:, 86));
                allCoords.esBackSide.y = cell2mat(raw(:, 87));
                allCoords.esBackSide.likelihood = cell2mat(raw(:, 88));
                
                allCoords.esBackBlunt.x = cell2mat(raw(:, 89));
                allCoords.esBackBlunt.y = cell2mat(raw(:, 90));
                allCoords.esBackBlunt.likelihood = cell2mat(raw(:, 91));
                
                %%
                allCoords.clamp.x = cell2mat(raw(:, 92));
                allCoords.clamp.y = cell2mat(raw(:, 93));
                allCoords.clamp.likelihood = cell2mat(raw(:, 94));
                
                %%
                varNames = {'bodyparts_scorer', 'uppereyelid', 'lowereyelid', 'eyecornerL' 'eyecornerM', 'upperbeak', 'lowerbeak', 'lowerbeakFeather', 'beakCorner', 'beakBase', 'nostrilR', 'front', 'elbow', 'knee', 'tarsusAbove',  'tarsus', 'tarsusBelow', 'tarsus1', 'tarsus2', 'metatarsus', 'phalanxMedialis', 'phalanxDistalis', 'instrument', 'esBluntEnd', 'esBluntHead', 'esHeadSide', 'esHeadPointed', 'esPointedEnd', 'esPointedBack', 'esBackSide', 'esBackBlunt', 'clamp' } ;
                
                allCoords.nEntries = numel(allCoords.uppereyelid.y);
                
                switch j
                    case 1 %Baseline Pain
                        obj.COORDS.BL_P = allCoords;
                        obj.COORDS.BL_P_varNames = varNames;
                        
                    case 2 %postPain
                        
                        obj.COORDS.pP = allCoords;
                        obj.COORDS.pP_varNames = varNames;
                        
                    case 3 % Baseline Touch
                        
                        obj.COORDS.BL_T = allCoords;
                        obj.COORDS.BL_T_varNames = varNames;
                        
                    case 4 %postTouch
                        
                        obj.COORDS.pT = allCoords;
                        obj.COORDS.pT_varNames = varNames;
                        
                end
                
                disp('Body parts annotated: ')
                celldisp(varNames);
                disp(['n Entries: ' num2str(allCoords.nEntries )]);
                
                %% Clear temporary variables
                clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me R;
                
                disp('done...')
            end
            
        end
        
        
        
        %% Analysis
        
        function [obj] = plot_variable_over_time(obj, variable)
            
            
            plotPath = obj.PATH.Plots;
            
            savePath = [plotPath 'RawCoordinates\'];
            
            if exist(savePath, 'dir') ==0
                mkdir(savePath);
                disp(['Created directory: ' savePath])
            end
            
            
            fps = obj.VID.fps;
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            
            [indx,tf] = listdlg('PromptString','Choose tracked objects :', 'ListString',list);
            
            nChoices = numel(indx);
            for k = 1:nChoices
                allChoices{k} = list{indx(k)};
            end
            
            for  k =1:4
                
                switch k
                    case 1 %BL
                        coords = obj.COORDS.BL_P;
                        varNames = obj.COORDS.BL_P_varNames;
                        
                    case 2 %postPain
                        
                        coords = obj.COORDS.pP;
                        varNames = obj.COORDS.pP_varNames;
                        
                    case 3 %postTouch
                        coords = obj.COORDS.BL_T;
                        varNames = obj.COORDS.BL_T_varNames;
                        
                    case 4 %postTouch
                        coords = obj.COORDS.pT;
                        varNames = obj.COORDS.pT_varNames;
                        
                        
                end
                
                
                
                cols = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]
                    [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]
                    [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]
                    [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]
                    [0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]
                    };
                
                %% Iterate over Choices
                % figH = figure(100);clf
                figure(100+k);clf
                figure(200+k);clf
                for j = 1:nChoices
                    
                    thisTrackedObject = allChoices{j};
                    
                    switch variable
                        
                        case 1
                            eval(['likelihood = coords.' thisTrackedObject '.likelihood;']);
                            data = likelihood;
                            varText = 'likelihood';
                            ylab = 'Likelihood';
                        case 2
                            
                            eval(['coords_X = coords.' thisTrackedObject '.x;']);
                            data = coords_X;
                            
                            varText = 'value';
                            ylab = 'x-coords';
                        case 3
                            eval(['coords_Y = coords.' thisTrackedObject '.y;']);
                            data = coords_Y;
                            varText = 'value';
                            ylab = 'y-coords';
                    end
                    
                    figure(100+k)
                    subplot(nChoices, 1, j)
                    
                    timepoints_frames = 1:1:numel(data);
                    timepoints_s = timepoints_frames/fps;
                    
                    %plot(likelihood, 'color', cols{j}, 'marker', '.', 'markersize', 2, 'linestyle', '-')
                    plot(timepoints_s, data, 'color', cols{j}, 'linestyle', '-')
                    %  legend(thisTrackedObject)
                    %   legend ('boxoff')
                    axis tight
                    meanVal = nanmean(data);
                    stdVal = nanstd(data);
                    
                    minVal(j) = min(data);
                    maxVal(j) = max(data);
                    
                    title([thisTrackedObject ' | Mean ' varText ': '   num2str(meanVal) ' \pm ' num2str(stdVal) ' (std)' ])
                    ylabel(ylab)
                    
                    if j == nChoices
                        xlabel('Time (s)')
                    end
                    
                    %%
                    figure(200+k)
                    subplot(nChoices, 1, j)
                    boxplot(data, 'whisker', 100)
                    
                    title([thisTrackedObject ' | Mean ' varText ': '   num2str(meanVal) ' \pm ' num2str(stdVal) ' (std)' ])
                    ylabel(ylab)
                    
                    
                end
                
                
                allMinVals(:,k) = minVal;
                allMaxVals(:,k) = maxVal;
                
            end
            
            allMins = min(allMinVals, [], 2);
            allMaxs = max(allMaxVals, [], 2);
            
            for  o = 1:4
                switch o
                    case 1
                        expText = 'BL-Pain';
                        
                    case 2
                        expText = 'postPain';
                        
                    case 3
                        expText = 'BL-Touch';
                        
                    case 4
                        expText = 'postTouch';
                        
                end
                figH = figure(100+o);
                for oo = 1:nChoices
                    
                    subplot(nChoices, 1, oo)
                    ylim([allMins(oo)  allMaxs(oo)])
                end
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[obj.PATH.ExperimentName '-' expText],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                
                saveName = [savePath ylab '_' expText ];
                plotpos = [0 0 15 20]; % keep this so arena dims look ok
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                
                figH = figure(200+o);
                
                %                 for oo = 1:nChoices
                %
                %                     subplot(nChoices, 1, oo)
                %                     ylim([allMins(oo)  allMaxs(oo)])
                %                 end
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[obj.PATH.ExperimentName '-' expText],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                saveName = [savePath ylab '_' expText '_Boxplot'];
                plotpos = [0 0 15 20]; % keep this so arena dims look ok
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                
            end
        end
        
        
        
        function [obj] = plotDetectionClusters(obj, likelihood_cutoff, SaveNameTxt)
            
            plotPath = obj.PATH.Plots;
            
            savePath = [plotPath 'DetectionClusters\'];
            
            if exist(savePath, 'dir') ==0
                mkdir(savePath);
                disp(['Created directory: ' savePath])
            end
            
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            [indx,tf] = listdlg('PromptString','Choose tracked objects:', 'ListString',list);
            
            nChoices = numel(indx);
            for k = 1:nChoices
                allChoices{k} = list{indx(k)};
            end
            
            for j = 1:4
                
                switch j
                    case 1 %BL
                        coords = obj.COORDS.BL_P;
                        varNames = obj.COORDS.BL_P_varNames;
                        
                        expText = 'BL-Pain';
                        
                    case 2 %postPain
                        
                        coords = obj.COORDS.pP;
                        varNames = obj.COORDS.pP_varNames;
                        
                        expText = 'postPain';
                        
                        
                    case 3 %postTouch
                        coords = obj.COORDS.BL_T;
                        varNames = obj.COORDS.BL_T_varNames;
                        
                        expText = 'BL-Touch';
                        
                    case 4 %postTouch
                        coords = obj.COORDS.pT;
                        varNames = obj.COORDS.pT_varNames;
                        
                        expText = 'postTouch';
                        
                end
                
                
                
                vidHeight = 1080;
                vidWidth = 1920;
                
                cols = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]};
                
                %% Iterate over Choices
                figH = figure(100+j);clf
                
                trackedText = [];
                legText = [];
                for j = 1:nChoices
                    
                    thisTrackedObject = allChoices{j};
                    
                    eval(['coords_X = coords.' thisTrackedObject '.x;']);
                    eval(['coords_Y = coords.' thisTrackedObject '.y;']);
                    eval(['likelihood = coords.' thisTrackedObject '.likelihood;']);
                    
                    hold on
                    % liklihood
                    HL_inds = find(likelihood >= likelihood_cutoff);
                    n_inds = numel(HL_inds);
                    
                    % plot(coords_X, coords_Y, 'color', C(j,:), 'marker', '.', 'markersize', 10, 'linestyle', 'none')
                    plot(coords_X(HL_inds), coords_Y(HL_inds), 'color', cols{j}, 'marker', '.', 'markersize', 10, 'linestyle', '-')
                    trackedText = [trackedText '-' thisTrackedObject];
                    legText{j} = thisTrackedObject;
                    
                end
                
                xlim([0 vidWidth]);
                ylim([0 vidHeight]);
                legend(legText)
                legend ('boxoff')
                legend('location', 'eastoutside')
                figure(figH)
                title(['Detection clusters | Likelihood  Cutoff: ' num2str(likelihood_cutoff)])
                ylabel('y coordinates')
                xlabel('x coordinates')
                
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[ obj.PATH.ExperimentName '-' expText],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                disp('Printing Plot')
                
                saveName = [savePath SaveNameTxt '-DetectionClusters_' expText];
                plotpos = [0 0 25 18]; % keep this so arena dims look ok
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
            end
        end
        
        function [obj] = plotDistanceBetweenTwoPoints(obj, likelihood_cutoff)
            
            plotPath = obj.PATH.Plots;
            
            savePath = [plotPath 'DistanceBetweenPoints\'];
            
            if exist(savePath, 'dir') ==0
                mkdir(savePath);
                disp(['Created directory: ' savePath])
            end
            
            
            fps = obj.VID.fps;
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            [indx,tf] = listdlg('PromptString','Choose tracked objects:', 'ListString',list);
            
            nChoices = numel(indx);
            for k = 1:nChoices
                allChoices{k} = list{indx(k)};
            end
            
            for j = 1:4
                
                switch j
                    case 1 %BL
                        coords = obj.COORDS.BL_P;
                        varNames = obj.COORDS.BL_P_varNames;
                        
                        expText = 'BL-Pain';
                        
                    case 2 %postPain
                        
                        coords = obj.COORDS.pP;
                        varNames = obj.COORDS.pP_varNames;
                        
                        expText = 'postPain';
                        
                    case 3 %postTouch
                        coords = obj.COORDS.BL_T;
                        varNames = obj.COORDS.BL_T_varNames;
                        
                        expText = 'BL-Touch';
                        
                        
                    case 4 %postTouch
                        coords = obj.COORDS.pT;
                        varNames = obj.COORDS.pT_varNames;
                        
                        expText = 'postTouch';
                        
                end
                
                plotPath = obj.PATH.Plots;
                
                vidHeight = 1080;
                vidWidth = 1920;
                
                cols = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]};
                
                %% Iterate over Choices
                
                
                timeRes_s = 1/fps;
                
                %for oo = 1:nChoices
                
                thisTrackedObject1 = allChoices{1};
                thisTrackedObject2 = allChoices{2};
                
                eval(['coords_X_1 = coords.' thisTrackedObject1 '.x;']);
                eval(['coords_Y_1 = coords.' thisTrackedObject1 '.y;']);
                eval(['likelihood_1 = coords.' thisTrackedObject1 '.likelihood;']);
                
                
                eval(['coords_X_2 = coords.' thisTrackedObject2 '.x;']);
                eval(['coords_Y_2 = coords.' thisTrackedObject2 '.y;']);
                eval(['likelihood_2 = coords.' thisTrackedObject2 '.likelihood;']);
                
                
                hold on
                % liklihood
                HL_inds_1 = find(likelihood_1 < likelihood_cutoff);
                n_inds_1 = numel(HL_inds_1);
                
                HL_inds_2 = find(likelihood_2 < likelihood_cutoff);
                n_inds_2 = numel(HL_inds_2);
                
%                 c_X_1 = coords_X_1(HL_inds_1);
%                 c_Y_1 = coords_Y_1(HL_inds_1);
%                 
%                 c_X_2 = coords_X_2(HL_inds_2);
%                 c_Y_2 = coords_Y_2(HL_inds_2);
                
                c_X_1 = coords_X_1;
                c_Y_1 = coords_Y_1;
                
                c_X_1(HL_inds_1) = nan; % set all low probabilities to 0
                c_Y_1(HL_inds_1) = nan;
                
                c_X_2 = coords_X_2;
                c_Y_2 = coords_Y_2;
                
                c_X_2(HL_inds_2)= nan;
                c_Y_2(HL_inds_2) = nan;
                
                
%                 if numel(c_X_1) ~= numel(c_X_2)
%                     keyboard
%                 end
                
                euclideanDistance = [];
                for k = 1:numel(c_X_1)
                    point_1_xy_t0 = [c_X_1(k), c_Y_1(k)];
                    point_2_xy_t0 = [c_X_2(k), c_Y_2(k)];
                    
                    distance = [point_1_xy_t0; point_2_xy_t0];
                    euclideanDistance(k) = pdist(distance,'euclidean');
                    
                end
                
                nMissingDatapoints = sum(isnan(euclideanDistance));
                
                meanVal_euclidian = nanmean(euclideanDistance);
                stdVal_euclidian = nanstd(euclideanDistance);
                
                timepoints_frames = 1:1:numel(euclideanDistance);
                timepoints_s =timepoints_frames/fps;
                
                velocity_px_per_s = euclideanDistance/timeRes_s;
                
                meanVal_vel = nanmean(velocity_px_per_s);
                stdVal_vel = nanstd(velocity_px_per_s);
                
                %%
                figH = figure(105); clf
                
                hold on
                plot(timepoints_s, euclideanDistance, 'color', cols{1}, 'marker', '.', 'markersize', 5, 'linestyle', '-')
                %clear('coords_X', 'coords_Y');
                axis tight
                %ylim([0 5])
                title(['Mean Distance between ' thisTrackedObject1 ' and ' thisTrackedObject2  ' | Mean Euclidean distance: '   num2str(meanVal_euclidian) ' \pm ' num2str(stdVal_euclidian) ' (std)' ])
                ylabel('Distance (px)')
                xlabel('Time (s)')
                
                plotpos = [0 0 40 12]; % keep this so arena dims look ok
                
                
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[obj.PATH.ExperimentName '-' expText ' | Likelihood  Cutoff: ' num2str(likelihood_cutoff)],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                saveName = [savePath 'Distance_' thisTrackedObject1 '-' thisTrackedObject2 '_'  expText];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                allEucDistOverExps{j} = euclideanDistance;
                allExpLabs{j} = expText;
                
            end
            
            saveNameDistances = [savePath 'EuclideanDistanceTwoPoints.mat'];
            save(saveNameDistances, 'allEucDistOverExps', 'allChoices')
            
            obj.PATH.EuclideanMat = saveNameDistances;
            
            %% Make summary plots
            
            figHH = figure(305); clf
            
            distance_BL_Pain = allEucDistOverExps{1}';
            distance_Pain = allEucDistOverExps{2}';
            
            x = [distance_BL_Pain; distance_Pain;];
            g = [zeros(length(distance_BL_Pain), 1); ones(length(distance_Pain), 1)];
            subplot(2, 3, [1 4])
            boxplot(x, g, 'color', [0.5 0.5 0.5], 'symbol', '.', 'whisker', 0, 'jitter', 0.75, 'Labels',{'BL-Touch','Touch'})
            hold on
            boxplot(x, g, 'color', 'k', 'whisker', inf, 'Labels',{'BL-Pain','Pain'})
            
            yss = ylim;
            ylabel(['Distance between ' thisTrackedObject1 ' and ' thisTrackedObject2 ' (px)'])
            title([obj.PATH.ExperimentName ' | Likelihood  Cutoff: ' num2str(likelihood_cutoff)])
            distance_BL_Touch = allEucDistOverExps{3}';
            distance_Touch = allEucDistOverExps{4}';
            
            x = [distance_BL_Touch; distance_Touch;];
            g = [zeros(length(distance_BL_Touch), 1); ones(length(distance_Touch), 1)];
            subplot(2, 3, [2 5])
            
            boxplot(x, g, 'color', [0.5 0.5 0.5], 'symbol', '.', 'whisker', 0, 'jitter', 0.75, 'Labels',{'BL-Touch','Touch'})
            hold on
            boxplot(x, g, 'color', 'k', 'whisker', inf, 'Labels',{'BL-Touch','Touch'})
            
            ylim(yss )
            title(obj.PATH.ExperimentName)
            
            %%
            [p1, h1] = ranksum(distance_BL_Pain, distance_Pain);
            [p2, h2] = ranksum(distance_BL_Touch, distance_Touch);
            
            Name = {'BL v Pain';'BL v Touch'};
            h = [h1;h2];
            p = [p1;p2];
            T = table(h,p,'RowNames',Name);
            
            ha = subplot(2, 3, 3);
            pos = get(ha,'Position');
            un = get(ha,'Units');
            delete(ha)
            
            ht = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
                'RowName',T.Properties.RowNames,'Units', un, 'Position',pos);
            ha = subplot(2, 3, 3);
            title(['Wilcoxon Ranksum statistics'])
            axis off
            
            
            %%
            median_BL_P = nanmedian(distance_BL_Pain);
            std_BL_P = nanstd(distance_BL_Pain);
            
            median_P = nanmedian(distance_Pain);
            std_P = nanstd(distance_Pain);
            
            
            median_BL_T = nanmedian(distance_BL_Touch);
            std_BL_T = nanstd(distance_BL_Touch);
            
            median_T = nanmedian(distance_Touch);
            std_T = nanstd(distance_Touch);
            
            
            medians = [median_BL_P; median_P; median_BL_T; median_T];
            stds = [std_BL_P; std_P; std_BL_T; std_T];
            
            Name = {'BL-Pain';'Pain'; 'BL-Touch';'Touch'};
            
            T = table(medians,stds,'RowNames',Name);
            
            ha = subplot(2, 3, 6);
            pos = get(ha,'Position');
            un = get(ha,'Units');
            delete(ha)
            
            ht = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
                'RowName',T.Properties.RowNames,'Units', un, 'Position',pos);
            ha = subplot(2, 3, 6);
            title(['Medians and Stds'])
            axis off
            
            
            plotpos = [0 0 40 12]; % keep this so arena dims look ok
            
            saveName = [savePath 'DistanceBoxplot_' thisTrackedObject1 '-' thisTrackedObject2];
            print_in_A4(0, saveName, '-djpeg', 0, plotpos);
            
            %% Create table to save
            
            for k = 1:4
                
                Distance_px = allEucDistOverExps{k}';
                tt = table(Distance_px);
                
                saveName = [savePath 'Distances_' thisTrackedObject1 '-' thisTrackedObject2 '_' allExpLabs{k}];
                writetable(tt, [saveName '.xls'])
                
            end
            
            
        end
        
        
        function [obj] = plotAngleBetweenThreePoints(obj, likelihood_cutoff)
            
            plotPath = obj.PATH.Plots;
            
            savePath = [plotPath 'AngleBetweenPoints\'];
            
            if exist(savePath, 'dir') ==0
                mkdir(savePath);
                disp(['Created directory: ' savePath])
            end
            
            
            fps = obj.VID.fps;
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            [indx,tf] = listdlg('PromptString','Choose two objects:', 'ListString',list);
            
            nChoices = numel(indx);
            for k = 1:nChoices
                allChoices{k} = list{indx(k)};
            end
            
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            [indx,tf] = listdlg('PromptString','Choose reference point:', 'ListString',list);
            refChoice = list{indx};
            
            
            
            coords = []; varNames = [];
            for j = 1:4
                
                switch j
                    case 1 %BL
                        coords = obj.COORDS.BL_P;
                        varNames = obj.COORDS.BL_P_varNames;
                        
                        expText = 'BL-Pain';
                        
                    case 2 %postPain
                        
                        coords = obj.COORDS.pP;
                        varNames = obj.COORDS.pP_varNames;
                        
                        expText = 'postPain';
                        
                    case 3 %postTouch
                        coords = obj.COORDS.BL_T;
                        varNames = obj.COORDS.BL_T_varNames;
                        
                        expText = 'BL-Touch';
                        
                        
                    case 4 %postTouch
                        coords = obj.COORDS.pT;
                        varNames = obj.COORDS.pT_varNames;
                        
                        expText = 'postTouch';
                        
                end
                
                plotPath = obj.PATH.Plots;
                
                vidHeight = 1080;
                vidWidth = 1920;
                
                cols = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]};
                
                %% Iterate over Choices
                
                
                timeRes_s = 1/fps;
                
                %for oo = 1:nChoices
                
                thisTrackedObject1 = allChoices{1};
                thisTrackedObject2 = allChoices{2};
                
                refObject = refChoice;
                
                eval(['coords_X_1 = coords.' thisTrackedObject1 '.x;']);
                eval(['coords_Y_1 = coords.' thisTrackedObject1 '.y;']);
                eval(['likelihood_1 = coords.' thisTrackedObject1 '.likelihood;']);
                
                
                eval(['coords_X_2 = coords.' thisTrackedObject2 '.x;']);
                eval(['coords_Y_2 = coords.' thisTrackedObject2 '.y;']);
                eval(['likelihood_2 = coords.' thisTrackedObject2 '.likelihood;']);
                
                eval(['coords_X_R = coords.' refObject '.x;']);
                eval(['coords_Y_R = coords.' refObject '.y;']);
                eval(['likelihood_R = coords.' refObject '.likelihood;']);
                
                
                hold on
                % liklihood
                HL_inds_1 = find(likelihood_1 < likelihood_cutoff);
                n_inds_1 = numel(HL_inds_1);
                
                HL_inds_2 = find(likelihood_2 < likelihood_cutoff);
                n_inds_2 = numel(HL_inds_2);
                
                  
                HL_inds_R = find(likelihood_R < likelihood_cutoff);
                n_inds_R = numel(HL_inds_R);
                
                
                c_X_1 = coords_X_1;
                c_Y_1 = coords_Y_1;
                
                c_X_1(HL_inds_1) = nan; % set all low probabilities to 0
                c_Y_1(HL_inds_1) = nan;
                
                c_X_2 = coords_X_2;
                c_Y_2 = coords_Y_2;
                
                c_X_2(HL_inds_2)= nan;
                c_Y_2(HL_inds_2) = nan;
                
                c_X_R = coords_X_R;
                c_Y_R = coords_Y_R;
                
                c_X_R(HL_inds_R) = nan;
                c_Y_R(HL_inds_R) = nan;
                
                % P1 = [10  210];
                % P2 = [140 210];
                % Z0 = [(P1(1)+P2(1))/2 225]; % Reference point, assuming it is in the middle of P1 & P2
                % degree = 2*atand((P2(1)-Z0(1))/(Z0(2)-P2(2)));
                
                %atan2(y2-y1,x2-x1)
                figure(205); clf
                
                %{
                    
                    P0 = [x0, y0];
P1 = [x1, y1];
P2 = [x2, y2];
n1 = (P2 - P0) / norm(P2 - P0);  % Normalized vectors
n2 = (P1 - P0) / norm(P1 - Po);
angle1 = acos(dot(n1, n2));                        % Instable at (anti-)parallel n1 and n2
angle2 = asin(norm(cropss(n1, n2));                % Instable at perpendiculare n1 and n2
angle3 = atan2(norm(cross(n1, n2)), dot(n1, n2));  % Stable
%https://de.mathworks.com/matlabcentral/answers/331017-calculating-angle-between-three-points


%For example, there is line  L1 between two points (x1,y1) and (x2,y2). Another line L2 between points (x1,y1) and (x3,y3).
%I want to find the angle between the
%lines L1, L2. How to find in MATLAB? I think in matlab there is no predefined function which performs the same.

v_1 = [x2,y2,0] - [x1,y1,0];
v_2 = [x3,y3,0] - [x1,y1,0];
Theta = atan2(norm(cross(v_1, v_2)), dot(v_1, v_2));


                %}
                angle3 = []; deg = [];

                for k = 1:numel(c_X_1)
                    
                    
                    v_1 = [c_X_1(k), c_Y_1(k), 0] - [c_X_R(k), c_Y_R(k), 0];
                    v_2 = [c_X_2(k), c_Y_2(k), 0] - [c_X_R(k), c_Y_R(k), 0];
                    Theta(k) = atan2(norm(cross(v_1, v_2)), dot(v_1, v_2));
                    
                    %Let row vectors P0 = [x0,y0], P1 = [x1,y1], and P2 = [x2,y2] be Calcaneus
                    P1 = [c_X_1(k) c_Y_1(k)];
                    P2 = [c_X_2(k) c_Y_2(k)];
                    P0 = [c_X_R(k) c_Y_R(k)];
                    
                    
                    ang(k) = atan2(abs(det([P2-P0;P1-P0])),dot(P2-P0,P1-P0));
                    
                    P1 = [c_X_1(k), c_Y_1(k)];
                    P2 = [c_X_2(k), c_Y_2(k)];
                    P0 = [c_X_R(k), c_Y_R(k)];
                    
                    n1 = (P2 - P0) / norm(P2 - P0);  % Normalized vectors
                    n2 = (P1 - P0) / norm(P1 - P0);
                    
                    angle3(k) = atan2(norm(det([n2; n1])), dot(n1, n2));
                    deg(k) = rad2deg(angle3(k));
                    
                    %                     hold on
                    %                     line([c_X_R(k) c_X_1(k)], [ c_Y_R(k) c_Y_1(k)])
                    %                     line([c_X_R(k) c_X_2(k)], [ c_Y_R(k) c_Y_2(k)])
                    
                end
                
                meanVal_angle = nanmean(deg);
                stdVal_angle = nanstd(deg);
                
                timepoints_frames = 1:1:numel(deg);
                timepoints_s =timepoints_frames/fps;
                
                
                %%
                figH = figure(105); clf
                
                hold on
                plot(timepoints_s, deg, 'color', cols{1}, 'marker', '.', 'markersize', 5, 'linestyle', '-')
                %clear('coords_X', 'coords_Y');
                axis tight
                %ylim([0 5])
                title(['Mean angle between ' thisTrackedObject1 ' and ' thisTrackedObject2  ' | Mean angle (deg): '   num2str(meanVal_angle) ' \pm ' num2str(stdVal_angle) ' (std)' ])
                ylabel('Angle (deg)')
                xlabel('Time (s)')
                
                plotpos = [0 0 40 12]; % keep this so arena dims look ok
                
                
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[obj.PATH.ExperimentName '-' expText ' | Likelihood  Cutoff: ' num2str(likelihood_cutoff)],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                saveName = [savePath thisTrackedObject1 '-' thisTrackedObject2 '_Degree' expText];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                allDegreesOverExps{j} = deg;
                allExpLabs{j} = expText;
            end
            
            saveNameDistances = [savePath 'AngleBetweenTwoPoints.mat'];
            save(saveNameDistances, 'Theta', 'ang', 'angle3', 'deg', 'allChoices', 'refChoice')
            
            obj.PATH.AngleMat = saveNameDistances;
            
            %%
            
            
            figHH = figure(305); clf
            
            distance_BL_Pain = allDegreesOverExps{1}';
            distance_Pain = allDegreesOverExps{2}';
            
            x = [distance_BL_Pain; distance_Pain;];
            g = [zeros(length(distance_BL_Pain), 1); ones(length(distance_Pain), 1)];
            subplot(2, 3, [1 4])
            boxplot(x, g, 'color', [0.5 0.5 0.5], 'symbol', '.', 'whisker', 0, 'jitter', 0.75, 'Labels',{'BL-Touch','Touch'})
            hold on
            boxplot(x, g, 'color', 'k', 'whisker', inf, 'Labels',{'BL-Pain','Pain'})
            
            yss = ylim;
            ylabel(['Angle between ' thisTrackedObject1 ' and ' thisTrackedObject2 ' (Deg.)'])
            title([obj.PATH.ExperimentName ' | Likelihood  Cutoff: ' num2str(likelihood_cutoff)])
            distance_BL_Touch = allDegreesOverExps{3}';
            distance_Touch = allDegreesOverExps{4}';
            
            x = [distance_BL_Touch; distance_Touch;];
            g = [zeros(length(distance_BL_Touch), 1); ones(length(distance_Touch), 1)];
            subplot(2, 3, [2 5])
            
            boxplot(x, g, 'color', [0.5 0.5 0.5], 'symbol', '.', 'whisker', 0, 'jitter', 0.75, 'Labels',{'BL-Touch','Touch'})
            hold on
            boxplot(x, g, 'color', 'k', 'whisker', inf, 'Labels',{'BL-Touch','Touch'})
            
            
            ylim(yss)
            title(obj.PATH.ExperimentName)
            
            %%
            [p1, h1] = ranksum(distance_BL_Pain, distance_Pain);
            [p2, h2] = ranksum(distance_BL_Touch, distance_Touch);
            
            Name = {'BL v Pain';'BL v Touch'};
            h = [h1;h2];
            p = [p1;p2];
            T = table(h,p,'RowNames',Name);
            
            ha = subplot(2, 3, 3);
            pos = get(ha,'Position');
            un = get(ha,'Units');
            delete(ha)
            
            ht = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
                'RowName',T.Properties.RowNames,'Units', un, 'Position',pos);
            ha = subplot(2, 3, 3);
            title(['Wilcoxon Ranksum statistics'])
            axis off
            
            
            %%
            median_BL_P = nanmedian(distance_BL_Pain);
            std_BL_P = nanstd(distance_BL_Pain);
            
            median_P = nanmedian(distance_Pain);
            std_P = nanstd(distance_Pain);
            
            
            median_BL_T = nanmedian(distance_BL_Touch);
            std_BL_T = nanstd(distance_BL_Touch);
            
            median_T = nanmedian(distance_Touch);
            std_T = nanstd(distance_Touch);
            
            
            medians = [median_BL_P; median_P; median_BL_T; median_T];
            stds = [std_BL_P; std_P; std_BL_T; std_T];
            
            Name = {'BL-Pain';'Pain'; 'BL-Touch';'Touch'};
            
            T = table(medians,stds,'RowNames',Name);
            
            ha = subplot(2, 3, 6);
            pos = get(ha,'Position');
            un = get(ha,'Units');
            delete(ha)
            
            ht = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
                'RowName',T.Properties.RowNames,'Units', un, 'Position',pos);
            ha = subplot(2, 3, 6);
            title(['Medians and Stds'])
            axis off
            
            
            plotpos = [0 0 40 12]; % keep this so arena dims look ok
            
            saveName = [savePath thisTrackedObject1 '-' thisTrackedObject2 '_AngleBoxplot'];
            print_in_A4(0, saveName, '-djpeg', 0, plotpos);
            
            Angles_deg = []; tt = [];
            for k = 1:4
                
                Angles_deg = allDegreesOverExps{k}';
                tt = table(Angles_deg);
                
                saveName = [savePath 'Degrees_' thisTrackedObject1 '-' thisTrackedObject2 '_' allExpLabs{k}];
                writetable(tt, [saveName '.xls'])
                
            end
            
            
            
            
        end
        
        
        
        function [obj] = plotVelocity(obj, SaveNameTxt, likelihood_cutoff)
            
            
            plotPath = obj.PATH.Plots;
            
            savePath = [plotPath 'Velocity\'];
            
            if exist(savePath, 'dir') ==0
                mkdir(savePath);
                disp(['Created directory: ' savePath])
            end
            
            
            fps = obj.VID.fps;
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            [indx,tf] = listdlg('PromptString','Choose tracked objects:', 'ListString',list);
            
            nChoices = numel(indx);
            for k = 1:nChoices
                allChoices{k} = list{indx(k)};
            end
            
            for j = 1:4
                
                switch j
                    case 1 %BL
                        coords = obj.COORDS.BL_P;
                        varNames = obj.COORDS.BL_P_varNames;
                        
                        expText = 'BL-Pain';
                        
                    case 2 %postPain
                        
                        coords = obj.COORDS.pP;
                        varNames = obj.COORDS.pP_varNames;
                        
                        expText = 'postPain';
                        
                    case 3 %postTouch
                        coords = obj.COORDS.BL_T;
                        varNames = obj.COORDS.BL_T_varNames;
                        
                        expText = 'BL-Touch';
                        
                        
                    case 4 %postTouch
                        coords = obj.COORDS.pT;
                        varNames = obj.COORDS.pT_varNames;
                        
                        expText = 'postTouch';
                        
                end
                
                plotPath = obj.PATH.Plots;
                
                vidHeight = 1080;
                vidWidth = 1920;
                
                cols = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                    [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                    [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]};
                
                %% Iterate over Choices
                
                figure(100+j);clf
                figure(200+j);clf
                
                timeRes_s = 1/fps;
                
                for oo = 1:nChoices
                    
                    thisTrackedObject = allChoices{oo};
                    
                    eval(['coords_X = coords.' thisTrackedObject '.x;']);
                    eval(['coords_Y = coords.' thisTrackedObject '.y;']);
                    eval(['likelihood = coords.' thisTrackedObject '.likelihood;']);
                    
                    hold on
                    % liklihood
                    HL_inds = find(likelihood >= likelihood_cutoff);
                    n_inds = numel(HL_inds);
                    
                    c_X = coords_X(HL_inds);
                    c_Y = coords_Y(HL_inds);
                    
                    euclideanDistance = [];
                    for k = 1:numel(c_X)-1
                        point_xy_t0 = [c_X(k), c_Y(k)];
                        point_xy_t1 = [c_X(k+1), c_Y(k+1)];
                        distance = [point_xy_t0; point_xy_t1];
                        euclideanDistance(k) = pdist(distance,'euclidean');
                        
                    end
                    
                    meanVal_euclidian = mean(euclideanDistance);
                    stdVal_euclidian = std(euclideanDistance);
                    
                    timepoints_frames = 1:1:numel(euclideanDistance);
                    timepoints_s =timepoints_frames/fps;
                    
                    velocity_px_per_s = euclideanDistance/timeRes_s;
                    
                    meanVal_vel = mean(velocity_px_per_s);
                    stdVal_vel = std(velocity_px_per_s);
                    
                    figure(100+j)
                    subplot(nChoices, 1, oo)
                    hold on
                    plot(timepoints_s, euclideanDistance, 'color', cols{oo}, 'marker', '.', 'markersize', 5, 'linestyle', '-')
                    clear('coords_X', 'coords_Y');
                    axis tight
                    ylim([0 5])
                    title([thisTrackedObject ' | Mean Euclidean distance: '   num2str(meanVal_euclidian) ' \pm ' num2str(stdVal_euclidian) ' (std)' ])
                    ylabel('Distance (px)')
                    
                    figure(200+j)
                    subplot(nChoices, 1, oo)
                    hold on
                    plot(timepoints_s, velocity_px_per_s, 'color', cols{oo}, 'marker', '.', 'markersize', 5, 'linestyle', '-')
                    clear('coords_X', 'coords_Y');
                    axis tight
                    ylim([0 100])
                    title([thisTrackedObject ' | Mean velocity: '   num2str(meanVal_vel) ' \pm ' num2str(stdVal_vel) ' (std)' ])
                    ylabel('Velocity (px/s)')
                    
                    allEucDist{oo} = euclideanDistance;
                    allVel{oo} = velocity_px_per_s;
                end
                
               % plotPath = obj.PATH.Plots;
                plotpos = [0 0 15 20]; % keep this so arena dims look ok
                
                figH = figure(200+j);
                xlabel('Time (s)')
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[obj.PATH.ExperimentName '-' expText ' | Likelihood  Cutoff: ' num2str(likelihood_cutoff)],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                saveName = [savePath SaveNameTxt '_Velocity' expText];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                figH = figure(100+j);
                xlabel('Time (s)')
                annotation(figH,'textbox',[0.1 0.96 0.46 0.028],'String',[obj.PATH.ExperimentName '-' expText],'LineStyle','none','FitBoxToText','off', 'fontsize', 12);
                saveName = [savePath SaveNameTxt '_Distance' expText];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                allEucDistOverExps{j} = allEucDist;
                allVelsOverExps{j} = allVel;
            end
            
            saveNameDistances = [savePath SaveNameTxt '_Euclidean.mat'];
            save(saveNameDistances, 'allEucDistOverExps', 'allVelsOverExps', 'allChoices')
            
            obj.PATH.EuclideanMat = saveNameDistances;
            
        end
        
        
        
        function [obj] = plotMovement(obj, likelihood_cutoff)
            
            plotPath = obj.PATH.Plots;
            
            savePath = [plotPath 'Movement\'];
            
            if exist(savePath, 'dir') ==0
                mkdir(savePath);
                disp(['Created directory: ' savePath])
            end
            
            
            fps = obj.VID.fps;
            
            list = {obj.COORDS.BL_P_varNames{2:end}};
            [indx,tf] = listdlg('PromptString','Choose tracked objects:', 'ListString',list);
            
            nChoices = numel(indx);
            for k = 1:nChoices
                allChoices{k} = list{indx(k)};
            end
            
            for oo = 1:nChoices
                
                for j = 1:4
                    
                    switch j
                        case 1 %BL
                            coords = obj.COORDS.BL_P;
                            varNames = obj.COORDS.BL_P_varNames;
                            
                            expText = 'BL-Pain';
                            
                        case 2 %postPain
                            
                            coords = obj.COORDS.pP;
                            varNames = obj.COORDS.pP_varNames;
                            
                            expText = 'postPain';
                            
                        case 3 %postTouch
                            coords = obj.COORDS.BL_T;
                            varNames = obj.COORDS.BL_T_varNames;
                            
                            expText = 'BL-Touch';
                            
                            
                        case 4 %postTouch
                            coords = obj.COORDS.pT;
                            varNames = obj.COORDS.pT_varNames;
                            
                            expText = 'postTouch';
                            
                    end
                    
                    plotPath = obj.PATH.Plots;
                    
                    vidHeight = 1080;
                    vidWidth = 1920;
                    
                    cols = {[0, 0.4470, 0.7410], [0.8500, 0.3250, 0.0980], [0.9290, 0.6940, 0.1250], [0.4940, 0.1840, 0.5560]...
                        [0.4660, 0.6740, 0.1880],  [0, 0.75, 0.75], [0.6350, 0.0780, 0.1840], [0.25, 0.25, 0.25], [0.360000 0.540000 0.660000]...
                        [0.890000 0.150000 0.210000], [0.600000 0.400000 0.800000], [1.000000 0.800000 0.640000], [0.840000 0.040000 0.330000]};
                    
                    %% Iterate over Choices
                    
                    
                    timeRes_s = 1/fps;
                    
                    thisTrackedObject = allChoices{oo};
                    
                    eval(['coords_X = coords.' thisTrackedObject '.x;']);
                    eval(['coords_Y = coords.' thisTrackedObject '.y;']);
                    eval(['likelihood = coords.' thisTrackedObject '.likelihood;']);
                    
                    hold on
                    % liklihood
                    HL_inds = find(likelihood >= likelihood_cutoff);
                    n_inds = numel(HL_inds);
                    
                    c_X = coords_X(HL_inds);
                    c_Y = coords_Y(HL_inds);
                    
                    euclideanDistance = [];
                    for k = 1:numel(c_X)-1
                        point_xy_t0 = [c_X(k), c_Y(k)];
                        point_xy_t1 = [c_X(k+1), c_Y(k+1)];
                        distance = [point_xy_t0; point_xy_t1];
                        euclideanDistance(k) = pdist(distance,'euclidean');
                        
                    end
                    
                    AllMvmtsThisObject{j} = euclideanDistance;
                    allExpLabs{j} = expText;
                end
                
                figH = figure(300);clf
                
                distance_BL_Pain = AllMvmtsThisObject{1}';
                distance_Pain = AllMvmtsThisObject{2}';
                
                x = [distance_BL_Pain; distance_Pain;];
                g = [zeros(length(distance_BL_Pain), 1); ones(length(distance_Pain), 1)];
                subplot(2, 3, [1 4])
                boxplot(x, g, 'color', [0.5 0.5 0.5], 'symbol', '.', 'whisker', 0, 'jitter', 0.75, 'Labels',{'BL-Touch','Touch'})
                hold on
                boxplot(x, g, 'color', 'k', 'whisker', inf, 'Labels',{'BL-Pain','Pain'})
                
                yss = ylim;
                
                ylabel(['Distance moved for ' thisTrackedObject ' (px)'])
                title([obj.PATH.ExperimentName ' | ' thisTrackedObject])
                distance_BL_Touch = AllMvmtsThisObject{3}';
                distance_Touch = AllMvmtsThisObject{4}';
                
                x = [distance_BL_Touch; distance_Touch;];
                g = [zeros(length(distance_BL_Touch), 1); ones(length(distance_Touch), 1)];
                subplot(2, 3, [2 5])
                
                boxplot(x, g, 'color', [0.5 0.5 0.5], 'symbol', '.', 'whisker', 0, 'jitter', 0.75, 'Labels',{'BL-Touch','Touch'})
                hold on
                boxplot(x, g, 'color', 'k', 'whisker', inf, 'Labels',{'BL-Touch','Touch'})
                
                title([obj.PATH.ExperimentName ' | ' thisTrackedObject ' | Likelihood  Cutoff: ' num2str(likelihood_cutoff)])
                
                ylim(yss)
                
                
                %%
                [p1, h1] = ranksum(distance_BL_Pain, distance_Pain);
                [p2, h2] = ranksum(distance_BL_Touch, distance_Touch);
                
                Name = {'BL v Pain';'BL v Touch'};
                h = [h1;h2];
                p = [p1;p2];
                T = table(h,p,'RowNames',Name);
                
                ha = subplot(2, 3, 3);
                pos = get(ha,'Position');
                un = get(ha,'Units');
                delete(ha)
                
                ht = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
                    'RowName',T.Properties.RowNames,'Units', un, 'Position',pos);
                ha = subplot(2, 3, 3);
                title(['Wilcoxon Ranksum statistics'])
                axis off
                
                
                %%
                median_BL_P = nanmedian(distance_BL_Pain);
                std_BL_P = nanstd(distance_BL_Pain);
                
                median_P = nanmedian(distance_Pain);
                std_P = nanstd(distance_Pain);
                
                median_BL_T = nanmedian(distance_BL_Touch);
                std_BL_T = nanstd(distance_BL_Touch);
                
                median_T = nanmedian(distance_Touch);
                std_T = nanstd(distance_Touch);
                
                
                medians = [median_BL_P; median_P; median_BL_T; median_T];
                stds = [std_BL_P; std_P; std_BL_T; std_T];
                
                Name = {'BL-Pain';'Pain'; 'BL-Touch';'Touch'};
                
                T = table(medians,stds,'RowNames',Name);
                
                ha = subplot(2, 3, 6);
                pos = get(ha,'Position');
                un = get(ha,'Units');
                delete(ha)
                
                ht = uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
                    'RowName',T.Properties.RowNames,'Units', un, 'Position',pos);
                ha = subplot(2, 3, 6);
                title(['Medians and Stds'])
                axis off
                
                
                plotpos = [0 0 40 12]; % keep this so arena dims look ok
                
                saveName = [savePath 'MvmtBoxplot_' thisTrackedObject ];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
                
                
                for k = 1:4
                    
                    DistanceMoved_px = AllMvmtsThisObject{k}';
                    tt = table(DistanceMoved_px);
                    
                    saveName = [savePath 'Movement_' thisTrackedObject '_' allExpLabs{k}];
                    writetable(tt, [saveName '.xls'])
                    
                end
                
                
                
            end
        end
        
        
        
        function obj = makePlotsForDistances(obj, vel_or_dist)
            if isfile(obj.PATH.EuclideanMat)
                load(obj.PATH.EuclideanMat);
            else
                disp('Please run "plotVelocity" analysis')
                return
            end
            
            switch vel_or_dist
                case 1
                    BL_vels = allVelsOverExps{1,1};
                    pP_vels = allVelsOverExps{1,2};
                    pT_vels = allVelsOverExps{1,3};
                    lab = 'Velocity (px/s)';
                    savetxt = 'Velocity';
                case 2
                    BL_vels = allEucDistOverExps{1,1};
                    pP_vels = allEucDistOverExps{1,2};
                    pT_vels = allEucDistOverExps{1,3};
                    lab = 'Distance (px)';
                    savetxt = 'Distance';
                    
            end
            
            nChoices = numel(allChoices);
            p = numSubplots(nChoices);
            
            %% Boxplots
            figure(103); clf
            for k = 1:nChoices
                
                BL_val = BL_vels{1,k};
                pP_val = pP_vels{1,k};
                pT_val = pT_vels{1,k};
                
                [p1,h] = ranksum(BL_val, pP_val);
                [p2,h] = ranksum(BL_val, pT_val);
                
                subplot(p(1),p(2),k)
                
                x = [BL_val pP_val pT_val];
                g = [zeros(length(BL_val), 1); ones(length(pP_val), 1); 2*ones(length(pT_val), 1)];
                %boxplot(x, g, 'plotstyle', 'compact', 'Labels',{'BL','postPain', 'postTouch'}, 'color', 'k' , 'whisker', 50)
                boxplot(x, g, 'Labels',{'BL','postPain', 'postTouch'}, 'color', 'k' , 'whisker', 50)
                yss = ylim;
                text(0.8, yss(2)*0.9, ['BL vs pP: p = ' num2str(p1)]);
                text(0.8, yss(2)*0.8, ['BL vs pT: p = ' num2str(p2)]);
                ylabel(lab)
                title(allChoices{k})
                
            end
            
            plotpos = [0 0 30 15]; % keep this so arena dims look ok
            
            saveName = [obj.PATH.Plots 'Boxplot-' savetxt];
            print_in_A4(0, saveName, '-djpeg', 0, plotpos);
            
            
            %% heatmap
            
            clims = [-2 15];
            
            fps = 50;
            smoothWin_s = 1;
            smoothWin_frames = smoothWin_s*fps;
            
            for k = 1:nChoices
                
                thisBLVal = BL_vels{k};
                
                [Z_BL,mean_BL,std_BL]= zscore(thisBLVal);
                
                thispPVal = pP_vels{k};
                thispTVal = pT_vels{k};
                
                zscore_pP = (thispPVal - mean_BL) ./ std_BL;
                zscore_pT = (thispTVal - mean_BL) ./ std_BL;
                
                minVal = min([Z_BL zscore_pP zscore_pT]);
                maxVal = max([Z_BL zscore_pP zscore_pT]);
                
                %clims = [floor(minVal) ceil(maxVal)];
                
                figure(100+k); clf
                subplot(3, 1, 1)
                %imagesc(Z_BL, clims)
                imagesc(smooth(Z_BL, smoothWin_frames)', clims)
                xticks = get(gca, 'xtick');
                xticlabs = xticks/fps;
                for j = 1:numel(xticlabs)
                    xtickLabs{j} = num2str(xticlabs(j));
                end
                set(gca, 'xticklabel',xtickLabs)
                set(gca,'YTickLabel',[]);
                colorbar
                title([allChoices{k} ': Baseline'])
                
                subplot(3, 1, 2)
                %imagesc(zscore_pP, clims)
                imagesc(smooth(zscore_pP, smoothWin_frames)', clims)
                xticks = get(gca, 'xtick');
                xticlabs = xticks/fps;
                for j = 1:numel(xticlabs)
                    xtickLabs{j} = num2str(xticlabs(j));
                end
                set(gca, 'xticklabel',xtickLabs)
                set(gca,'YTickLabel',[]);
                colorbar
                title([allChoices{k} ': postPain'])
                
                subplot(3, 1, 3)
                %imagesc(zscore_pT, clims)
                imagesc(smooth(zscore_pT,smoothWin_frames)', clims)
                xticks = get(gca, 'xtick');
                xticlabs = xticks/fps;
                for j = 1:numel(xticlabs)
                    xtickLabs{j} = num2str(xticlabs(j));
                end
                set(gca, 'xticklabel',xtickLabs)
                set(gca,'YTickLabel',[]);
                colorbar
                title([allChoices{k} ': postTouch'])
                xlabel('Time (s)')
                
                plotpos = [0 0 15 12]; % keep this so arena dims look ok
                
                saveName = [obj.PATH.Plots 'Heatmap-' allChoices{k} '_' savetxt];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
            end
            %% Z scores
            for k = 1:nChoices
                
                thisBLVal = BL_vels{k};
                [Z_BL,mean_BL,std_BL]= zscore(thisBLVal);
                
                thispPVal = pP_vels{k};
                thispTVal = pT_vels{k};
                
                zscore_pP = (thispPVal - mean_BL) ./ std_BL;
                zscore_pT = (thispTVal - mean_BL) ./ std_BL;
                
                figure(100+k); clf
                
                subplot(3, 1, 1)
                timepoints_frames = 1:1:numel(Z_BL);
                timepoints_s = timepoints_frames/fps;
                plot(timepoints_s, smooth(Z_BL, smoothWin_frames))
                axis tight
                title([allChoices{k} ': Baseline'])
                ylabel('Z-score')
                
                subplot(3, 1, 2)
                timepoints_frames = 1:1:numel(zscore_pP);
                timepoints_s = timepoints_frames/fps;
                plot(timepoints_s, smooth(zscore_pP, smoothWin_frames))
                title([allChoices{k} ': postPain'])
                ylabel('Z-score')
                axis tight
                
                subplot(3, 1, 3)
                timepoints_frames = 1:1:numel(zscore_pT);
                timepoints_s = timepoints_frames/fps;
                plot(timepoints_s, smooth(zscore_pT,smoothWin_frames))
                axis tight
                xlabel('Time (s)')
                ylabel('Z-score')
                title([allChoices{k} ': postTouch'])
                
                
                plotpos = [0 0 15 12]; % keep this so arena dims look ok
                
                saveName = [obj.PATH.Plots 'Zscores-' allChoices{k} '_' savetxt];
                print_in_A4(0, saveName, '-djpeg', 0, plotpos);
                
            end
            
            
        end
        
        
        function obj = makePlotsMeanWindowAnalysis(obj, vel_or_dist)
            
            
            if isfile(obj.PATH.EuclideanMat)
                load(obj.PATH.EuclideanMat);
            else
                disp('Please run "plotVelocity" analysis')
                return
            end
            
            switch vel_or_dist
                case 1
                    BL_vels = allVelsOverExps{1,1};
                    pP_vels = allVelsOverExps{1,2};
                    pT_vels = allVelsOverExps{1,3};
                    lab = 'Velocity (px/s)';
                    savetxt = 'Velocity';
                    
                case 2
                    BL_vels = allEucDistOverExps{1,1};
                    pP_vels = allEucDistOverExps{1,2};
                    pT_vels = allEucDistOverExps{1,3};
                    lab = 'Distance (px)';
                    savetxt = 'Distance';
                    
            end
            
            nChoices = numel(allChoices);
            p = numSubplots(nChoices);
            
            %% Boxplots
            figure(103); clf
            
            fps = 50;
            
            timeWindow_roi_s = [10 120];
            timeWindow_roi_frames = timeWindow_roi_s*fps;
            win_s = 5;
            win_frames = win_s*fps;
            for k = 1:nChoices
                
                BL_val = BL_vels{1,k}(timeWindow_roi_frames(1): timeWindow_roi_frames(2)-1);
                pP_val = pP_vels{1,k}(timeWindow_roi_frames(1): timeWindow_roi_frames(2)-1);
                pT_val = pT_vels{1,k}(timeWindow_roi_frames(1): timeWindow_roi_frames(2)-1);
                
                BL_buff = buffer(BL_val, win_frames);
                pP_buff = buffer(pP_val, win_frames);
                pT_buff = buffer(pT_val, win_frames);
                
                BL_means = mean(BL_buff, 1);
                pP_means = mean(pP_buff, 1);
                pT_means = mean(pT_buff, 1);
                
                allBL_buffs{k} =BL_buff;
                allpP_buffs{k} =pP_buff;
                allpT_buffs{k} =pT_buff;
                %[h, pp] = lillietest(BL_means );
                
                [p1,h] = ranksum(BL_means, pP_means);
                [p2,h] = ranksum(BL_means, pT_means);
                
                %                 [h, p1] = ttest(BL_means, pP_means);
                %                 [h, p2] = ttest(BL_means, pT_means);
                
                subplot(p(1),p(2),k)
                
                toPlot = [BL_means ; pP_means ;pT_means];
                boxplot(toPlot', 'Labels',{'BL','postPain', 'postTouch'}, 'color', 'k' , 'whisker', 50)
                
                yss = ylim;
                text(0.8, yss(2)*0.9, ['BL vs pP: p = ' num2str(p1)]);
                text(0.8, yss(2)*0.8, ['BL vs pT: p = ' num2str(p2)]);
                ylabel(lab)
                title(allChoices{k})
                
            end
            
            plotpos = [0 0 35 15]; % keep this so arena dims look ok
            
            saveName = [obj.PATH.Plots 'BoxplotMeans-' savetxt];
            print_in_A4(0, saveName, '-djpeg', 0, plotpos);
            
            clims = [0 0.5];
            
            for k = 1:nChoices
                
                
                BL_buff = mean(allBL_buffs{k}, 1);
                pP_buff = mean(allpP_buffs{k}, 1);
                pT_buff = mean(allpT_buffs{k}, 1);
                
                toPlot = [BL_buff; pP_buff; pT_buff];
                
                subplot(p(1),p(2),k)
                
                imagesc(toPlot)
                %imagesc(toPlot, clims)
                colorbar
                title(allChoices{k})
                
                xticks = 1:5:22;
                
                xticlabs = {'15', '40', '65', '90', '115'};
                set(gca, 'xtick', xticks)
                set(gca, 'xticklabels', xticlabs)
                set(gca,'YTickLabel',[]);
                xlabel('Time (s)')
            end
            
            plotpos = [0 0 35 15]; % keep this so arena dims look ok
            
            saveName = [obj.PATH.Plots 'HeatmapMeans-' savetxt];
            print_in_A4(0, saveName, '-djpeg', 0, plotpos);
            
        end
        
        
    end
    
    %%
    
    methods (Hidden)
        %class constructor
        function obj = dlcAnalysis_OBJ_embryo(analysisDir, ExperimentName)
            
            %addpath(genpath(analysisDir, ExperimentName))
            
            obj = definePaths(obj, analysisDir, ExperimentName);
            
            
        end
    end
    
end



