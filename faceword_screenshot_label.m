
boldname = 'self';
path_output = '~/Desktop/Label_Screenshots';

labelNames = { % 'roi.rh.f20.f-vs-o.label', ...
    'roi.lh.f13.f-vs-o.ffa1.label', ...
    'roi.lh.f20.f-vs-o.ffa1.label', ...
    'roi.lh.f13.f-vs-o.ffa2.label',...
    'roi.lh.f13.w-vs-o.label', ...
    'roi.lh.f20.f-vs-o.label', ...
    'roi.lh.f40.f-vs-o.label',...`
    'roi.rh.f13.f-vs-o.ffa1.label', ...
    'roi.rh.f20.f-vs-o.ffa2.label',...
    'roi.rh.f40.f-vs-o.ffa2.label', ...
    'roi.rh.f20.f-vs-o.label', ...
    'roi.rh.f40.f-vs-o.label'};
nLabels = numel(labelNames);


FS = fs_setup;
subjBoldPath = fullfile(FS.subjects, '..', 'Data_fMRI');
subjBoldDir = dir(fullfile(subjBoldPath, ['*' boldname]));
nSubj = numel(subjBoldDir);


for iLabel = 1:nLabels
    
    thisLabel = labelNames{iLabel};
    hemi = fs_hemi(thisLabel);
    
    conStrPosition = strfind(thisLabel, '-') + [-1, 1];
    contrast = thisLabel(conStrPosition(1):conStrPosition(2));
    
    for iSubj = 1:nSubj
        
        thisSubj = subjBoldDir(iSubj).name;
        subjCode = fw_subjcode(thisSubj);
        
        
        isAvailable = fw_checklabel(thisLabel, subjCode);
        if ~isAvailable
            continue
        end
        
        analysis = sprintf('loc_%s.%s', boldname, hemi);
        file_overlay = fullfile(subjBoldPath, thisSubj, 'bold', analysis, contrast, 'sig.nii.gz');
        
        if ~exist(file_overlay, 'file')
            continue
        end
            
        fs_screenshot_label(subjCode, thisLabel, path_output, file_overlay);
        
        
    end
    
end
