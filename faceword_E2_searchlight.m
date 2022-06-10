%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'fsaverage';
fs_funcdir(funcPath, 'faceword*_fs');

% session list for E2
sessListE2 = fs_sesslist('sessid_E2');

outPath = fullfile('~', 'Desktop', 'FaceWord_E2_SL');
fs_mkdir(outPath);


%% fmcpr.even.nii.gz -> fmcpr.even.sm0.fsaverage.?h.nii.gz
%%%% project the unsmoothed data 

% project data for each session separately
% for iSess = 1:numel(sessListE2)
%     
%     % this session code
%     thisSess = sessListE2{iSess};
%     
%     % the bold path
%     boldPath = fullfile(funcPath, thisSess, 'bold');
%     % the list of all runs
%     runList = fs_runlist(boldPath);
%       
%     % all the combinations of hemispheres and runs
%     [hemis, runs] = ndgrid({'lh', 'rh'}, runList);
%     
%     % Project functional data for all runs
%     cellfun(@(x, y) fs_projfunc(thisSess, 'fmcpr.even', x, 'fsaverage', y, ...
%         0, funcPath), runs(:), hemis(:), 'uni', false);
%     
% end  % iSess

%% First level analysis
nCond = 8;
runFn = 'run_Main.txt';
refDura = 16;
TR = 2;

% make analysis for E2 
[anaListE2, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 0, 'hemis', {'lh', 'rh'}, 'anaextra', 'E2', 'stc', 'even', 'nskip', 4, 'runcmd', 0);
% anaListE2 = {'main_sm0_E2_fsaverage.lh', 'main_sm0_E2_fsaverage.rh'};

% make contrast for E2
contraPairsE2 = {'English_intact', 'Chinese_intact';
    'English_intact', 'English_exchange';
    'Chinese_intact', 'Chinese_exchange';
    'English_top', 'English_bottom';
    'Chinese_top', 'Chinese_bottom';
    'English','Chinese'};
condE2 = fs_par2cond(sessListE2, runFn, 'main.par', funcPath);
method = 1;
[contraE2, fscmd_con] = fs_mkcontrast(anaListE2, contraPairsE2, condE2, method, 0);

% run first level analysis
fscmd_avg = fs_selxavg3('sessid_E2', anaListE2, 1, 0, 1);

fs_createfile(fullfile(outPath, 'fscmd_E2_sl_1st.txt'), ...
    vertcat(fscmd_ana(:, 1), fscmd_con(:,1), fscmd_avg(:,1)));

%% Searchlight
classPairsE2 = vertcat(contraPairsE2(1:5, :), ...
    {{'English','Chinese'}, {[1, 2, 3, 4], [5, 6, 7, 8]}});

% without 'zscore'
fs_cosmo_sesssl(sessListE2, anaListE2, classPairsE2, ...
    'runlist', 'run_main.txt', 'surftype', 'white', ...
    'cvslopts', {'count', 150, 'nproc', 10});

% with 'zscore'
fs_cosmo_sesssl(sessListE2, anaListE2, classPairsE2, ...
    'runlist', 'run_main.txt', 'surftype', 'white', ...
    'cvslopts', {'count', 150, 'nproc', 10, 'classopt', {'normalization', 'zscore'}});


% tfce
slAnaListE2 = {'sl_white_count150_main_sm0_E2_fsaverage.lh', ...
    'sl_white_count150_main_sm0_E2_fsaverage.rh'};
contraList = fs_ana2con(anaListE2);
dataFn = 'sl.libsvm.acc.mgz';
% dataFn = 'sl.libsvm.zscore.acc.mgz';
tfce_cell = fs_cosmo_sesstfce(sessListE2, slAnaListE2, contraList, dataFn, ...
    'groupfolder', 'Group_SL_E2', 'nproc', 10);


% summarize the searchlight results
thmin = 1.65;
allpath = {'Group_SL_E2', slAnaListE2, contraList};
[slTable, fscmd] = fs_sl_surfcluster(allpath, 'slfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('sl_E2_main_results_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, sprintf('fscmd_E2_sl_surfcluster_2nd_%0.2f.txt', thmin)), fscmd(:,1));

fs_cvn_print2nd(allpath, dataFn, outPath, ...
    'thresh', thmin);

%% Searchlight (try with more vertexs; count)
% fs_mkintermediate('fsaverage', 'lh.white', 'lh.pial');
% fs_mkintermediate('fsaverage', 'rh.white', 'rh.pial');

classPairsE2 = vertcat(contraPairsE2(1:5, :), ...
    {{'face', 'word'}, {[1, 2, 3, 4], [5, 6, 7, 8]}});

% without zscoring
fs_cosmo_sesssl(sessListE2, anaListE2, classPairsE2, ...
    'runlist', 'run_main.txt', 'surftype', 'white', ...
    'cvslopts', {'count', 200, 'nproc', 10});

% with zscoring
% fs_cosmo_sesssl(sessListE2(1), anaListE2(1), classPairsE2(1, :), ...
%     'runlist', 'run_main.txt', 'surftype', 'white', ...
%     'cvslopts', {'count', 150, 'nproc', 10, 'classopt', {'normalization', 'zscore'}});

% tfce
slAnaList = {'sl_white_count200_main_sm0_E2_fsaverage.lh', ...
    'sl_white_count200_main_sm0_E2_fsaverage.rh'};
contraList = fs_ana2con(anaListE2);
dataFn = 'sl.libsvm.acc.mgz';
% dataFn = 'sl.libsvm.zscore.acc.mgz';
tfce_cell = fs_cosmo_sesstfce(sessListE2, slAnaList, contraList, dataFn, ...
    'groupfolder', 'Group_SL_E2', 'nproc', 10);


% summarize the searchlight results
thmin = 1.65;
allpath = {'Group_SL_E2', slAnaList, contraList};
[slTable, fscmd] = fs_group_surfcluster(allpath, 'slfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('sl_E2_main_results_count200_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, sprintf('fscmd_E2_sl_surfcluster_count200_2nd_%0.2f.txt', thmin)), fscmd(:,1));

fs_cvn_print2nd(allpath, dataFn, outPath, ...
    'thresh', thmin);

% % with fixed radius
% fs_cosmo_sesssl(sessListE2(1), anaListE2, classPairsE2(1, :), ...
%     'runlist', 'run_main.txt', 'surftype', surfType, 'ispct', 1, 'bothhemi', 1, ...
%     'cvslopts', {'radius', 10, 'nproc', 10});





