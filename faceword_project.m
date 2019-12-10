%% Information used later
boldext = 'self';
FW = fw_projectinfo(boldext);
output_path = fullfile('~', 'Desktop', 'FaceWord');
if ~exist(output_path, 'dir'); mkdir(output_path); end


%% Draw labels
contrast_List = {
    'f-vs-o';
    'w-vs-o';
    'o-vs-scr'};
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


%% Information for later
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

%% Screenshots of labels
% single labels
fs_fun_screenshot_label(FW, labelList, output_path);

% multiple lables
label_multi = {
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.label', 'roi.lh.f20.f-vs-w.label';
%     'roi.lh.f13.w-vs-o.label', 'roi.lh.f20.f-vs-o.label', 'roi.lh.f13.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-w.label';
    'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f20.f-vs-w.label'};
overlay = 1;  % show the contrast of the first label
fs_fun_screenshot_label(FW, label_multi, overlay, output_path);


%% Classifications with CoSMoMVPA
% labelNames = {'roi.rh.f20.f-vs-o.label'};
classifiers = 1; % 1:nclassifiers
% 1-libsvm; 2-nn; 3-naive bayes; 4-lda; 5-svm(matlab)
runLoc = 0; % run analysis for localizer

% run the analysis
[mvpaTable, uniTable, uniLocTable] = fw_classification(labelList, classifiers, runLoc, output_path);


%% Searchlight
% get setup for FaceWord project
subjBoldList = FW.subjList;
nSubj = FW.nSubj;

for iSubj = 1:nSubj
    
    thisSubj = subjBoldList{iSubj};
    
    expCode = ceil(iSubj/(nSubj/2));
    
%     feature_count = 200;
    fw_searchlight(thisSubj, expCode);
    
end

