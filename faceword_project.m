%% Information used later
boldext = 'self';
FW = fw_projectinfo(boldext);
output_path = fullfile('~', 'Desktop', 'FaceWord');
if ~exist(output_path, 'dir'); mkdir(output_path); end


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
fs_sumlabelinfo(label_parts, output_path); 
% [labelSumTable, labelSumLongTable] =fs_sumlabelinfo(label_parts, output_labelsum);

%% Overlaps between labels
labels = {
    {'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-w.label'};
    {'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa2.label'}
    };

fs_labeloverlap(labels, output_path);

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

fs_fun_screenshot_label(FW, labelList, output_path);

% screenshots of multiple lables
label_multi = {
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.label', 'roi.lh.f20.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f20.f-vs-o.label', 'roi.lh.f13.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f20.f-vs-w.label'
    };
overlay = 2;  % show the contrast of the first label
fs_fun_screenshot_label(FW, label_multi, output_path, overlay);


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
    'Chinese_top', 'Chinese_bottom';
    'English_intact', 'English_exchange';
    'English_top', 'English_bottom'};
classPairs = [classifyPairs_E1; classifyPairs_E2];

% 1-libsvm; 2-nn; 3-naive bayes; 4-lda; 5-svm(matlab)
classifiers = 1; % 1:nclassifiers 
runLoc = 0; % run analysis for localizer

% run the analysis
% [mvpaTable, uniTable, uniLocTable] = 
fs_fun_cosmo_classification(FW, labelList, classPairs, classifiers, runLoc, output_path);


%% Searchlight

file_surfcoor = 'inflated';
combineHemi = 3;  % for each hemipsheres separately and the whole brain
classPairs_SL = {
    'face_intact', 'word_intact';
    'Chinese_intact', 'English_intact'
    };
classifier = 1;

fs_fun_cosmo_searchlight(FW, file_surfcoor, combineHemi, classPairs_SL, classifier);


