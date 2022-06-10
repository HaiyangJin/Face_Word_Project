%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'fsaverage';
fs_funcdir(funcPath, 'faceword*_fs');
cd(funcPath);

% session list for E1 and E2
sessid = 'sessid_20Ss';
sessListE1 = fs_sesslist(sessid);

outPath = fullfile('~', 'Desktop', 'FaceWord');
fs_mkdir(outPath);

%% First level analysis
TR = 2;
runFn = 'run_Main.txt';
nCond = 8;
refDura = 16;

% make analysis for E1 
[anaListE1, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 5, 'hemis', {'lh', 'rh'}, 'anaextra', 'E1', 'stc', 'even', 'nskip', 4, 'runcmd', 0);

% make contrast for E1
classPairsE1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    'face', 'word'};  % all faces vs. all words
condE1 = fs_par2cond(sessListE1, runFn, 'main.par', funcPath);
method = 1;  % startsWith  
[conStruct, fscmd_con] = fs_mkcontrast(anaListE1, classPairsE1, condE1, method, 0);

% run first level analysis
fscmd_avg = fs_selxavg3(sessid, anaListE1, 0, 0, 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_group_1st.txt'), ...
    vertcat(fscmd_ana(:, 1), fscmd_con(:,1), fscmd_avg(:, 1)));

%% Group-level anlaysis
% concatenate all participants' first-level results
% anaListE1 = {'main_sm5_E1_fsaverage.lh', 'main_sm5_E1_fsaverage.rh'};
conListE1 = fs_ana2con(anaListE1);
[conStruct, fscmd_isc] = fs_isxconcat(sessid, anaListE1, conListE1, 'group_E1', 0);

% group-level glm
[glmdir, fscmd_glm] = fs_glmfit_osgm(conStruct, '', '', 0);

% correct for multiple comparisons
fscmd_perm3 = fs_glmfit_perm(glmdir, 'ncores', 10, 'nsim', 10000, 'runcmd', 0);
fscmd_perm2 = fs_glmfit_perm(glmdir, 'ncores', 10, 'nsim', 10000, 'vwthreshold', 2);
fscmd_perm13 = fs_glmfit_perm(glmdir, 'ncores', 10, 'nsim', 10000, 'vwthreshold', 1.3);


% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_group_2nd.txt'), ...
    vertcat(fscmd_isc(:,1), fscmd_glm(:,1), fscmd_perm3(:,1)));

% print group-level results
sigPath = {'group_E1', anaListE1, conListE1, 'glm-group', 'osgm'};
fs_cvn_print2nd(sigPath, 'perm.th30.abs.sig.cluster.nii.gz',...
    fullfile(outPath, 'main_sm5_fsaverage_E1_th30'));
fs_cvn_print2nd(sigPath, 'perm.th20.abs.sig.cluster.nii.gz',outPath);
fs_cvn_print2nd(sigPath, 'perm.th13.abs.sig.cluster.nii.gz',outPath);
% print uncorrected results
fs_cvn_print2nd(sigPath, 'sig.nii.gz',...
    fullfile(outPath, 'main_sm5_fsaverage_E1_th30'));
fs_cvn_print2nd(sigPath, 'sig.nii.gz', ...
    fullfile(outPath, 'main_sm5_fsaverage_E1_th30'), ...
    'thresh', 2);

fs_readsummary(sigPath, '', 1, outPath, 'E1_group_main_summary.csv');

%%%% th20
fs_createfile(fullfile(outPath, 'fscmd_E1_group_2nd_th20.txt'), fscmd_perm2(:,1));
fs_cvn_print2nd(sigPath, 'perm.th20.abs.sig.cluster.nii.gz',...
    fullfile(outPath, 'main_sm5_fsaverage_E1_th20'));


%%%%% (pilot) tfce with cosmo %%%%%
% perform tfce
folder_main_tfce = 'group_E1_tfce';
tfce_main = fs_cosmo_sesstfce(sessListE1, anaListE1, conListE1, 't.nii.gz',...
    'groupfolder', 'group_E1_tfce', 'h0_mean', 0, 'nproc', 10);

% summarize the searchlight results
thmin = 1.96;
resultPath = {folder_main_tfce, anaListE1, conListE1};
dataFn = 't.nii.gz.mgz';
[slTable, fscmd] = fs_group_surfcluster(resultPath, 'sigfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('E1_main_results_tfce_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, sprintf('E1_main_results_tfce_%0.2f.txt', thmin)), fscmd(:,1));


% save tfce results

fs_cvn_print2nd(resultPath, 't.nii.gz.mgz', outPath, 'viewpt', -2, 'thresh', 1.96i);

% save tfce results
% fs_cvn_print2nd(resultPath, 't.nii.gz.mgz', outPath, 'viewpt', -2, 'thresh', 1i);


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Test for loc runs %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% First level analysis

TR = 2;
runFn = 'run_loc.txt';
nCond = 4;
refDura = 14;

% make analysis for E1 
[anaList_loc, fscmd_ana_loc] = fs_mkanalysis('loc', template, TR, runFn, nCond, refDura, ...
    'smooth', 5, 'hemis', {'lh', 'rh'}, 'anaextra', 'E1', 'stc', 'even', 'nskip', 4, 'runcmd', 0);
% anaList_loc = {'loc_sm5_E1_fsaverage.lh', 'loc_sm5_E1_fsaverage.rh'};

% make contrast for E1
classPairsE1_loc = {'face', 'word';
    'face', 'object';
    'face', 'scrambled';
    'word', 'object';
    'word', 'scrambled';
    'object', 'scrambled'
    };
% classPairsE1_loc = {'word', {'face', 'object', 'scrambled'}};
condE1_loc = fs_par2cond(sessListE1, runFn, 'loc.par');
[anaStruct_loc, fscmd_con_loc] = fs_mkcontrast(anaList_loc, classPairsE1_loc, condE1_loc, 1, 1);

% run first level analysis
fscmd_avg_loc = fs_selxavg3(sessid, anaList_loc, 0, 1, 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_group_loc_1st.txt'), ...
    vertcat(fscmd_ana_loc(:,1), fscmd_con_loc(:,1), fscmd_avg_loc(:,1)));


%% Group-level anlaysis
% concatenate all participants' first-level results
[anaStruct_loc, fscmd_isc_loc] = fs_isxconcat(sessid, anaStruct_loc, '', 'group_E1', 1);

% group-level glm
[glmdir_loc, fscmd_glm_loc] = fs_glmfit_osgm(anaStruct_loc, '', '', 1);

% correct for multiple comparisons
fscmd_perm_loc = fs_glmfit_perm(glmdir_loc, 'ncores', 8, 'nsim', 10000, 'runcmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_group_loc_2nd.txt'), ...
    vertcat(fscmd_isc_loc(:,1), fscmd_glm_loc(:,1), fscmd_perm_loc(:,1)));

% print group-level results
conList_loc = fs_ana2con(anaList_loc);
sigPath = {'group_E1', anaList_loc, conList_loc, 'glm-group', 'osgm'};
fs_cvn_print2nd(sigPath, 'perm.th30.abs.sig.cluster.nii.gz', ...
    fullfile(outPath, 'loc_sm5_fsaverage_E1_th30'));

fs_cvn_print2nd(sigPath, 'sig.nii.gz', ...
    fullfile(outPath, 'loc_sm5_fsaverage_E1_th30_uncor'));

fs_readsummary(sigPath, '', 1, outPath, 'E1_group_loc_summary.csv');


%%%%% (pilot) tfce with cosmo %%%%%
% perform tfce
tfce_cell = fs_cosmo_sesstfce(sessListE1, anaList_loc, conList_loc, 't.nii.gz',...
    'groupfolder', 'group_E1_tst', 'h0_mean', 0);

% save tfce results
resultPath = {'group_E1_tst', anaList_loc, conList_loc};
fs_cvn_print2nd(resultPath, 't.nii.gz.mgz', outPath, 'viewpt', -2, 'thresh', 2i);

% save tfce results
resultPath = {'group_E1_tst', anaList_loc, conList_loc};
fs_cvn_print2nd(resultPath, 't.nii.gz.mgz', outPath, 'viewpt', -2, 'thresh', 1i);


