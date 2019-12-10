

%% Summarize the information of labels
label_parts = {'roi.*-vs-o.*label', 'roi.*o-vs-scr*.label'};
output_labelsum = fullfile('~', 'Desktop', 'FaceWord_LabelSummary');
fs_sumlabelinfo(label_parts, output_labelsum); 
% [labelSumTable, labelSumLongTable] =fs_sumlabelinfo(label_parts, output_labelsum);


%% Classifications with CoSMoMVPA
labelNames = { % ...
    'roi.lh.f13.o-vs-scr.label',...
    'roi.rh.f13.o-vs-scr.label',...
    'roi.lh.f13.f-vs-o.ffa1.label', ...
    'roi.lh.f20.f-vs-o.ffa1.label', ...
    'roi.lh.f13.f-vs-o.ffa2.label',...
    'roi.lh.f13.w-vs-o.label', ...
    'roi.lh.f13.f-vs-o.label', ...
    'roi.lh.f20.f-vs-o.label', ...
    'roi.lh.f40.f-vs-o.label',...
    'roi.rh.f13.f-vs-o.ffa1.label', ...
    'roi.rh.f13.f-vs-o.ffa2.label',...
    'roi.rh.f20.f-vs-o.ffa2.label',...
    'roi.rh.f40.f-vs-o.ffa2.label', ...
    'roi.rh.f13.f-vs-o.label',...
    'roi.rh.f20.f-vs-o.label', ...
    'roi.rh.f40.f-vs-o.label'};
% labelNames = {'roi.rh.f20.f-vs-o.label'};
classifiers = 1; % 1:nclassifiers
% 1-libsvm; 2-nn; 3-naive bayes; 4-lda; 5-svm(matlab)
runLoc = 0; % run analysis for localizer
outputFolder = fullfile('~', 'Desktop/', 'FW_Classification');

% run the analysis
[mvpaTable, uniTable, uniLocTable] = fw_classification(labelNames, classifiers, runLoc, outputFolder);


%% Searchlight
% get setup for FaceWord project
FW = fw_projectinfo('self');

subjBoldList = FW.subjList;
nSubj = FW.nSubj;

for iSubj = 1:nSubj
    
    thisSubj = subjBoldList{iSubj};
    
    expCode = ceil(iSubj/(nSubj/2));
    
%     feature_count = 200;
    fw_searchlight(thisSubj, expCode);
    
end

