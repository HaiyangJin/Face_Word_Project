% set subject path
subjPath = fullfile(filesep, 'Volumes', 'Atlantic', 'research', 'fMRI', 'faceword',...
    'freesurfer', 'subjects');

subjDir = dir(fullfile(subjPath, 'faceword*'));
nSubj = length(subjDir);

roiStruct = struct([]);
roiStructlong = struct([]);
n = 0;

% get info for each subject
for iSubj = 1:nSubj
    
    thisSubj = subjDir(iSubj).name;
    
    thisLabelPath = fullfile(subjPath, thisSubj, 'label');
    
    
    roiDir = dir(fullfile(thisLabelPath, 'roi.*-vs-o*.label')); % roi*label roi.*-vs-o.label   
    
    nRoi = length(roiDir);
    
    roiStruct(iSubj).SubjCode = thisSubj;
    
    
    for iRoi = 1:nRoi
        
        thisRoi = roiDir(iRoi).name;
        
        dataStruct = importdata(fullfile(thisLabelPath, thisRoi), ' ', 2);
        
        nVertice = str2double(dataStruct.textdata{2});
        
        
        tempRoi = strrep(thisRoi, '.', '0');
        tempRoi = strrep(tempRoi, '-', 'T');
        
        roiStruct(iSubj).(tempRoi) = nVertice;
        
        n = n + 1;
        roiStructlong(n).SubjCode = thisSubj;
        roiStructlong(n).label = thisRoi;
        roiStructlong(n).nVertice = nVertice;
        
        roiInfo = strsplit(thisRoi, '.');
        roiStructlong(n).hemi = roiInfo{2};
        roiStructlong(n).sig = roiInfo{3};
        roiStructlong(n).Contrast = roiInfo{4};
        
        if length(roiInfo) > 5
            roiStructlong(n).ffa = roiInfo{5};
        end
    end
end

roiTable = struct2table(roiStruct);

roiVarNames = cellfun(@(x) strrep(x, '0', '.'), roiTable.Properties.VariableNames, ...
    'UniformOutput', false);
roiVarNames = cellfun(@(x) strrep(x, 'T', '-'), roiVarNames, 'UniformOutput', false);

roiSumTable = [cell2table(roiVarNames, 'VariableNames', roiTable.Properties.VariableNames); roiTable];

% wide table
writetable(roiSumTable, fullfile('~', 'Desktop', 'ROI_Summary_wide.xlsx'), 'WriteVariableNames', false);

% long table
roiSumLongTable= struct2table(roiStructlong);
writetable(roiSumLongTable, fullfile('~', 'Desktop', 'ROI_Summary_long.xlsx'));


