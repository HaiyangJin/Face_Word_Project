%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath);
% % save a new sessid file for faceword*_self
% sessSelf = fs_funcdir(funcPath, 'faceword*_self');
% fs_createfile('sessid_E1_self', sessSelf(1:21));

% session list for E1 and E2
sessid = 'sessid_E1_self';
sessListE1 = fs_sesslist(sessid);

outPath = fullfile('~', 'Desktop', 'FaceWord_uni');
if ~exist(outPath, 'dir'); mkdir(outPath); end


%% First level analysis
TR = 2;
runFn = 'run_Main.txt';
nCond = 8;
refDura = 16;

% make analysis for E1 
[anaListE1, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 5, 'hemis', {'lh', 'rh'}, 'anaextra', 'E1', 'stc', 'even', 'nskip', 4);
% anaListE1 = {'main_sm5_E1_self.lh', 'main_sm5_E1_self.rh'};

% make contrast for E1
classPairsE1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    'face', 'word'};
condE1 = fs_par2cond(sessListE1, runFn, 'main.par', funcPath);
method = 1;
[anaStruct, fscmd_con] = fs_mkcontrast(anaListE1, classPairsE1, condE1, method, 1);

% run first level analysis
fscmd_avg = fs_selxavg3(sessid, anaListE1, 0, 1, 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_uni_1st.txt'), ...
    vertcat(fscmd_ana(:, 1), fscmd_con(:, 1), fscmd_avg(:, 1)));


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% loc runs %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% First level analysis

smooth = 5;
TR = 2;
runFn = 'run_loc.txt';
nCond = 4;
refDura = 14;
hemis = {'lh', 'rh'};
stc = 'even';
nSkip = 4;


% make analysis for E1 
[anaList_loc, fscmd_ana_loc] = fs_mkanalysis('loc', template, smooth, ...
    TR, runFn, nCond, refDura, hemis, stc, nSkip, 'E1');
% anaList_loc = {'loc_sm5_E1_self.lh', 'loc_sm5_E1_self.rh'};

% make contrast for E1
classPairsE1_loc = {'face', 'word';
    'face', 'object';
    'face', 'scrambled';
    'word', 'object';
    'word', 'scrambled';
    'object', 'scrambled'
    };
condE1_loc = fs_par2cond(sessListE1, runFn, 'loc.par', funcPath);
method = 1;
[anaStruct_loc, fscmd_con_loc] = fs_mkcontrast(anaList_loc, classPairsE1_loc, condE1_loc, method, 1);

% run first level analysis
fscmd_avg_loc = fs_selxavg3(sessid, anaList_loc, 0, 1, 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_uni_loc_1st.txt'), ...
    vertcat(fscmd_ana_loc, fscmd_con_loc, fscmd_avg_loc(:,1)));

conList_loc = fs_ana2con(anaList_loc);
fs_cvn_print1st(sessListE1, anaList_loc, conList_loc, sigFn, fullfile(outPath, 'loc_E1'), extraopts, funcPath);


%% Create labels (faceword_E1_trim_labels.m)

%% Univariate analysis
% output the data for uni analysis
anaListE1 = {'main_sm5_E1_self.lh', 'main_sm5_E1_self.rh'};
labelList = {
    'roi.lh.f-vs-o.ffa1.label';
    'roi.lh.f-vs-o.ffa2.label';
    'roi.lh.word-vs-face-object-scrambled.label';
    'roi.lh.o-vs-scr.label';
    'roi.rh.f-vs-o.ffa1.label';
    'roi.rh.f-vs-o.ffa2.label';
    'roi.rh.o-vs-scr.label'
    };
uniTable = fs_cosmo_readdata(sessListE1, anaListE1, 'labellist', labelList, 'runlist', 'run_main.txt');
writetable(uniTable, fullfile(outPath, 'faceword_E1_Uni_HJ.csv'));

% following analysis is done in R.











