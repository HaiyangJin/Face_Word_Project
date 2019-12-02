function [roisize, talCoor, nVtxs, VtxMax] = fw_labelsize(subjCode_bold, labelfn, betafn, thmin)
% This function obtains the size of the label (ROI) from FreeSurfer
% commands (mri_surfcluster).
%
% Created by Haiyang Jin (18/11/2019)

if nargin < 3 || isempty(betafn)
    betafn = 'beta.nii.gz';
end
if nargin < 4 || isempty(thmin)
    thmin = 0.001;
end

% load FreeSurfer set up
FS = fs_setup;

hemi = fs_hemi(labelfn);
subjCode_mri = fw_subjcode(subjCode_bold);

% label file
if labelfn(1) ~= filesep
    labeldir = dir(fullfile(FS.subjects, subjCode_mri, 'label', labelfn));
else
    labeldir = dir(labelfn);
end
labelfile = fullfile(labeldir.folder, labeldir.name);

% beta file
if betafn(1) ~= filesep
    analysisfolder = ['loc_self.' hemi];
    betadir = dir(fullfile(FS.subjects, '..', 'Data_fMRI', subjCode_bold, ...
        'bold', analysisfolder, betafn));
else
    betadir = dir(betafn);
end
betafile = fullfile(betadir.folder, betadir.name);

% create the freesurfer command
fn_path = fullfile('~', 'Desktop', 'LabelSize');
if ~exist(fn_path, 'dir'); mkdir(fn_path); end
fn_out = sprintf('cluster%%%s%%%s.txt', labeldir.name, subjCode_mri);
file_out = fullfile(fn_path, fn_out);
fs_command = sprintf(['mri_surfcluster --in %s --clabel %s --subject %s ' ...
    '--surf inflated --thmin %d --hemi %s --sum %s'], ...
    betafile, labelfile, subjCode_mri, ...
    thmin, hemi, file_out);

system(fs_command);

%% load the output file from mri_surfcluster
tempcell = importdata(file_out, ' ', 36);

tempdata = tempcell.data;

VtxMax = tempdata(3);
roisize = tempdata(4);
talCoor = tempdata(5:7);
nVtxs = tempdata(8);

end