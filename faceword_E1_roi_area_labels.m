% this code is modified from faceword_E1_trim_labels.m

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
subjList = fs_subjcode(sessList);

outPath = fullfile('~', 'Desktop', 'FaceWord_largerconcen_E1');
fm_mkdir(outPath);

% Setting for labels
anaList = {'loc_self.lh', 'loc_self.rh'};
anaListE1 = {'main_sm5_E1_self.lh', 'main_sm5_E1_self.rh'};


%% %%%%%%%%%%%%%%% FFA12 %%%%%%%%%%%%%%%%%
gmList = {'roi.lh.f-vs-o.ffa1.gm', 'roi.lh.f-vs-o.ffa2.gm',...
    'roi.rh.f-vs-o.ffa1.gm','roi.rh.f-vs-o.ffa2.gm', ...
    'roi.lh.word-vs-face-object-scrambled.gm', ... 'roi.lh.w-vs-o.gm', ...
    'roi.lh.o-vs-scr.gm', ...
    'roi.rh.o-vs-scr.gm'};

areas = [50, 100, 200, 300];

labelInfocell = cell(length(areas), 1);
labelCell = cell(length(areas), length(gmList));
unicell = cell(length(areas), 1);

for iarea = 1:numel(areas)
    
    thearea = areas(iarea);
    
    % create the roi
    fs_circleroi(subjList, gmList, 'area', thearea);
    
    % label list
    labelList = cellfun(@(x) [erase(x, 'gm') ...
        sprintf('surf.geodesic.a%d.label', thearea)], gmList, 'uni', false);
    labelCell(iarea, :) = labelList;
    labelInfocell{iarea,1} = fs_labelinfo(labelList, subjList);

    % univariate data
    thisUniTable = fs_cosmo_readdata(sessList, anaListE1, 'labellist', labelList, 'runlist', 'run_main.txt');
    thisUniTable.Area = repmat(thearea, size(thisUniTable, 1), 1);
    
    unicell{iarea,1} = thisUniTable;
    
end

writetable(vertcat(labelInfocell{:}), fullfile(outPath, 'faceword_E1_label_area_HJ.csv'));
writetable(vertcat(unicell{:}), fullfile(outPath, 'faceword_E1_Uni_area_HJ.csv'));

lh_labels = labelCell(:,[1,2,5,6]);
lh_colors = arrayfun(@(x) repmat(fm_colors(x),4,1), 1:4, 'uni', false);
fs_cvn_print1st(sessList, anaList(1), {lh_labels(:)},...
    outPath, 'viewpt', -4, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, ...
    'roicolors', vertcat(lh_colors{:}));

rh_labels = labelCell(:,[3,4,7]);
rh_colors = arrayfun(@(x) repmat(fm_colors(x),4,1), 1:3, 'uni', false);
fs_cvn_print1st(sessList, anaList(2), {rh_labels(:)},...
    outPath, 'viewpt', -4, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, ...
    'roicolors', vertcat(rh_colors{:}));


%% MVPA
anaListE1_mvpa = {'main_sm0_E1_self.lh', 'main_sm0_E1_self.rh'};
labelList_mvpa = [lh_labels(:); rh_labels(:)];

% define the pairs for classification
classifyPairs_E1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    };

mvpaTable = fs_cosmo_cvdecode(sessList, anaListE1_mvpa, ...
    labelList_mvpa, 'run_main.txt', classifyPairs_E1, ...
    'outpath', outPath, 'outfn', 'faceword_roi_area_E1_Decode_zscore');

% Try without zscore
classopt.autoscale = false;
mvpaTablenoz = fs_cosmo_cvdecode(sessList, anaListE1_mvpa, ...
    labelList_mvpa, 'run_main.txt', classifyPairs_E1, ...
    'outpath', outPath, 'outfn', 'faceword_roi_area_E1_Decode_noz', ...
    'classopt', classopt);



%% backup

labelList = {{'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label','lh.MFS.label'}; 
    {'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label','rh.MFS.label'};
    {'roi.lh.w-vs-o.label', 'lh.OTS.label'}; 
    {'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label'};
    {'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label'};
    {'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label', 'roi.lh.w-vs-o.label','roi.lh.o-vs-scr.label'};
    {'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label', 'roi.rh.o-vs-scr.label'}};

