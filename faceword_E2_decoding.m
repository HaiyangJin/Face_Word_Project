%% Information used later
fs_setup('6.0');
struPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(struPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath, 'faceword*_self');

% session list for E2 
sessidE2 = 'sessid_E2_self';
sessListE2 = fs_sesslist(sessidE2);

outPath = fullfile('~', 'Desktop', 'FaceWord_E2_MVPA');
if ~exist(outPath, 'dir'); mkdir(outPath); end

%% fmcpr.even.nii.gz -> fmcpr.even.sm0.fsaverage.?h.nii.gz
%%%% project the unsmoothed data 

% % project data for each session separately
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
% make analysis for E2 
TR = 2;
runFn = 'run_Main.txt';
nCond = 8;
refDura = 16;

% make analysis for E2 
[anaListE2, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 0, 'hemis', {'lh', 'rh'}, 'anaextra', 'E2', 'stc', 'even', 'nskip', 4);
% anaListE2 = {'main_sm0_E2_self.lh', 'main_sm0_E2_self.rh'};

% make contrast for E2
classPairsE2 = {'English_intact', 'Chinese_intact';
    'English_intact', 'English_exchange';
    'Chinese_intact', 'Chinese_exchange';
    'English_top', 'English_bottom';
    'Chinese_top', 'Chinese_bottom';
    'English', 'Chinese'};
condE2 = fs_par2cond(sessListE2, runFn, 'main.par', funcPath);
method = 1;
[contraE2, fscmd_con] = fs_mkcontrast(anaListE2, classPairsE2, condE2, method, 1);

% run first level analysis
fscmd_avg = fs_selxavg3(sessidE2, anaListE2, 1, '', 1);

fscmd = fs_fscmd2txt('fscmd_E2_MVPA.txt', outPath, fscmd_ana, fscmd_con, fscmd_avg);

%% Create labels (faceword_E2_update_labels.m)

%% MVPA
anaListE2 = {'main_sm0_E2_self.lh', 'main_sm0_E2_self.rh'};
labelList = {
    'roi.lh.f-vs-o.ffa1.label';
    'roi.lh.f-vs-o.ffa2.label';
    'roi.lh.word-vs-face-object-scrambled.label';
    'roi.lh.o-vs-scr.label';
    'roi.rh.f-vs-o.ffa1.label';
    'roi.rh.f-vs-o.ffa2.label';
    'roi.rh.o-vs-scr.label'
    };

% define the pairs for classification
classifyPairs_E2 = {'English_intact', 'Chinese_intact';
    'English_intact', 'English_exchange';
    'Chinese_intact', 'Chinese_exchange';
    'English_top', 'English_bottom';
    'Chinese_top', 'Chinese_bottom'};

mvpaTable = fs_cosmo_cvdecode(sessListE2, anaListE2, ...
    labelList, 'run_main.txt', classifyPairs_E2, ...
    'outpath', outPath, 'outfn', 'faceword_E2_Decode_zscore');

% Try without zscore
classopt.autoscale = false;
mvpaTablenoz = fs_cosmo_cvdecode(sessListE2, anaListE2, ...
    labelList, 'run_main.txt', classifyPairs_E2, ...
    'outpath', outPath, 'outfn', 'faceword_E2_Decode_noz', ...
    'classopt', classopt);



%% Similarity analysis

classPairsSim = {...
    'Chinese_intact', 'Chinese_exchange';
    'English_intact', 'English_exchange'};

condName = {...
    'Chinese_top', 'Chinese_bottom';
    'English_top', 'English_bottom'};

condWeight = [...
    0.5, 0.5;
    0.25, 0.75;
    0.75, 0.25];

predTable = fs_cosmo_similarity(sessListE2, anaListE2, labelList,  ...
    'run_main.txt', classPairsSim, condName, condWeight, 1, outPath);

% do not apply autoscale
predTable = fs_cosmo_similarity(sessListE2, anaListE2, labelList,  ...
    'run_main.txt', classPairsSim, condName, condWeight, 0, outPath);


%% Decoding in LO with 100, 150, 200, 300 mm^2
anaListE2 = {'main_sm0_E2_self.lh', 'main_sm0_E2_self.rh'};
labelList_LO = {
    'roi.lh.o-vs-scr.label';
    'roi.lh.o-vs-scr.a100.label';
    'roi.lh.o-vs-scr.a150.label';
    'roi.lh.o-vs-scr.a200.label';
    'roi.lh.o-vs-scr.a300.label';
    'roi.rh.o-vs-scr.label';
    'roi.rh.o-vs-scr.a100.label';
    'roi.rh.o-vs-scr.a150.label';
    'roi.rh.o-vs-scr.a200.label';
    'roi.rh.o-vs-scr.a300.label';
    };

mvpaTable = fs_cosmo_cvdecode(sessListE2, anaListE2, ...
    labelList_LO, 'run_main.txt', classifyPairs_E2, ...
    'outpath', outPath, 'outfn', 'faceword_E2_Decode_LO_zscore');

% Try without zscore
classopt.autoscale = false;
mvpaTablenoz = fs_cosmo_cvdecode(sessListE2, anaListE2, ...
    labelList_LO, 'run_main.txt', classifyPairs_E2, ...
    'outpath', outPath, 'outfn', 'faceword_E2_Decode_LO_noz', ...
    'classopt', classopt);

%% Train with face (intact vs. exchannged) and test on words (intact vs. exchanged)
trainPairsSim = {...
    'Chinese_intact', 'Chinese_exchange';
    'English_intact', 'English_exchange'};

testCond = {...
    {'English_intact', 'English_exchange'};
    {'Chinese_intact', 'Chinese_exchange'}};

condWeight = -1;

predTable1 = fs_cosmo_similarity(sessListE2, anaListE2, labelList,  ...
    'run_main.txt', trainPairsSim, testCond, condWeight, 1, fullfile(outPath, 'zscore'));

% do not apply autoscale
predTable2 = fs_cosmo_similarity(sessListE2, anaListE2, labelList,  ...
    'run_main.txt', trainPairsSim, testCond, condWeight, 0, fullfile(outPath, 'nozscore'));

