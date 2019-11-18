function subjCode_mri = fw_subjcode(subjCode_bold)
% This function is specific for FaceWord project.
% This function get the subjCode for $SUBJECTS_DIR in FreeSurfer
%
% Created by Haiyang Jin (18/11/2019)

subjCode_cell = strsplit(subjCode_bold, '_');

subjCode = subjCode_cell{1};


subjCode_mri = [subjCode '*'];

end