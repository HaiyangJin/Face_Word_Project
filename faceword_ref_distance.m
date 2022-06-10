%% The reference coordinates
% Ross, D. A., Tamber-Rosenau, B. J., Palmeri, T. J., Zhang, J., Xu, Y., & Gauthier, I. (2018). High-resolution Functional Magnetic Resonance Imaging Reveals Configural Processing of Cars in Right Anterior Fusiform Face Area of Car Experts. Journal of Cognitive Neuroscience, 30(7), 973?984. https://doi.org/10.1162/jocn_a_01256
% McGugin, R. W., Ryan, K. F., Tamber-Rosenau, B. J., & Gauthier, I. (2018). The Role of Experience in the Face-Selective Response in Right FFA. Cerebral Cortex, 28(6), 2071?2084. https://doi.org/10.1093/cercor/bhx113
% McGugin, R. W., & Gauthier, I. (2016). The reliability of individual differences in face-selective responses in the fusiform gyrus and their relation to face recognition ability. Brain Imaging and Behavior, 10(3), 707?718. https://doi.org/10.1007/s11682-015-9467-4
% McGugin, R. W., Newton, A. T., Gore, J. C., & Gauthier, I. (2014). Robust expertise effects in right FFA. Neuropsychologia, 63, 135?144. https://doi.org/10.1016/j.neuropsychologia.2014.08.029

N = [30, 25, 29, 26];

% lFFA1
ref_lffa1 = [-39.39, -63.58, -28.71;
    -41.82, -61.57, -25.01;
    -39.90, -59.72, -32.06;
    -39.29, -65.00, -24.62];

% lFFA2
ref_lffa2 = [-40.81, -45.56, -30.05;
    -41.31, -43.14, -26.45;
    -41.01, -39.65, -30.66;
    -39.90, -49.66, -23.61];

% rFFA1
ref_rffa1 = [38.48 -67.08 -24.26;
    37.27 -61.33 -23.33;
    40.71 -58.94 -30.94;
    36.36 -67.43 -23.33];

% rFFA2
ref_rffa2 = [38.99 -46.61 -29.63;
    37.07 -42.90 -24.77;
    40.30 -37.55 -29.11;
    35.56 -51.03 -20.59];

%% coordinates to be decided

E1_lh = [-45.7 -54.4 -16.9;  % 6
    -40.0 -48.1 -23.0;  % 11
    -43.0 -53.1 -24.7]; % 12

E1_rh = [40.7 -54.3 -27.5;  % 9
    40.0 -50.5 -21.8;  % 11
    50.3 -58.8 -24.8];  % 20

E2_lh = [-41.3, -48.6, -13.8]; % N19

E2_rh = [39.1, -51.9, -22.5; % N13
    42.5, -49.3, -13.9; % N16
    45.6, -49.5, -22.5]; % N11


%%
[closer_E1_lh, dist_E1_lh, t1, t2] = compare_dist(E1_lh, ref_lffa1, ref_lffa2, N);
[closer_E2_lh, dist_E2_lh, t3, t4] = compare_dist(E2_lh, ref_lffa1, ref_lffa2, N);

[closer_E1_rh, dist_E1_rh, t5, t6] = compare_dist(E1_rh, ref_rffa1, ref_rffa2, N);
[closer_E2_rh, dist_E2_rh, t7, t8] = compare_dist(E2_rh, ref_rffa1, ref_rffa2, N);


% [closer_E1_lh1, dist_E1_lh1, t11, t21] = compare_dist(E1_lh, 'lffa1', 'lffa2');


%% VWFA1/2 E1

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

outPath = fullfile('~', 'Desktop', 'FaceWord_checklabel_E1');
fs_mkdir(outPath);

% Setting for labels
anaList = {'loc_self.lh', 'loc_self.rh'};

% calculate the distances
tempE1 = fs_labelinfo('roi.lh.word-vs-face-object-scrambled.label', fs_subjcode(sessList));

[closer_vwfa1, dist_vwfa1, v1, v2] = compare_dist(tempE1.MNI305_gm, 'vwfa1', 'vwfa2');

tempE1.Closer = closer_vwfa1;
tempE1.dist = dist_vwfa1;

%% VWFA1/2 E2

fs_setup('6.0');
subjectsPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
fs_subjdir(subjectsPath);

funcPath = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/Data_fMRI';
template = 'self';
fs_funcdir(funcPath);
cd(funcPath);
% % save a new sessid file for faceword*_self
% sessSelf = fs_funcdir(funcPath, 'faceword*_self');
% fs_createfile('sessid_E2_self', sessSelf(1:21));

sessListE2 = fs_sesslist('sessid_E2_self');

outPath = fullfile('~', 'Desktop', 'FaceWord_checklabel_E2');
fs_mkdir(outPath);

% Setting for labels
anaList = {'loc_self.lh', 'loc_self.rh'};

% calculate the distances
tempE2 = fs_labelinfo('roi.lh.word-vs-face-object-scrambled.label', fs_subjcode(sessListE2));

[closer_vwfa1, dist_vwfa1, v1, v2] = compare_dist(tempE2.MNI305_gm, 'vwfa1', 'vwfa2');

tempE2.Closer = closer_vwfa1;
tempE2.dist = dist_vwfa1;


