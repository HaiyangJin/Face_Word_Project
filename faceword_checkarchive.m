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



outPath = fullfile('~', 'Desktop', 'FaceWord_checkarchive');
if ~exist(outPath, 'dir'); mkdir(outPath); end


labelList = {
    'roi.lh.f-vs-o.ffa1.label';
    'roi.lh.f-vs-o.ffa2.label';
    'roi.lh.word-vs-face-object-scrambled.label';
    'roi.lh.o-vs-scr.label';
    'roi.rh.f-vs-o.ffa1.label';
    'roi.rh.f-vs-o.ffa2.label';
    'roi.rh.o-vs-scr.label'
    };
labellist_ar = cellfun(@(x) strrep(x, '.label', '.archive.label'), labelList, 'uni', false);


%% E1
sessListE1 = fs_sesslist('sessid_E1_self');
anaListE1 = {'main_sm5_E1_self.lh', 'main_sm5_E1_self.rh'};

table_E1 = fs_labelinfo(labellist_ar, fs_subjcode(sessListE1));


%% E2
sessListE2 = fs_sesslist('sessid_E2_self');
anaListE2 = {'main_sm5_E2_self.lh', 'main_sm5_E2_self.rh'};

table_E2 = fs_labelinfo(labellist_ar, fs_subjcode(sessListE2));

% all is ok.
