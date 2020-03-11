%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
boldext = 'self';
FW = fs_fun_projectinfo('faceword', funcPath, boldext);

outputPath = fullfile('~', 'Desktop', 'FaceWord');
if ~exist(outputPath, 'dir'); mkdir(outputPath); end


%% Draw labels
contrast_List = {
    'f-vs-o';
    'w-vs-o';
    'o-vs-scr'
    };
siglevel = '';
extraLabelInfo = '';

nCon = numel(contrast_List);
for iCon = 1:nCon
    contrast_name = contrast_List{iCon};
    
    % draw labels for both hemispheres separately
    fs_fun_drawlabel(FW, contrast_name, siglevel, extraLabelInfo);
    
end

%% Summarize the information of labels
label_parts = {'roi.*-vs-o.*label', 'roi.*o-vs-scr*.label'};
fs_sumlabelinfo(label_parts, outputPath); 
% [labelSumTable, labelSumLongTable] =fs_sumlabelinfo(label_parts, output_labelsum);

%% Overlaps between labels
labels = {
    {'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-w.label'};
    {'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa2.label'}
    };

fs_labeloverlap(labels, outputPath);

%% Screenshots of labels
% screenshots of single labels
labelList = { % ...
    'roi.lh.f13.o-vs-scr.label';
    'roi.rh.f13.o-vs-scr.label';
    'roi.lh.f13.f-vs-o.ffa1.label';
    'roi.lh.f20.f-vs-o.ffa1.label';
    'roi.lh.f13.f-vs-o.ffa2.label';
    'roi.lh.f13.w-vs-o.label';
    'roi.lh.f13.f-vs-o.label';
    'roi.lh.f20.f-vs-o.label';
    'roi.lh.f40.f-vs-o.label';
    'roi.rh.f13.f-vs-o.ffa1.label';
    'roi.rh.f13.f-vs-o.ffa2.label';
    'roi.rh.f20.f-vs-o.ffa2.label';
    'roi.rh.f40.f-vs-o.ffa2.label';
    'roi.rh.f13.f-vs-o.label';
    'roi.rh.f20.f-vs-o.label';
    'roi.rh.f40.f-vs-o.label'
    };

% fs_fun_screenshot_label(FW, labelList, output_path);
fs_fun_screenshot_label(FW, labelList, outputPath, '', '', '2,8');


% screenshots of multiple lables
label_multi = {
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.label', 'roi.lh.f20.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f20.f-vs-o.label', 'roi.lh.f13.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f20.f-vs-w.label'
    };
overlay = 1;  % show the contrast of the first label
fv_label(FW, label_multi, outputPath, overlay);


%% Classifications with CoSMoMVPA
labelList = { % ...
    'roi.lh.f13.o-vs-scr.label';
    'roi.rh.f13.o-vs-scr.label';
    'roi.lh.f13.f-vs-o.ffa1.label';
    'roi.lh.f20.f-vs-o.ffa1.label';
    'roi.lh.f13.f-vs-o.ffa2.label';
    'roi.lh.f13.w-vs-o.label';
    'roi.lh.f13.f-vs-o.label';
    'roi.lh.f20.f-vs-o.label';
    'roi.lh.f40.f-vs-o.label';
    'roi.rh.f13.f-vs-o.ffa1.label';
    'roi.rh.f13.f-vs-o.ffa2.label';
    'roi.rh.f20.f-vs-o.ffa2.label';
    'roi.rh.f40.f-vs-o.ffa2.label';
    'roi.rh.f13.f-vs-o.label';
    'roi.rh.f20.f-vs-o.label';
    'roi.rh.f40.f-vs-o.label'
    };

% define the pairs for classification
classifyPairs_E1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    };

classifyPairs_E2 = {'Chinese_intact', 'English_intact';
    'Chinese_intact', 'Chinese_exchange';
    'English_intact', 'English_exchange';
    'Chinese_top', 'Chinese_bottom';
    'English_top', 'English_bottom'};
classPairs = [classifyPairs_E1; classifyPairs_E2];

% 1-libsvm; 2-nn; 3-naive bayes; 4-lda; 5-svm(matlab)
classifiers = 1; % 1:nclassifiers 
runLoc = 0; % run analysis for localizer

% run the analysis
% [mvpaTable, uniTable, uniLocTable] = fs_fun_cosmo_crossdecode(FW, labelList, classPairs, classifiers, runLoc, outputPath);


%% Searchlight
% run searchlight and save the results as labels
surfType = 'inflated';
combineHemi = 0;  % 3 for each hemipsheres separately and the whole brain
% classPairs_SL = {
%     'face_intact', 'word_intact';
%     'Chinese_intact', 'English_intact'
%     };
classPairs_SL = classPairs;
classifier = 1;

% fs_fun_cosmo_searchlight(FW, file_surfcoor, combineHemi, classPairs_SL, classifier);
% 
% % convert label files into mgz files
% label_parts = {'sl.svm*label'};
% 
% for iSubj = 1:FW.nSubj
%     subjCode = fwSubj.subjList{iSubj};
%     labelDir = fs_labeldir(subjCode, label_parts);
%     
%     cellfun(@(x) fs_label2mgz(subjCode, x), {labelDir.name}, 'uni', false);
% end

%%%%%%%
sessCode = FW.sessList(21:30);

fs_fun_cosmo_crosssl(FW, classPairs_SL, sessCode, surfType, ...
    combineHemi, classifier); 


%% Similarity test (top+bottom vs. intact and misconfigured)

classPairsSim = {...
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'Chinese_intact', 'Chinese_exchange';
    'English_intact', 'English_exchange'};

condName = {...
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    'Chinese_top', 'Chinese_bottom';
    'English_top', 'English_bottom'};

condWeight = [...
    0.5, 0.5;
    0.25, 0.75;
    0.75, 0.25];

predictTable = fs_fun_cosmo_similarity(FW, labelList, ...
    classPairsSim, condName, condWeight, outputPath);

