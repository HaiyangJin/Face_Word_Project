% For example, we are going to display ?h.V1_exvivo.label and
% ?h.V2_exvivo.label for fsaverage.

% set SUBJECTS_DIR for FreeSurfer
subjdir = '/Volumes/Atlantic/research/fMRI/faceword/freesurfer/subjects';
% subjdir = '/full/path/to/subject/dir';
setenv('SUBJECTS_DIR', subjdir);

% get the number of vertices
vtx_lh = read_surf(fullfile(subjdir, 'fsaverage', 'surf', 'lh.white'));
vtx_rh = read_surf(fullfile(subjdir, 'fsaverage', 'surf', 'rh.white'));
nVtx_lh = size(vtx_lh, 1);
nVtx_rh = size(vtx_rh, 1);


% load the labels
label_v1_lh = read_label('fsaverage', 'lh.V1_exvivo');
label_v2_lh = read_label('fsaverage', 'lh.V2_exvivo');
label_v1_rh = read_label('fsaverage', 'rh.V1_exvivo');
label_v2_rh = read_label('fsaverage', 'rh.V2_exvivo');

% convert the label file into roimask
roi_v1 = zeros(nVtx_lh + nVtx_rh, 1);
roi_v1([label_v1_lh(:, 1)+1; label_v1_rh(:, 1)+1+nVtx_lh], 1) = 1;
roi_v2 = zeros(nVtx_lh + nVtx_rh, 1);
roi_v2([label_v2_lh(:, 1)+1; label_v2_rh(:, 1)+1+nVtx_lh], 1) = 1;

rois = cell(2, 1);
rois{1} = logical(roi_v1);
rois{2} = logical(roi_v2);


% create "dummy" data
data = zeros(nVtx_lh + nVtx_rh, 1);

% display the ROIs
cvnlookup('fsaverage', 5, data, '', '', 1i, '', '', ...
    {'roimask', rois, 'roicolor', {'y', 'g'}}); % 

%% Notes:
% 
% Note:
% 1. You may have to copy the fsaverage to somewhere you have rights to 
%    write for running this example.
% 2. `read_label()` and `read_surf()` are FreeSurfer Matlab functions. 
%    You need to add these functions to the Matlab path. These FreeSurfer 
%    Matlab functions should be at e.g., `/Applications/FreeSurfer/matlab`.
% 3. For the arguments in `cvnlookup()`, please check its help file: 
%    https://github.com/kendrickkay/cvncode/blob/master/cvnlookup.m.