%% E1 Information used later
fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath);
cd(funcPath);

outPath = fullfile('~', 'Desktop', 'FaceWord_hospital');
fs_mkdir(outPath); 

%% The session used
% following faceword_E1_uni.m; faceword_E2_uni.m
sesscode_E1 = 'faceword08_self';
sesscode_E2 = 'facewordN09_self';

%% E1
anaList_loc = {'loc_self.lh', 'loc_self.rh'};
% make contrast 
classPairs_loc = {{'face', 'word', 'object'}, {'scrambled'};
    'face', 'scrambled';
    'word', 'scrambled';
    'object', 'scrambled'
    };
cond_loc = fs_par2cond(sesscode_E1, 'run_loc.txt', 'loc.par');
method = 1;
[anaStruct_loc, fscmd_con_loc] = fs_mkcontrast(anaList_loc, classPairs_loc, cond_loc, method, 1);

% run first level analysis
fscmd_avg_E1_loc = fs_selxavg3({sesscode_E1}, anaList_loc, 1, 1, 1);
fscmd_avg_E2_loc = fs_selxavg3({sesscode_E2}, anaList_loc, 1, 1, 1);

% save the commands used
fs_createfile(fullfile(outPath, 'fscmd_E1_2_hospital_loc.txt'), ...
    vertcat(fscmd_con_loc(:,1), fscmd_avg_E1_loc(:,1), fscmd_avg_E2_loc(:,1)));

conList_loc_all = fs_ana2con(anaList_loc);

conList_loc_08 = fs_fullfile({'pr017', 'pr018'}, conList_loc_all([3,4,6,9]));
fs_cvn_print1st(sesscode_E1, anaList_loc, conList_loc_08, ...
    fullfile(outPath, 'loc_hospital'), 'visualimg', 0, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc',...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 1, 'roicolors', fs_colors);

conList_loc_N09 = fs_fullfile({'pr015', 'pr016'}, conList_loc_all([3,4,6,9]));
fs_cvn_print1st(sesscode_E2, anaList_loc, conList_loc_N09, ...
    fullfile(outPath, 'loc_hospital'), 'visualimg', 0, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc',...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 1, 'roicolors', fs_colors);

% fs_cvn_print1st({sesscode_E1,sesscode_E2}, anaList_loc, conList_loc, ...
%     fullfile(outPath, 'loc_hospital'), 'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc',...
%     'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors,...
%     'showinfo', 1, 'cvnopts', {'overlayalpha', 0.5});















