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

sessListE1 = fs_sesslist('sessid_20Ss');

outPath = fullfile('~', 'Desktop', 'FaceWord_checklabel');
if ~exist(outPath, 'dir'); mkdir(outPath); end

%% 

% choose some labels on self space
labelList = {'roi.lh.f20.f-vs-o.label';
    'roi.rh.f20.f-vs-o.label';};

sessList = sessListE1(7:9);

% read labels to make sure they are available
info = fs_labelinfo(labelList, fs_subjcode(sessList));


%% Draw labels on fsaverage
anaList = {'loc_fs.lh', 'loc_fs.rh'};
conList = {'f-vs-o'};
fthresh = 2;

fscmd = fs_drawlabel(sessList, anaList, conList, fthresh, 'fsaverage');


labelList_fs = {'roi.lh.f20.f-vs-o.fsaverage.label';
    'roi.rh.f20.f-vs-o.fsaverage.label';};

info_fs = fs_labelinfo(labelList_fs, fs_subjcode(sessList));

%% convert label on self to fsaverage
fscmds = fs_label2label(fs_subjcode(sessList), labelList);


%% print the labels 
colors = fs_colors;
labelList_fssingle = {'roi.lh.f20.f-vs-o.fsaverage.label';
    'roi.rh.f20.f-vs-o.fsaverage.label';
    'roi.lh.f20.f-vs-o.2fsaverage.label';
    'roi.rh.f20.f-vs-o.2fsaverage.label';};
fs_cvn_print1st(sessList, anaList, labelList_fssingle, fullfile(outPath, 'single'), 'roicolors', colors(4, :));

labelList_fsmulti = {{'roi.lh.f20.f-vs-o.fsaverage.label', 'roi.lh.f20.f-vs-o.2fsaverage.label'};
    {'roi.rh.f20.f-vs-o.fsaverage.label', 'roi.rh.f20.f-vs-o.2fsaverage.label'}};
fs_cvn_print1st(sessList, anaList, labelList_fsmulti, fullfile(outPath, 'multiple'), 'roicolors', colors([4,1], :));

[outTable, fscmd_surf] = fs_surflabel(sessList, labelList_fssingle, anaList, outPath);
 
% fs_cvn_print1st(sessList, anaList, labelList_fssingle, fullfile(outPath, 'single'), ...
%     'roicolors', colors(4, :), 'showinfo', 1, 'markpeak', 1);
% 
% 
% fs_cvn_print1st(sessList, anaList, labelList_fsmulti, fullfile(outPath, 'multiple'),...
%     'roicolors', colors([4,1], :), 'showinfo', 1, 'markpeak', 1);


% save fscmd 
fs_fscmd2txt('fscmd.txt', outPath, fscmd, fscmds, fscmd_surf);




