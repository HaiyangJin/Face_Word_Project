

boldname = 'self';
% path_output = '~/Desktop/Label_LOC';

FS = fs_setup;
subjFolder = FS.subjects;
subjBoldPath = fullfile(FS.subjects, '..', 'Data_fMRI');
subjBoldDir = dir(fullfile(subjBoldPath, ['*' boldname]));
nSubj = numel(subjBoldDir);

hemis = {'lh', 'rh'};
contrast_name = 'o-vs-scr';


%%
for iSubj = 1:nSubj
    % iSubj = 0;
    % iSubj = iSubj + 1;
    
    thisBoldSubj = subjBoldDir(iSubj).name;
    subjCode = fw_subjcode(thisBoldSubj);
    
    for iHemi = 1:numel(hemis)
        
        hemi = hemis{iHemi};
        
        file_sig = fullfile(subjBoldDir(iSubj).folder, subjBoldDir(iSubj).name, ...
            'bold', ['loc_' boldname '.' hemi], contrast_name, 'sig.nii.gz');
        
        fscmd = sprintf('tksurfer %s %s inflated -aparc -overlay %s',...
            subjCode, hemi, file_sig);
        
        % created an empty file with the label filename
        fn_label = sprintf('roi.%s.f13.%s.label', hemi, contrast_name);
        file_label = fullfile(subjFolder, subjCode, 'label', fn_label);
%         if ~exist(file_label, 'file')
%             system(['touch ' file_label]);
%         end
        
        system(fscmd);
        
        % rename and move this label file
        tmp_fn_label = 'label.label';
        file_tmp_label = fullfile(subjFolder, subjCode, tmp_fn_label);
        
        if exist(file_tmp_label, 'file')
            movefile(file_tmp_label, file_label);
        end
        
    end
    
    
end


