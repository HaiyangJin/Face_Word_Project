%% Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath);
cd(funcPath);
% % save a new sessid file for faceword*_self
% sessSelf = fs_funcdir(funcPath, 'faceword*_self');
% fs_createfile('sessid_E1_self', sessSelf(1:21));

sessList = fs_sesslist('sessid_E1_self');

outPath = fullfile('~', 'Desktop', 'FaceWord_checklabel');
if ~exist(outPath, 'dir'); mkdir(outPath); end

% Setting for labels
anaList = {'loc_self.lh', 'loc_self.rh'};
labelList = { % ...
    'roi.lh.f13.f-vs-o.ffa1.label';
    'roi.lh.f20.f-vs-o.ffa1.label';
    'roi.lh.f13.f-vs-o.ffa2.label';
    'roi.lh.f20.f-vs-o.ffa2.label';
    'roi.lh.f13.w-vs-o.label';
    'roi.lh.f20.w-vs-o.label';
%     'roi.lh.f13.f-vs-o.label';
%     'roi.lh.f20.f-vs-o.label';
%     'roi.lh.f40.f-vs-o.label';
    'roi.lh.f13.o-vs-scr.label';
    'roi.lh.f20.o-vs-scr.label';
    'roi.rh.f13.f-vs-o.ffa1.label';
    'roi.rh.f20.f-vs-o.ffa1.label';
    'roi.rh.f13.f-vs-o.ffa2.label';
    'roi.rh.f20.f-vs-o.ffa2.label';
    'roi.rh.f40.f-vs-o.ffa2.label';
%     'roi.rh.f13.f-vs-o.label';
%     'roi.rh.f20.f-vs-o.label';
%     'roi.rh.f40.f-vs-o.label';
    'roi.rh.f13.o-vs-scr.label';
    'roi.rh.f20.o-vs-scr.label';
    };

% label_multi = {
%     {'roi.rh.f13.f-vs-o.label', 'roi.rh.f13.f-vs-o.ffa1.label', 'roi.rh.f13.f-vs-o.ffa2.label', 'roi.rh.f13.o-vs-scr.label'};
%     {'roi.rh.f20.f-vs-o.label', 'roi.rh.f20.f-vs-o.ffa1.label', 'roi.rh.f20.f-vs-o.ffa2.label', 'roi.rh.f20.o-vs-scr.label'};
%     {'roi.lh.f13.f-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f13.o-vs-scr.label', 'roi.lh.f13.w-vs-o.label'};
%     {'roi.lh.f20.f-vs-o.label', 'roi.lh.f20.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-o.ffa2.label', 'roi.lh.f20.o-vs-scr.label', 'roi.lh.f20.w-vs-o.label'};
%     };
label_multi = {
    {'roi.rh.f13.f-vs-o.ffa1.label', 'roi.rh.f13.f-vs-o.ffa2.label', 'roi.rh.f13.o-vs-scr.label'};
    {'roi.rh.f20.f-vs-o.ffa1.label', 'roi.rh.f20.f-vs-o.ffa2.label', 'roi.rh.f20.o-vs-scr.label'};
    {'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f13.o-vs-scr.label', 'roi.lh.f13.w-vs-o.label'};
    {'roi.lh.f20.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-o.ffa2.label', 'roi.lh.f20.o-vs-scr.label', 'roi.lh.f20.w-vs-o.label'};
    };


%% Print labels for E1

% session list for E1 
sessListE1 = fs_sesslist('sessid_E1_self');
% print labels with first-level results
fs_cvn_print1st(sessListE1, anaList, labelList, fullfile(outPath, 'loc_self_E1'),...
    'subfolder', 1);

% print multiple labels on the same brain
fs_cvn_print1st(sessListE1, anaList, label_multi, fullfile(outPath, 'loc_self_E1_multi'), ...
    'subfolder', 1)

% only print the contrast
conList = fs_ana2con(anaList);
fs_cvn_print1st(sessListE1, anaList, conList, fullfile(outPath, 'loc_self_E1_contrast'), ...
    'cvnopts', {'overlayalpha', 0.5});

% save the label information with mri_surfcluster
[outTable, fscmd] = fs_surflabel(sessListE1, labelList, anaList, outPath);
fs_createfile(fullfile(outPath, 'fscmd_checklabel_E1.txt'), fscmd);


%%%%%%%%%%%% Temporary %%%%%%%%%%%%%%%%
% save the label information
subjList = fs_subjcode(sessListE1);
labelTable = fs_labelinfo(labelList, subjList);
writetable(labelTable, fullfile(outPath, 'labelInfo_E1_temp.csv'));

% single with label information
fs_cvn_print1st(sessListE1, anaList, labelList, fullfile(outPath, 'loc_self_E1_singleinfo'),...
    'annot', 'aparc', 'showinfo', 1, 'markpeak', 1, 'subfolder', 1, 'cvnopts', {'overlayalpha', 0.5});

% save multiple with label information
labelinfo_multi = {
    {'roi.rh.f13.f-vs-o.label', 'roi.rh.f13.f-vs-o.ffa1.label', 'roi.rh.f13.f-vs-o.ffa2.label', 'roi.rh.f13.o-vs-scr.label'};
    {'roi.rh.f20.f-vs-o.label', 'roi.rh.f20.f-vs-o.ffa1.label', 'roi.rh.f20.f-vs-o.ffa2.label', 'roi.rh.f20.o-vs-scr.label'};
    {'roi.lh.f13.f-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f13.o-vs-scr.label', 'roi.lh.f13.w-vs-o.label'};
    {'roi.lh.f20.f-vs-o.label', 'roi.lh.f20.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-o.ffa2.label', 'roi.lh.f20.o-vs-scr.label', 'roi.lh.f20.w-vs-o.label'};
    };
fs_cvn_print1st(sessListE1, anaList, labelinfo_multi, fullfile(outPath, 'loc_self_E1_multiinfo'), ...
    'annot', 'aparc', 'showinfo', 1, 'markpeak', 1, 'subfolder', 1, 'cvnopts', {'overlayalpha', 0.5});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% create empty excel for inputs the checking information
[labelE1, sessE1] = ndgrid(labelList, subjList);
inputCellE1 = sortrows([sessE1(:), labelE1(:)], 1);

fileE1 = fullfile(outPath, 'checklabel_E1.csv');
writetable(cell2table(inputCellE1), fileE1);

%%%%%%%%%%%%%%%%%%%%%
% read labelInfo.xlsx
labelT = readtable('labelInfo.xlsx');
labelT.AnalysisName = [];

[tempsubj, templabel] = ndgrid(unique(labelT.SubjCode), labelList);
inputCE1 = horzcat(tempsubj(:), templabel(:));

isEmpty = ~arrayfun(@(x) any(strcmp(labelT.SubjCode, inputCE1{x, 1}) & strcmp(labelT.LabelName, inputCE1{x, 2})), 1:size(inputCE1, 1));
SubjCode = inputCE1(isEmpty, 1);
LabelName = inputCE1(isEmpty, 2);
emptyT = table(SubjCode, LabelName);

outT = outerjoin(labelT,emptyT,'MergeKeys', true);
outT.Available = double(~arrayfun(@isnan, outT.ClusterNo));

outT = [outT(:, 1:2), outT(:, end), outT(:, 3:end-1)];

writetable(outT, 'checklabel_E1_all.xlsx');

%% Print labels for E2

% % save a new sessid file for faceword*_self
% sessSelf = fs_funcdir(funcPath, 'facewordN*_self');
% fs_createfile('sessid_E2_self', sessSelf);

% session list for E2 
sessListE2 = fs_sesslist('sessid_E2_self');
fs_cvn_print1st(sessListE2, anaList, labelList, fullfile(outPath, 'loc_self_E2'), 'subfolder', 1);


% print multiple labels on the same brain
fs_cvn_print1st(sessListE2, anaList, label_multi, fullfile(outPath, 'loc_self_E2_multi'), ...
    'subfolder', 1)

% only print the contrast
conList = fs_ana2con(anaList);
fs_cvn_print1st(sessListE2, anaList, conList, fullfile(outPath, 'loc_self_E2_contrast'), ...
    'cvnopts', {'overlayalpha', 0.5});

% save the label information with mri_surfcluster
[outTable, fscmd] = fs_surflabel(sessListE2, labelList, anaList, outPath);
fs_createfile(fullfile(outPath, 'fscmd_checklabel_E2.txt'), fscmd);

%%%%%%%%%%%% Temporary %%%%%%%%%%%%%%%%
% save the label information
subjList = fs_subjcode(sessListE2);
labelTable = fs_labelinfo(labelList, subjList);
writetable(labelTable, fullfile(outPath, 'labelInfo_E2_temp.csv'));

% single with label information
fs_cvn_print1st(sessListE2, anaList, labelList, fullfile(outPath, 'loc_self_E2_singleinfo'),...
    'annot', 'aparc', 'showinfo', 1, 'markpeak', 1, 'subfolder', 1, 'cvnopts', {'overlayalpha', 0.5});

% save multiple with label information
labelinfo_multi = {
    {'roi.rh.f13.f-vs-o.label', 'roi.rh.f13.f-vs-o.ffa1.label', 'roi.rh.f13.f-vs-o.ffa2.label', 'roi.rh.f13.o-vs-scr.label'};
    {'roi.rh.f20.f-vs-o.label', 'roi.rh.f20.f-vs-o.ffa1.label', 'roi.rh.f20.f-vs-o.ffa2.label', 'roi.rh.f20.o-vs-scr.label'};
    {'roi.lh.f13.f-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label', 'roi.lh.f13.f-vs-o.ffa2.label', 'roi.lh.f13.o-vs-scr.label', 'roi.lh.f13.w-vs-o.label'};
    {'roi.lh.f20.f-vs-o.label', 'roi.lh.f20.f-vs-o.ffa1.label', 'roi.lh.f20.f-vs-o.ffa2.label', 'roi.lh.f20.o-vs-scr.label', 'roi.lh.f20.w-vs-o.label'};
    };
fs_cvn_print1st(sessListE2, anaList, labelinfo_multi, fullfile(outPath, 'loc_self_E2_multiinfo'), ...
    'annot', 'aparc', 'showinfo', 1, 'markpeak', 1, 'subfolder', 1, 'cvnopts', {'overlayalpha', 0.5});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% [labelE2, sessE2] = ndgrid(labelList, subjList);
% inputCellE1 = sortrows([sessE2(:), labelE2(:)], 1);
% 
% fileE2 = fullfile(outPath, 'checklabel_E2.csv');
% writetable(cell2table(inputCellE1), fileE2);

%%%%%%%%%%%%%%%%%%%%%
% read labelInfo.xlsx
labelT = readtable('labelInfo.csv');
labelT.AnalysisName = [];

[tempsubj, templabel] = ndgrid(unique(labelT.SubjCode), labelList);
inputCE2 = horzcat(tempsubj(:), templabel(:));

isEmpty = ~arrayfun(@(x) any(strcmp(labelT.SubjCode, inputCE2{x, 1}) & strcmp(labelT.LabelName, inputCE2{x, 2})), 1:size(inputCE2, 1));
SubjCode = inputCE2(isEmpty, 1);
LabelName = inputCE2(isEmpty, 2);
emptyT = table(SubjCode, LabelName);

outT = outerjoin(labelT,emptyT,'MergeKeys', true);
outT.Available = double(~arrayfun(@isnan, outT.ClusterNo));

outT = [outT(:, 1:2), outT(:, end), outT(:, 3:end-1)];

writetable(outT, 'checklabel_E2_all.xlsx');


