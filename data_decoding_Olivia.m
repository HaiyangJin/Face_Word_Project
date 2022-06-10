% output folder
out_dir_E1 = fullfile('~', 'Desktop', 'data_decoding_E1');
% mkdir(out_dir_E1);
out_dir_E2 = fullfile('~', 'Desktop', 'data_decoding_E2');
% mkdir(out_dir_E2);

%% Information used later
fs_setup('6.0');
struPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(struPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath, 'faceword*_self');

labelList = {
    'roi.lh.f-vs-o.ffa1.label';
    'roi.lh.f-vs-o.ffa2.label';
    'roi.lh.word-vs-face-object-scrambled.label';
    'roi.lh.o-vs-scr.label';
    'roi.rh.f-vs-o.ffa1.label';
    'roi.rh.f-vs-o.ffa2.label';
    'roi.rh.o-vs-scr.label'
    };

rois = {'LFFA1', 'LFFA2', 'LVWFA', 'LLO', 'RFFA1', 'RFFA2', 'RLO'};

%% E1

% session list for E1 
sessidE1 = 'sessid_E1_self';
sessListE1 = fs_sesslist(sessidE1);


for iSess = 1:numel(sessListE1)
    
    sess = sessListE1{iSess};
    
    for iLabel = 1:numel(labelList)
        
        label = labelList{iLabel};
        
        % load the data
        [ds_subj, condInfo] = fs_cosmo_subjds(sess, label, template, ...
            funcPath, 'main', 0, 1);
        
        if ~isempty(ds_subj)
            % update the format
            coords_all = fs_readsurf([fs_2hemi(label) '.white'], fs_subjcode(sess));
            coords = coords_all(ds_subj.fa.node_indices', :);
            
            roiMatrix = ds_subj.samples;
            
            other_info = table;
            other_info.run = ds_subj.sa.chunks;
            other_info.condition = ds_subj.sa.labels;
            other_info.cond_index = ds_subj.sa.targets;
            
            % filename
            tmp_fn = sprintf('%s_%s_E1_faceword.mat', sess, rois{iLabel});
            
            save(fullfile(out_dir_E1, tmp_fn), 'coords', 'roiMatrix', 'other_info');
            
        end
        
    end
    
end

%% E2

% session list for E2 
sessidE2 = 'sessid_E2_self';
sessListE2 = fs_sesslist(sessidE2);


for iSess = 1:numel(sessListE2)
    
    sess = sessListE2{iSess};
    
    for iLabel = 1:numel(labelList)
        
        label = labelList{iLabel};
        
        % load the data
        [ds_subj, condInfo] = fs_cosmo_subjds(sess, label, template, ...
            funcPath, 'main', 0, 1);
        
        if ~isempty(ds_subj)
            % update the format
            coords_all = fs_readsurf([fs_2hemi(label) '.white'], fs_subjcode(sess));
            coords = coords_all(ds_subj.fa.node_indices', :);
            
            roiMatrix = ds_subj.samples;
            
            other_info = table;
            other_info.run = ds_subj.sa.chunks;
            other_info.condition = ds_subj.sa.labels;
            other_info.cond_index = ds_subj.sa.targets;
            
            % filename
            tmp_fn = sprintf('%s_%s_E2_faceword.mat', sess, rois{iLabel});
            
            save(fullfile(out_dir_E2, tmp_fn), 'coords', 'roiMatrix', 'other_info');
            
        end
        
    end
    
end