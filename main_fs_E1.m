%%%% Following Olivia's analysis {'main_fs.rh', 'main_fs.lh'}
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'fsaverage';
fs_funcdir(funcPath, 'faceword*_fs');

outPath = fullfile('~', 'Desktop', 'FaceWord');
if ~exist(outPath, 'dir'); mkdir(outPath); end

sessid = 'sessid_20Ss';
anaList = {'main_fs.rh', 'main_fs.lh'};
conList = {
    'Fintact-vs-Wintact';
    'Fintact-vs-exchange';
    'Ftop-vs-bottom';
    'Wintact-vs-exchange';
    'Wtop-vs-bottom';
    'f-vs-w'};

%% Group-level anlaysis
% concatenate all participants' first-level results
[anaStruct_fs, fscmd_isc_fs] = fs_isxconcat(sessid, anaList, conList, 'group_E1_fs', 0);

% group-level glm
[glmdir_fs, fscmd_glm_fs] = fs_glmfit_osgm(anaStruct_fs, '', '', 0);

% correct for multiple comparisons
fscmd_perm_fs2 = fs_glmfit_perm(glmdir_fs, 4, 10000, 2, 'abs', 0.05, 2, 2);
fscmd_perm_fs3 = fs_glmfit_perm(glmdir_fs, 4, 10000, 3, 'abs', 0.05, 2, 2);


fscmd = vertcat(fscmd_isc_fs, fscmd_glm_fs, fscmd_perm_fs2, fscmd_perm_fs3);
fs_createfile(fullfile(outPath, 'fscmd_E1_group_fs_2nd.txt'), fscmd(:, 1));


%% print the group-level results (p-values)
fs_cvn_print2nd(anaStruct_fs, 'glm-group', 'perm.th30.abs.sig.cluster.nii.gz', fullfile(outPath, 'group_fs_th30'));
fs_cvn_print2nd(anaStruct_fs, 'glm-group', 'perm.th20.abs.sig.cluster.nii.gz', fullfile(outPath, 'group_fs_th20'));

sumTable30 = fs_read2ndsum('group_E1_fs', anaList, conList, '', '', 'perm.th30.abs.sig.cluster.summary');
writetable(sumTable30, fullfile(outPath, 'summary_th30.csv'));

% print results before corrections
fs_cvn_print2nd(anaStruct_fs, 'glm-group', 'sig.nii.gz', fullfile(outPath, 'group_fs_th30_uncor'));


%% Output results done by Olivia
thisana = {'loc_fs.lh', 'loc_fs.rh'};
thiscon = {'f-vs-o', 'f-vs-w'};
paths = fs_fullfile(funcPath, 'group_20Ss', thisana, thiscon, 'group_glm.wls');

fs_cvn_print2nd('', paths, 'sig.mgh', fullfile(outPath, 'group_fs_wls'));
