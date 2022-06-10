%% Information used later
fs_setup('6.0');
struPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(struPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'fsaverage';
fs_funcdir(funcPath, 'faceword*_fs');
cd(funcPath);

% session list for E1 and E2
sessid = 'sessid_20Ss';
sessListE1 = fs_sesslist('sessid_20Ss');

outPath = fullfile('~', 'Desktop', 'FaceWord_sl');
fm_makedir(outPath);

% make contrast for E1
contraPairsE1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    'face', 'word'
    };

%% First level analysis
% make analysis for E1 
TR = 2;
runFn = 'run_Main.txt';
nCond = 8;
refDura = 16;

% make analysis for E1 
[anaListE1, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 0, 'hemis', {'lh', 'rh'}, 'anaextra', 'E1', 'stc', 'even', 'nskip', 4, 'runcmd', 0);
% anaListE1 = {'main_sm0_E1_fsaverage.lh', 'main_sm0_E1_fsaverage.rh'};

% {'face_intact', 'face_exchange', 'face_top', 'face_bottom'}, ...
%     {'word_intact', 'word_exchange', 'word_top', 'word_bottom'}
condE1 = fs_par2cond(sessListE1, runFn, 'main.par', funcPath);
method = 1;
[contraE1, fscmd_con] = fs_mkcontrast(anaListE1, contraPairsE1, condE1, method, 0);

% run first level analysis
fscmd_avg = fs_selxavg3(sessid, anaListE1, 1, 0, 1);

fs_createfile(fullfile(outPath, 'fscmd_E1_sl_1st.txt'), ...
    vertcat(fscmd_ana(:,1), fscmd_con(:,1), fscmd_avg(:, 1)));

%% Searchlight
% fs_mkintermediate('fsaverage', 'lh.white', 'lh.pial');
% fs_mkintermediate('fsaverage', 'rh.white', 'rh.pial');
anaListE1 = {'main_sm0_E1_fsaverage.lh','main_sm0_E1_fsaverage.rh'};

classPairsE1 = vertcat(contraPairsE1(1:5, :), ...
    {{'face', 'word'}, {[1, 2, 3, 4], [5, 6, 7, 8]}});

% without zscoring
fs_cosmo_sesssl(sessListE1, anaListE1, classPairsE1, ...
    'runinfo', 'run_main.txt', 'surftype', 'white', ...
    'count', 150, 'nproc', 10);

% with zscoring
fs_cosmo_sesssl(sessListE1(1), anaListE1(1), classPairsE1(1, :), ...
    'runinfo', 'run_main.txt', 'surftype', 'white', ...
    'count', 150, 'nproc', 10, 'classopt', {'normalization', 'zscore'});

% tfce
slAnaList = {'sl_white_count150_main_sm0_E1_fsaverage.lh', ...
    'sl_white_count150_main_sm0_E1_fsaverage.rh'};
contraList = fs_ana2con(anaListE1);
dataFn = 'sl.libsvm.acc.mgz';
% dataFn = 'sl.libsvm.zscore.acc.mgz';
tfce_cell = fs_cosmo_sesstfce(sessListE1, slAnaList, contraList, dataFn, ...
    'groupfolder', 'Group_SL_E1', 'nproc', 10);


% summarize the searchlight results
thmin = 1.65;
allpath = {'Group_SL_E1', slAnaList, contraList};
[slTable, fscmd] = fs_group_surfcluster(allpath, 'slfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('sl_E1_main_results_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, sprintf('fscmd_E1_sl_surfcluster_2nd_%0.2f.txt', thmin)), fscmd(:,1));

fs_cvn_print2nd(allpath, dataFn, outPath, ...
    'thresh', thmin);

% % with fixed radius
% fs_cosmo_sesssl(sessListE1(1), anaListE1, classPairsE1(1, :), ...
%     'runlist', 'run_main.txt', 'surftype', surfType, 'ispct', 1, 'bothhemi', 1, ...
%     'cvslopts', {'radius', 10, 'nproc', 10});


%% Searchlight (test betat)
% fs_mkintermediate('fsaverage', 'lh.white', 'lh.pial');
% fs_mkintermediate('fsaverage', 'rh.white', 'rh.pial');

classPairsE1 = vertcat(contraPairsE1(1:5, :), ...
    {{'face', 'word'}, {[1, 2, 3, 4], [5, 6, 7, 8]}});

% fs_processbeta(sessListE1, anaListE1, 'runwise', 1, 'runinfo' ,'run_main.txt');

% without zscoring
fs_cosmo_sesssl(sessListE1, anaListE1, classPairsE1, ...
    'runinfo', 'run_main.txt', 'surftype', 'white', ...
    'count', 150, 'nproc', 10, 'datafn', 'betat.mgz');

% with zscoring
fs_cosmo_sesssl(sessListE1, anaListE1, classPairsE1, ...
    'runinfo', 'run_main.txt', 'surftype', 'white', ...
    'count', 150, 'nproc', 10, 'classopt', {'normalization', 'zscore'});

% tfce
slAnaList = {'sl_white_geodesic_c150_main_sm0_E1_fsaverage.lh', ...
    'sl_white_geodesic_c150_main_sm0_E1_fsaverage.rh'};
contraList = fs_ana2con(anaListE1);
dataFn = 'sl.libsvm.acc.mgz';
% dataFn = 'sl.libsvm.zscore.acc.mgz';
tfce_cell = fs_cosmo_sesstfce(sessListE1, slAnaList, contraList, dataFn, ...
    'groupfolder', 'Group_SL_E1', 'nproc', 10);


% summarize the searchlight results
thmin = 1.65;
allpath = {'Group_SL_E1', slAnaList, contraList};
[slTable, fscmd] = fs_group_surfcluster(allpath, 'slfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('sl_E1_main_results_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fm_mkfile(fullfile(outPath, sprintf('fscmd_E1_sl_surfcluster_2nd_%0.2f.txt', thmin)), fscmd(:,1));

fs_cvn_print2nd(allpath, dataFn, outPath, ...
    'thresh', thmin);

% % with fixed radius
% fs_cosmo_sesssl(sessListE1(1), anaListE1, classPairsE1(1, :), ...
%     'runlist', 'run_main.txt', 'surftype', surfType, 'ispct', 1, 'bothhemi', 1, ...
%     'cvslopts', {'radius', 10, 'nproc', 10});


%% Pilot with fixed area size
% % maximum area 100mm2
fs_cosmo_sesssl(sessListE1, anaListE1, contraPairsE1(1:5, :), ...
    'runlist', 'run_main.txt', 'surftype', 'white', 'ispct', 1, 'areamax', 100, ...
    'cvslopts', {'radius', 10, 'nproc', 10});

% tfce
sessList = sessListE1;
slAnaList = 'sl_white_area100_main_sm0_E1_fsaverage.lh';
contraList = {...
    'face_intact-vs-face_exchange', ...
    'face_intact-vs-word_intact', ...
    'face_top-vs-face_bottom', ...
    'word_intact-vs-word_exchange', ...
    'word_top-vs-word_bottom'};
dataFn = 'sl.libsvm.lh.acc.mgz';

fs_cosmo_sesstfce(sessList, slAnaList, contraList, dataFn, ...
    'nnull', 0, 'groupfolder', 'Group_SL_E1');


%% Searchlight (try with larger count)
% fs_mkintermediate('fsaverage', 'lh.white', 'lh.pial');
% fs_mkintermediate('fsaverage', 'rh.white', 'rh.pial');

classPairsE1 = vertcat(contraPairsE1(1:5, :), ...
    {{'face', 'word'}, {[1, 2, 3, 4], [5, 6, 7, 8]}});

% without zscoring
fs_cosmo_sesssl(sessListE1, anaListE1, classPairsE1, ...
    'runlist', 'run_main.txt', 'surftype', 'white', ...
    'cvslopts', {'count', 200, 'nproc', 10});

% with zscoring
% fs_cosmo_sesssl(sessListE1(1), anaListE1(1), classPairsE1(1, :), ...
%     'runlist', 'run_main.txt', 'surftype', 'white', ...
%     'cvslopts', {'count', 150, 'nproc', 10, 'classopt', {'normalization', 'zscore'}});

% tfce
slAnaList = {'sl_white_count200_main_sm0_E1_fsaverage.lh', ...
    'sl_white_count200_main_sm0_E1_fsaverage.rh'};
contraList = fs_ana2con(anaListE1);
dataFn = 'sl.libsvm.acc.mgz';
% dataFn = 'sl.libsvm.zscore.acc.mgz';
tfce_cell = fs_cosmo_sesstfce(sessListE1, slAnaList, contraList, dataFn, ...
    'groupfolder', 'Group_SL_E1', 'nproc', 10);


% summarize the searchlight results
thmin = 1.65;
allpath = {'Group_SL_E1', slAnaList, contraList};
[slTable, fscmd] = fs_group_surfcluster(allpath, 'slfn', dataFn, 'thmin', thmin, ...
    'outfile', fullfile(outPath, sprintf('sl_E1_main_results_count200_%0.2f.csv', thmin)), 'runfscmd', 1);

% save the commands used
fs_createfile(fullfile(outPath, sprintf('fscmd_E1_sl_surfcluster_count200_2nd_%0.2f.txt', thmin)), fscmd(:,1));

fs_cvn_print2nd(allpath, dataFn, outPath, ...
    'thresh', thmin);

% % with fixed radius
% fs_cosmo_sesssl(sessListE1(1), anaListE1, classPairsE1(1, :), ...
%     'runlist', 'run_main.txt', 'surftype', surfType, 'ispct', 1, 'bothhemi', 1, ...
%     'cvslopts', {'radius', 10, 'nproc', 10});




