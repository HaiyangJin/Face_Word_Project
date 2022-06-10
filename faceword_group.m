%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'fsaverage';
fs_funcdir(funcPath, 'faceword*_fs');

% session list for E1 and E2
sessListE1 = fs_sesslist('sessid_20Ss');
sessListE2 = fs_sesslist('sessid_E2');

outputPath = fullfile('~', 'Desktop', 'FaceWord');
if ~exist(outputPath, 'dir'); mkdir(outputPath); end


%% First level analysis
nCond = 8;
runFilename = 'run_Main.txt';
refDura = 16;
hemis = {'lh', 'rh'};
smooth = 5;
nSkip = 0;
TR = 2;

% make analysis for E1 
% anaListE1 = fs_mkanalysis('main', template, nCond, runFilename, refDura, ...
%     TR, hemis, smooth, nSkip, 'E1');
anaListE1 = {'main_sm5_E1_fsaverage.lh', 'main_sm5_E1_fsaverage.rh'};
% make analysis for E2 
% anaListE2 = fs_mkanalysis('main', template, nCond, runFilename, refDura, ...
%     TR, hemis, smooth, nSkip, 'E2');
anaListE2 = {'main_sm5_E2_fsaverage.lh', 'main_sm5_E2_fsaverage.rh'};

% make contrast for E1
classPairsE1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    };
condE1 = {
    'face_intact';
    'face_exchange';
    'face_top';
    'face_bottom';
    'word_intact';
    'word_exchange';
    'word_top';
    'word_bottom'};
contraE1 = fs_mkcontrast(anaListE1, classPairsE1, condE1, 1);

% make contrast for E2
classPairsE2 = {'Chinese_intact', 'English_intact';
    'Chinese_intact', 'Chinese_exchange';
    'English_intact', 'English_exchange';
    'Chinese_top', 'Chinese_bottom';
    'English_top', 'English_bottom'};
condE2 = {
    'Chinese_intact';
    'Chinese_exchange';
    'Chinese_top';
    'Chinese_bottom';
    'English_intact';
    'English_exchange';
    'English_top';
    'English_bottom'};
contraE2 = fs_mkcontrast(anaListE2, classPairsE2, condE2, 1);

% run first level analysis
fs_selxavg3('sessid_20Ss', anaListE1);
fs_selxavg3('sessid_E2', anaListE2);


%% Group level analysis
% gather results
