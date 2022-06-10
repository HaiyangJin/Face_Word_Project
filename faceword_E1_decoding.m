%% Information used later
fs_setup('6.0');
struPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(struPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath, 'faceword*_self');

% session list for E1 
sessidE1 = 'sessid_E1_self';
sessListE1 = fs_sesslist(sessidE1);

outPath = fullfile('~', 'Desktop', 'FaceWord_E1_MVPA_t');
fm_mkdir(outPath); 

%% fmcpr.even.nii.gz -> fmcpr.even.sm0.fsaverage.?h.nii.gz
%%%% project the unsmoothed data 

% % project data for each session separately
% for iSess = 1:numel(sessListE1)
%     
%     % this session code
%     thisSess = sessListE1{iSess};
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
% make analysis for E1 
TR = 2;
runFn = 'run_Main.txt';
nCond = 8;
refDura = 16;

% make analysis for E1 
[anaListE1, fscmd_ana] = fs_mkanalysis('main', template, TR, runFn, nCond, refDura, ...
    'smooth', 0, 'hemis', {'lh', 'rh'}, 'anaextra', 'E1', 'stc', 'even', 'nskip', 4);
% anaListE1 = {'main_sm0_E1_self.lh', 'main_sm0_E1_self.rh'};

% make contrast for E1
classPairsE1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    'face', 'word'};
condE1 = fs_par2cond(sessListE1, runFn, 'main.par', funcPath);
method = 1;
[contraE1, fscmd_con] = fs_mkcontrast(anaListE1, classPairsE1, condE1, method, 1);

% run first level analysis
fscmd_avg = fs_selxavg3(sessidE1, anaListE1, 1, '', 1);

fscmd = fs_fscmd2txt('fscmd_E1_MVPA.txt', outPath, fscmd_ana, fscmd_con, fscmd_avg);

%% Create labels (faceword_E1_update_labels.m)

%% MVPA (betat)
anaListE1 = {'main_sm0_E1_self.lh', 'main_sm0_E1_self.rh'};

% create beta t-value files
% fs_processbeta(sessListE1, anaListE1, 'runinfo', 'run_Main.txt', 'runwise', 1);

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
classifyPairs_E1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    };

mvpaTable = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
    labelList, classifyPairs_E1, 'runinfo', 'run_Main.txt', ...
    'outpath', outPath, 'outfn', 'faceword_E1_Decode_zscore', ...
    'datafn', 'betat.nii.gz');

% Try without zscore
classopt.autoscale = false;
mvpaTablenoz = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
    labelList, classifyPairs_E1, 'runinfo', 'run_main.txt', ...
    'outpath', outPath, 'outfn', 'faceword_E1_Decode_noz', ...
    'classopt', classopt, 'datafn', 'betat.nii.gz');


%% MVPA (beta)
anaListE1 = {'main_sm0_E1_self.lh', 'main_sm0_E1_self.rh'};
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
classifyPairs_E1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    };

mvpaTable = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
    labelList, classifyPairs_E1, 'runlist', 'run_main.txt', ...
    'outpath', outPath, 'outfn', 'faceword_E1_Decode_zscore');

% Try without zscore
mvpaTablenoz = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
    labelList, classifyPairs_E1, 'runlist', 'run_main.txt', ...
    'outpath', outPath, 'outfn', 'faceword_E1_Decode_noz', ...
    'autoscale', false);


% TRY: with different c for libsvm
cs = -5:15;
cmvpaTable = cell(numel(cs), 1);
for iC = 1:numel(cs)
   
    classopt.c = 2^cs(iC);
    
    tempTable = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
        labelList, classifyPairs_E1, 'runlist', 'run_main.txt', 'writeoutput', 0, ...
        'classopt', classopt);
    
    if ~isempty(tempTable)
        tempTable.c = repmat(classopt.c, size(tempTable, 1), 1);
    end
    
    cmvpaTable{iC, 1} = tempTable;
end

theTable = vertcat(cmvpaTable{:});
writetable(theTable, 'faceword_E1_DecodeC_HJ.csv');



%% Similarity analysis

classPairsSim = {...
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange'};

condName = {...
    'face_top', 'face_bottom';
    'word_top', 'word_bottom'};

condWeight = [...
    0.5, 0.5;
    0.25, 0.75;
    0.75, 0.25];

predTable = fs_cosmo_similarity(sessListE1, anaListE1, labelList,  ...
    'run_main.txt', classPairsSim, condName, condWeight, 1, outPath);

% do not apply autoscale
predTable = fs_cosmo_similarity(sessListE1, anaListE1, labelList,  ...
    'run_main.txt', classPairsSim, condName, condWeight, 0, outPath);


%% Decoding in LO with 100, 150, 200, 300 mm^2
anaListE1 = {'main_sm0_E1_self.lh', 'main_sm0_E1_self.rh'};
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

mvpaTable = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
    labelList_LO, classifyPairs_E1, 'runlist', 'run_main.txt', ...
    'outpath', outPath, 'outfn', 'faceword_E1_Decode_LO_zscore');

% Try without zscore
mvpaTablenoz = fs_cosmo_cvdecode(sessListE1, anaListE1, ...
    labelList_LO, classifyPairs_E1, 'runlist', 'run_main.txt', ...
    'outpath', outPath, 'outfn', 'faceword_E1_Decode_LO_noz', ...
    'autoscale', false);


%% Train with face (intact vs. exchannged) and test on words (intact vs. exchanged)
trainPairsSim = {...
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange'};

testCond = {...
    {'word_intact', 'word_exchange'};
    {'face_intact', 'face_exchange'}};

condWeight = -1;

predTable1 = fs_cosmo_similarity(sessListE1, anaListE1, labelList,  ...
    'run_main.txt', trainPairsSim, testCond, condWeight, 1, fullfile(outPath, 'zscore'));

% do not apply autoscale
predTable2 = fs_cosmo_similarity(sessListE1, anaListE1, labelList,  ...
    'run_main.txt', trainPairsSim, testCond, condWeight, 0, fullfile(outPath, 'nozscore'));

