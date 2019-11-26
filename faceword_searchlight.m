% get setup for FreeSurfer
clear all
clc;

FS = fs_setup;

subjBoldDir = dir(fullfile(FS.subjects, '..', 'Data_fMRI', 'faceword*_self'));

subjBoldList = {subjBoldDir.name};
nSubj = numel(subjBoldList);

for iSubj = 1:nSubj
    
    thisSubj = subjBoldList{iSubj};
    
    expCode = ceil(iSubj/(nSubj/2));
    
    fw_searchlight(thisSubj, expCode);
    
end
