%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'fsaverage';
fs_funcdir(funcPath, 'faceword*_fs');
cd(funcPath);

% session list for E2
sessid = 'sessid_E2';
sessListE2 = fs_sesslist(sessid);

outPath = fullfile('~', 'Desktop', 'FaceWord_E2');
fs_mkdir(outPath);

%% First level analysis
TR = 2;
runFn = 'run_Main.txt';
nCond = 8;
refDura = 16;

% make analysis for E2 
[anaListE2, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 5, 'hemis', {'lh', 'rh'}, 'anaextra', 'E2', 'stc', 'even', 'nskip', 4, 'runcmd',0);
% anaListE2 = {'main_sm5_E2_fsaverage.lh', 'main_sm5_E2_fsaverage.rh'};

% make contrast for E2
classPairsE2 = {'English_intact', 'Chinese_intact';
    'English_intact', 'English_exchange';
    'Chinese_intact', 'Chinese_exchange';
    'English_top', 'English_bottom';
    'Chinese_top', 'Chinese_bottom';
    'English','Chinese'};
condE2 = fs_par2cond(sessListE2, runFn, 'main.par', funcPath);
method = 1;
[conStruct, fscmd_con] = fs_mkcontrast(anaListE2, classPairsE2, condE2, method, 0);

% run first level analysis
fscmd_avg = fs_selxavg3(sessid, anaListE2, 0, 0, 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E2_group_1st.txt'), ...
    vertcat(fscmd_ana(:, 1), fscmd_con(:, 1), fscmd_avg(:, 1)));


%% Group-level anlaysis
% concatenate all participants' first-level results
conListE2 = fs_ana2con(anaListE2);
[conStruct, fscmd_isc] = fs_isxconcat(sessid, anaListE2, conListE2, 'group_E2', 0);

% group-level glm
[glmdir, fscmd_glm] = fs_glmfit_osgm(conStruct, '', '', 0);

% correct for multiple comparisons
fscmd_perm3 = fs_glmfit_perm(glmdir, 'ncores', 10, 'nsim', 10000, 'runcmd', 0);
fscmd_perm2 = fs_glmfit_perm(glmdir, 'ncores', 10, 'nsim', 10000, 'vwthreshold', 2);
fscmd_perm13 = fs_glmfit_perm(glmdir, 'ncores', 10, 'nsim', 10000, 'vwthreshold', 1.3);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E2_group_2nd.txt'), ...
    vertcat(fscmd_isc(:,1), fscmd_glm(:,1), fscmd_perm3(:,1)));

% print group-level results
conList_main = fs_ana2con(anaListE2);
sigPath = {'group_E2', anaListE2, conList_main, 'glm-group', 'osgm'};
fs_cvn_print2nd(sigPath, 'perm.th30.abs.sig.cluster.nii.gz', ...
    fullfile(outPath, 'main_sm5_fsaverage_E2_th30'));
fs_cvn_print2nd(sigPath, 'perm.th20.abs.sig.cluster.nii.gz', ...
    fullfile(outPath, 'main_sm5_fsaverage_E2_th20'));
fs_cvn_print2nd(sigPath, 'perm.th13.abs.sig.cluster.nii.gz', ...
    fullfile(outPath, 'main_sm5_fsaverage_E2_th13'));
fs_cvn_print2nd(sigPath, 'sig.nii.gz', fullfile(outPath, 'main_sm5_fsaverage_E2_th30_uncor'));
fs_cvn_print2nd(sigPath, 'sig.nii.gz', fullfile(outPath, 'main_sm5_fsaverage_E2_th30_uncor'), ...
    'thresh', 2);


fs_readsummary(sigPath, '', 1, outPath, 'E2_group_main_summary.csv');


%%%%% (pilot) tfce with cosmo %%%%%
% perform tfce
folder_main_tfce = 'group_E2_tfce';
tfce_main = fs_cosmo_sesstfce(sessListE2, anaListE2, conListE2, 't.nii.gz',...
    'groupfolder', 'group_E2_tfce', 'h0_mean', 0, 'nproc', 10);

% summarize the searchlight results
thmin = 1.96;
resultPath = {folder_main_tfce, anaListE2, conListE2};
dataFn = 't.nii.gz.mgz';
[slTable, fscmd] = fs_group_surfcluster(resultPath, 'sigfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('E2_main_results_tfce_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, sprintf('E2_main_results_tfce_%0.2f.txt', thmin)), fscmd(:,1));


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
hemis = {'lh', 'rh'};

% make analysis for E2 
[anaList_loc, fscmd_ana_loc] = fs_mkanalysis('loc', template, TR, runFn, nCond, refDura, ...
    'smooth', 5, 'hemis', {'lh', 'rh'}, 'anaextra', 'E2', 'stc', 'even', 'nskip', 4);
% anaList_loc = {'loc_sm5_E2_fsaverage.lh', 'loc_sm5_E2_fsaverage.rh'};

% make contrast for E2
classPairsE2_loc = {'face', 'word';
    'face', 'object';
    'face', 'scrambled';
    'word', 'object';
    'word', 'scrambled';
    'object', 'scrambled'
    };
% classPairsE2_loc = {'word', {'face', 'object', 'scrambled'}};
condE2_loc = fs_par2cond(sessListE2, runFn, 'loc.par');
[anaStruct_loc, fscmd_con_loc] = fs_mkcontrast(anaList_loc, classPairsE2_loc, condE2_loc, 1, 1);

% run first level analysis
fscmd_avg_loc = fs_selxavg3(sessid, anaList_loc, 0, 2, 1);

% save the commands used
fscmd = vertcat(fscmd_ana_loc, fscmd_con_loc, fscmd_avg_loc);
fs_createfile(fullfile(outPath, 'fscmd_E2_group_loc_1st.txt'), fscmd(:, 1));


%% Group-level anlaysis
% concatenate all participants' first-level results
[anaStruct_loc, fscmd_isc_loc] = fs_isxconcat(sessid, anaStruct_loc, '', 'group_E2');

% group-level glm
[glmdir_loc, fscmd_glm_loc] = fs_glmfit_osgm(anaStruct_loc, '', '');

% correct for multiple comparisons
fscmd_perm_loc = fs_glmfit_perm(glmdir_loc, 'ncores', 10, 'nsim', 10000, 'runcmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E2_group_loc_2nd.txt'), ...
    vertcat(fscmd_isc_loc(:,1), fscmd_glm_loc(:,1), fscmd_perm_loc(:,1)));

% print group-level results
conList_loc = fs_ana2con(anaList_loc);
sigPath = {'group_E2', anaList_loc, conList_loc, 'glm-group', 'osgm'};
fs_cvn_print2nd(sigPath, 'perm.th30.abs.sig.cluster.nii.gz', ...
    fullfile(outPath, 'loc_sm5_fsaverage_E2'), 'viewpt', -1);

fs_cvn_print2nd(sigPath, 'sig.nii.gz', ...
    fullfile(outPath, 'loc_sm5_fsaverage_E2_th30_uncor'), 'viewpt', -1);

fs_readsummary(sigPath, '', 1, outPath, 'E2_group_loc_summary.csv');



