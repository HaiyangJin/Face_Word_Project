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

outPath = fullfile('~', 'Desktop', 'FaceWord_checklabel_E1');
fm_mkdir(outPath);

% Setting for labels
anaList = {'loc_self.lh', 'loc_self.rh'};

%% Convert labels from fsaverage to all subjects
% ?h.MFS.label
msfLabels = {'lh.MFS.label', 'rh.MFS.label'};
fscmd_mfs = fs_label2label('fsaverage', msfLabels, fs_subjcode(sessList), 'samename');

% lh.OTS.label
fscmd_ots = fs_label2label('fsaverage', 'lh.OTS.label', fs_subjcode(sessList), 'samename');


%% read the checklabel_all_v2.0.xlsx
xlsFile = fullfile('/Users/hj23/GoogleDrive/0_NYUAD/01_Research/00_FaceWord/Results/11_CheckLabels/checklabel_all_v2.0.xlsx');
tableE1 = readtable(xlsFile, 'Sheet', 'Summary_E1');

isHighThre = strcmp(tableE1.Solution, 'higher threshold');

%% %%%%%%%%%%%%%%% FFA12 %%%%%%%%%%%%%%%%%
isFFA12 = strcmp(tableE1.Review, 'FFA12');

subjFFA = tableE1.SubjCode(isFFA12);
hemiFFA = cellfun(@fs_2hemi, tableE1.LabelName(isFFA12), 'uni', false);

ffaToCheck = unique(table(subjFFA, hemiFFA), 'rows');
ffaToCheck.SessCode = cellfun(@(x) sprintf('%s_self', x(1:10)), ffaToCheck.subjFFA, 'uni', false); 
ffaToCheck.Analysis = cellfun(@(x) sprintf('loc_self.%s', x), ffaToCheck.hemiFFA, 'uni', false);
ffaToCheck.LabelName = cellfun(@(x) sprintf('roi.%s.f13.f-vs-o.ffa12.label', x), ffaToCheck.hemiFFA, 'uni', false);

% make roi.?h.f13.f-vs-o.label 
fscmd = arrayfun(@(x) fs_drawlabel(ffaToCheck.SessCode(x), ffaToCheck.Analysis(x), ...
    'f-vs-o', 1.3, 'ffa12'), 1:size(ffaToCheck, 1), 'uni', false);
fscmd1 = vertcat(fscmd{:});

% screenshots of ffa12 with various thmin
infoTable1 = fs_cvn_printlabel(ffaToCheck.LabelName, ffaToCheck.SessCode, ...
    '', outPath, {'viewpt', 'ffa'});

% update labels with fixed size
% obtain FFA1 and FFA2 from FFA12
[labelMatCell, clustrVtx] = arrayfun(@(x) fs_trimlabel(ffaToCheck.LabelName{x},...
    ffaToCheck.SessCode{x}, outPath, 'ncluster', 2), [1 5], 'uni', false);

% Trim FFA1/2 l/rh
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.f-vs-o.ffa12.label',...
    x, outPath, 'ncluster', 3, 'lowerthresh', 1), sessList([3  ]), 'uni', false);

% check if the labels are available
labelList = {'roi.rh.f-vs-o.ffa1.label';'roi.lh.f-vs-o.ffa1.label'; 
    'roi.rh.f-vs-o.ffa2.label';'roi.lh.f-vs-o.ffa2.label'};
checkTable = fs_labelinfo(labelList, fs_subjcode(sessList));

% thelabellist = {{'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label', 'roi.lh.f13.f-vs-o.ffa1.label','roi.lh.f13.f-vs-o.ffa2.label'}, ...
%     {'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label', 'roi.rh.f13.f-vs-o.ffa1.label','roi.rh.f13.f-vs-o.ffa2.label'}};
% fs_cvn_print1st(sessList, anaList, thelabellist, ...
%     outPath, 'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', 'ffa', 'annot', 'aparc',...
%     'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors([1 4 5 7]), 'cvnopts', {'overlayalpha', 0.5});
% 
% fs_cvn_print1st(sessList, anaList, thelabellist, ...
%     outPath, 'showinfo', 0, 'waitbar', 1, 'viewpt', 'ffa', 'annot', '',...
%     'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors([1 4 5 7]));

% save the label info (surfcluster)
thelsit = {'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label',...
    'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label'};
[ffaTable, fscmdffa] = fs_surflabel(sessList(3), thelsit, anaList, 1.3, outPath);
fs_fscmd2txt('ffa_HJ.txt', outPath, fscmdffa);


%% %%%%%%%%%%%%%%% VWFA %%%%%%%%%%%%%%%%%
isConti = strcmpi(tableE1.Review, 'contiguous');

subjConti = tableE1.SubjCode(isConti);
labelConti = tableE1.LabelName(isConti);
conConti = cellfun(@fs_2contrast, labelConti, 'uni', false);
hemiConti = cellfun(@fs_2hemi, labelConti, 'uni', false);

conti2Check = unique(table(subjConti, conConti, hemiConti), 'rows');
conti2Check(strcmp(conti2Check.conConti, 'f-vs-o'), :) = [];
conti2Check.SessCode = cellfun(@(x) sprintf('%s_self', x(1:10)), conti2Check.subjConti, 'uni', false); 
conti2Check.Analysis = cellfun(@(x) sprintf('loc_self.%s', x), conti2Check.hemiConti, 'uni', false);
conti2Check.LabelName = cellfun(@(x, y) sprintf('roi.%s.f13.%s.conti.label', x, y),...
    conti2Check.hemiConti, conti2Check.conConti, 'uni', false);

% make roi.lh.f13.?.label 
fscmd = arrayfun(@(x) fs_drawlabel(conti2Check.SessCode(x), conti2Check.Analysis(x), ...
    conti2Check.conConti(x), 1.3, 'conti'), 1, 'uni', false);

[labelMat, cluVtxC] = arrayfun(@(x) fs_trimlabel(conti2Check.LabelName{x}, ...
    conti2Check.SessCode{x}, outPath, 'ncluster', 4, 'lagnvtx', 100, 'lowerthresh', 1), 1, 'uni', false);


% convert roi.lh.f13.w-vs-o.label to roi.lh.w-vs-o.label
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.w-vs-o.label',...
    x, outPath, 'showinfo', 1, 'extraopt1st', {'viewpt', 'ffa'}), sessList, 'uni', false);


% try to make VWFA1/2
fscmd = fs_drawlabel(sessList([3 15]), anaList(1), 'w-vs-o', 1.3, {'vwfa12' }); % , 'vwfa1', 'vwfa2'

% 3 15
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.w-vs-o.vwfa12.label',...
    x, outPath, 'showinfo', 1, 'ncluster', 4, 'lowerthresh', 1), sessList(3), 'uni', false);
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.w-vs-o.vwfa12.label',...
    x, outPath, 'showinfo', 1, 'ncluster', 3, 'lowerthresh', 1), sessList(15), 'uni', false);

% [labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.w-vs-o.vwfa2.label',...
%     x, outPath, 'showinfo', 1, 'ncluster', 2, 'lowerthresh', 1, 'smalleronly', 0, 'extraopt1st', {'viewpt', 'ffa'}), sessList(18), 'uni', false);

% check if the labels are available
labelList = {'roi.lh.w-vs-o.label','roi.lh.w-vs-o.vwfa1.label', 'roi.lh.w-vs-o.vwfa2.label'};
checkTable = fs_labelinfo(labelList, fs_subjcode(sessList));

% % thelabellist = {{'roi.lh.f13.w-vs-o.label', 'roi.lh.w-vs-o.label'}};
% thelabellist = {{'roi.lh.w-vs-o.label','roi.lh.w-vs-o.vwfa1.label', 'roi.lh.w-vs-o.vwfa2.label'}};
% % thelabellist = {{'roi.lh.w-vs-o.label','roi.lh.f13.w-vs-o.vwfa1.label', 'roi.lh.f13.w-vs-o.vwfa2.label'}};
% fs_cvn_print1st(sessList, anaList(1), thelabellist, ...
%     outPath, 'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', 'ffa', 'annot', 'aparc',...
%     'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors([1 4 5]), 'cvnopts', {'overlayalpha', 0.5});
% 
% fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.w-vs-o.label', 'roi.lh.f13.w-vs-o.label'}}, ...
%     outPath, 'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', 'ffa', 'annot', '',...
%     'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors([4 5]));


% save the label info (surfcluster)
[ffaTable, fscmdffa] = fs_surflabel(sessList, 'roi.lh.w-vs-o.label', anaList(1), 1.3, outPath);
fs_fscmd2txt('vwfa_HJ.txt', outPath, fscmdffa);


% overlap between f-vs-o and w-vs-o (lh)
fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'roi.lh.w-vs-o.label'}}, ...
    outPath, 'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', 'ffa', 'annot', '',...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors([1 4 5]));

fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'roi.lh.w-vs-o.label'}}, ...
    outPath, 'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', 'ffa', 'annot', 'aparc',...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors([1 4 5]), 'showinfo', 1, 'cvnopts', {'overlayalpha', 0.5});


%% %%%%%%%%%%%%%%% LOC %%%%%%%%%%%%%%%%%
% rename f13 to f20
a1 = fs_subjcode(sessList);
[tempHemi, tempSub] = ndgrid({'lh', 'rh'}, a1);
sub = tempSub(:);
hemi = tempHemi(:);
isAva = cellfun(@(x, y) ~isempty(fs_readlabel(['roi.' y '.f13.o-vs-scr.label'], x)), sub, hemi);

cellfun(@(x, y) movefile(fullfile(x, 'label', ['roi.' y '.f13.o-vs-scr.label']),...
    fullfile(x, 'label', ['roi.' y '.f20.o-vs-scr.label'])), ...
    sub(isAva), hemi(isAva));

% create f13 labels
fscmd_loc = fs_drawlabel(sessList([2]), anaList(2), 'o-vs-scr', 1.3);

% update labels
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 2, 'reflabel', 'lh.MT.thresh.label', ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), sessList([18]), 'uni', false); % :end

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 4, 'reflabel', 'lh.MT.thresh.label', ...
    'lagnvtx', 50, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), sessList([3 4 8 11 13 17 19]), 'uni', false); % :end

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 8, 'reflabel', 'lh.MT.thresh.label', ...
    'lagnvtx', 5, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), sessList(4), 'uni', false); % :end

% lh
% 2, 50: 8 16 18
% 4, 50: 7 13 15 17
% 5, 25: 6 14 
%
% rh
% 4, 50: 3 8 11 13 1719
% 5, 25: 4


% save the label info (surfcluster)
[loTable, fscmdlo] = fs_surflabel(sessList, {'roi.lh.o-vs-scr.label', 'roi.rh.o-vs-scr.label'}, anaList, 1.3, outPath);
fs_fscmd2txt('lo_HJ.txt', outPath, fscmdlo);

% 
fs_cvn_print1st(sessList, anaList, {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label'}, {'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label'}}, ... , 
    outPath, 'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', -2,...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

fs_cvn_print1st(sessList, anaList, {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label'}}, ... , {'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label'}
    outPath, 'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2,...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);




%% %%%%%%%%%%%%%%%%%%%% update labels with 'maxresp' %%%%%%%%%%%%%%%%%%%%%%

%%%%%%% copy all labels out
fs_cplabel('', pwd, 'roi.*h.w-vs-o.*.label', 'faceword*');

% convert fsaverage lh.

fs_drawlabel(sessList(4), anaList(1), 'w-vs-o', 1.3); 

% FFA1/2
cellfun(@(x) fs_trimlabel('roi.rh.f13.f-vs-o.ffa1.label', x, outPath, ...
    'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.MFS.label'),...
    sessList(1), 'uni', false);

cellfun(@(x) fs_trimlabel('roi.rh.f13.f-vs-o.ffa12.label', x, outPath, ...
    'ncluster', 3, 'reflabel', 'lh.MFS.label', 'lowerthresh', 1, ...
    'method', 'maxresp', 'showinfo', 1, 'peakonly', 0), sessList(7), 'uni', false);

% 54389
cellfun(@(x) fs_trimlabel('roi.lh.f13.f-vs-o.manual.label', x, outPath, ...
    'ncluster', 2, 'lagnvtx', 20,...
    'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.MFS.label'),...
    sessList(16), 'uni', false);

% VWFA
cellfun(@(x) fs_trimlabel('roi.lh.f13.w-vs-o.label', x, outPath, ...
    'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.OTS.label'), ...
    sessList, 'uni', false);

cellfun(@(x) fs_trimlabel('roi.lh.f13.w-vs-o.label', x, outPath, ...
    'ncluster', 3, 'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.OTS.label'), ...
    sessList([15]), 'uni', false); % 15 16 21

% LO
fs_drawlabel(sessList([4 14 15]), anaList(2), 'o-vs-scr', 1.3, 'manual'); 
fs_drawlabel(sessList(10), anaList(1), 'o-vs-scr', 1.3); 


cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.manual.label', x, outPath, ...
    'ncluster', 4, 'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, ...
    'reflabel', 'lh.MT.thresh.label', 'lagnvtx', 20, 'maxiter', 100), ...  
    sessList([14]), 'uni', false);  % 4 11 12 13


%%%%%%%%%%%%% print the labels
labelList = {{'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label','lh.MFS.label'}; 
    {'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label','rh.MFS.label'};
    {'roi.lh.w-vs-o.label', 'lh.OTS.label'}; 
    {'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label'};
    {'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label'};
    {'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label', 'roi.lh.w-vs-o.label','roi.lh.o-vs-scr.label'};
    {'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label', 'roi.rh.o-vs-scr.label'}};

fs_cvn_print1st(sessList, anaList, labelList(4:end), outPath,...  
    'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc', ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'cvnopts', {'overlayalpha', 0.5});

fs_cvn_print1st(sessList, anaList, labelList(6:7), outPath, ... , 
    'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', -2,...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

thelabellist = {'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label',... 
    'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label',...
    'roi.lh.w-vs-o.label', ...
    'roi.lh.o-vs-scr.label', ...
    'roi.rh.o-vs-scr.label'};
[surftable, fscmd] = fs_surflabel(sessList, thelabellist, anaList, 1.3, outPath);
fs_fscmd2txt('0_fscmd_surfcluster.txt', outPath, fscmd);


% overlapping between FFA and VWFA
oTable1 = fs_labeloverlap({{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.w-vs-o.label'};
    {'roi.lh.f-vs-o.ffa2.label', 'roi.lh.w-vs-o.label'}}, fs_subjcode(sessList), outPath);


cellfun(@(x) fs_cplabel('', outPath, x, 'faceword*'), thelabellist, 'uni', false);

gm = fs_labelgm(thelabellist, fs_subjcode(sessList));

thetable = join(surftable, gm, 'Keys', {'SubjCode', 'Label'});

writetable(thetable, fullfile(outPath, 'labelinfo.xlsx'));


%% Try to create VWFA labels with contrast (words vs. the rest)
% run first level analysis with contrast of words vs. rest
% make this contrast for E1
classPairsE1_loc = {'word', {'face', 'object', 'scrambled'}};
runFn = 'run_loc.txt';
condE1 = fs_par2cond(sessList, runFn, 'loc.par');
method = 1;

[anaStruct, fscmd_con] = fs_mkcontrast(anaList, classPairsE1_loc, condE1, method, 1);

% run the first level analysis for this contrast
% remove the other contrasts files from the analysis folders
fscmd_avg = fs_selxavg3('sessid_E1_self', anaList, 0, 2, 1);

% draw labels for VWFA with f13
fs_drawlabel(sessList, anaList(1), 'word-vs-face-object-scrambled', 1.3); 
% fs_drawlabel(sessList(5), anaList(1), 'f-vs-o', 1.3); 

% update labels with maxresp
cellfun(@(x) fs_trimlabel('roi.lh.f13.word-vs-face-object-scrambled.label', x, outPath, ...
    'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.OTS.label'),...
    sessList, 'uni', false);

cellfun(@(x) fs_trimlabel('roi.lh.f13.word-vs-face-object-scrambled.label', x, outPath, ...
    'ncluster', 2, 'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.OTS.label'),...
    sessList([7]), 'uni', false);

% print the screenshots
fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.word-vs-face-object-scrambled.label', 'lh.OTS.label'}}, outPath,...  
    'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc', ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'cvnopts', {'overlayalpha', 0.5});

fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.word-vs-face-object-scrambled.label', 'lh.OTS.label'}}, outPath, ... , 
    'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', -2,...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

% surface label
[surftable, fscmd] = fs_surflabel(sessList, 'roi.lh.word-vs-face-object-scrambled.label', anaList, 1.3, outPath);
fs_fscmd2txt('0_fscmd_surfcluster.txt', outPath, fscmd);

[a1] = fs_labelgm('roi.lh.word-vs-face-object-scrambled.label', fs_subjcode(sessList));

thetable = join(surftable, a1, 'LeftKeys', {'SubjCode', 'Label'}, ...
    'RightKeys', {'SubjCode', 'Label'});

writetable(thetable, fullfile(outPath, 'labelinfo_E1_words_rest.xlsx'));

% comparing w-vs-o and w-vs-rest
fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.word-vs-face-object-scrambled.label', 'roi.lh.w-vs-o.label', 'lh.OTS.label'}}, outPath,...  
    'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc', ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'cvnopts', {'overlayalpha', 0.5});

% comparing w-vs-o and w-vs-rest
fs_cvn_print1st(sessList, anaList(1), {{'roi.lh.word-vs-face-object-scrambled.label', 'roi.lh.w-vs-o.label', 'lh.OTS.label'}}, outPath,...  
    'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', -2, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

%%%%%%% double check some coordinates (for some "other" clusters)
% roi.lh.f13.word-vs-face-object-scrambled.check.label
fs_drawlabel(sessList([16]), anaList(1), 'word-vs-face-object-scrambled', 1.3, 'check');  % 4 6 9 18 % 7 15

cellfun(@(x) fs_trimlabel('roi.lh.f13.word-vs-face-object-scrambled.check.label', x, outPath, ...
    'ncluster', 2, 'method', 'maxresp', 'showinfo', 1, 'peakonly', 0, 'reflabel', 'lh.OTS.label'),...
    sessList([6 7 15 16 18]), 'uni', false); % 4 6 9 18

fs_cvn_print1st(sessList([6 7 15 16 18]), anaList(1), {{'roi.lh.word-vs-face-object-scrambled.check.label', 'roi.lh.w-vs-o.label', 'lh.OTS.label'}}, outPath,...  
    'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', -2, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2); %% 4 6 7 9 15 18

[surftable, fscmd] = fs_surflabel(sessList([6 7 15 16 18]), 'roi.lh.word-vs-face-object-scrambled.check.label', anaList(1), 1.3, outPath);

writetable(surftable, fullfile(outPath, 'labelinfo_E1_words_rest_check.xlsx'));


%% Manually solve issues regarding FFA1/2
% bisect the contiguous FFA1/2 [The overlap will be bisected manually.]

% fscmd1 = fs_label2annot(fs_subjcode(sessList(9)), 'lh', ...
%     {'roi.lh.f-vs-o.ffa1.backup.label', 'roi.lh.f-vs-o.ffa2.backup.label'}, ...
%     'roi.lh.f-vs-o.ffa12.backup.label');
% fs_drawlabel(sessList(9), anaList(1), 'f-vs-o', 1.3);
% fs_drawlabel(sessList([4 7 8]), anaList(2), 'f-vs-o', 1.3);

%%%%% faceword09_self (lh) %%%%%%%
fs_cvn_print1st(sessList{9}, anaList{1}, ...
    {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label'}},...
    outPath, 'viewpt', 3, 'drawroi', 1);
Rmask = drawroipoly(himg,lookup);
fs_mklabel(Rmask, fs_subjcode(sessList(9)), 'roi.lh.f-vs-o.ffa2.bisectoverlap.label');

% cvnlookup(fs_subjcode(sessList(9)),3,Rmask,[0 1],gray);

% the "old" 'roi.lh.f-vs-o.ffa1.label' will be saved as
% 'roi.lh.f-vs-o.ffa1.label.backup.label'
fs_updatelabel('roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.bisectoverlap.label', ...
    fs_subjcode(sessList(9)));
fs_updatelabel('roi.lh.f-vs-o.ffa2.label', 'roi.lh.f-vs-o.ffa2.bisectoverlap.label', ...
    fs_subjcode(sessList(9)), @intersect);
% visualize the results
fs_cvn_print1st(sessList{9}, anaList{1}, ...
    {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'lh.MFS.label'}},...
    outPath, 'visualimg', 0, 'showinfo', 1, 'waitbar', 0, 'annot', 'aparc', ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'cvnopts', {'overlayalpha', 0.5});
fs_cvn_print1st(sessList{9}, anaList{1}, ...
    {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'lh.MFS.label'}},...
    outPath, 'clim', [-5 5], 'subfolder', 2);


%%%%% faceword04_self (rh) %%%%%%%
thisSess = sessList(7); % 4, 7, 8

fs_cvn_print1st(thisSess, anaList{2}, ...
    {{'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label'}}, outPath, ...
    'viewpt', 3, 'drawroi', 1);
Rmask = drawroipoly(himg,lookup);
fs_mklabel(Rmask, fs_subjcode(thisSess), 'roi.rh.f-vs-o.ffa2.bisectoverlap.label');


fs_updatelabel('roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.bisectoverlap.label', ...
    fs_subjcode(thisSess));
fs_trimlabelcluster('roi.rh.f-vs-o.ffa1.label', fs_subjcode(thisSess));
fs_updatelabel('roi.rh.f-vs-o.ffa2.label', 'roi.rh.f-vs-o.ffa2.bisectoverlap.label', ...
    fs_subjcode(thisSess), @intersect);
fs_trimlabelcluster('roi.rh.f-vs-o.ffa2.label', fs_subjcode(thisSess));


fs_cvn_print1st(thisSess, anaList{2}, ...
    {{'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', 'rh.MFS.label'}},...
    outPath, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc', ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'cvnopts', {'overlayalpha', 0.5});
fs_cvn_print1st(thisSess, anaList{2}, ...
    {{'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', 'rh.MFS.label'}},...
    outPath, 'viewpt', -2, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

tst = fs_labeloverlap({{'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label'}}, fs_subjcode(sessList([4 7 8])));
disp(tst);




%% Extra checking (the second best ROI)

% lFFA1
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.f-vs-o.ffa12.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'lh.MFS.label', 'peakonly', 0, ...
    'lagnvtx', 1, 'maxiter', 300, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), sessList(3), 'uni', false); % :end

t = fs_labelinfo('roi.lh.f-vs-o.ffa1.alt.label', fs_subjcode(sessList(3)));

fs_cvn_print1st(sessList(3), anaList(1), ...
    {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'lh.MFS.label', 'roi.lh.f-vs-o.ffa1.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


% lFFA2

% lLO
fs_drawlabel(sessList(2), anaList(1), 'o-vs-scr', 1.3, 'alt');

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.alt.label',...
    x, outPath, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(2), 'uni', false); % :end

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(2)));

fs_cvn_print1st(sessList(2), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

% ---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.label',...
    x, outPath, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(3), 'uni', false); % :end

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(3)));

fs_cvn_print1st(sessList(3), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

% ---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(9), 'uni', false);

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(9)));

fs_cvn_print1st(sessList(9), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


% ---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(12), 'uni', false);

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(12)));

fs_cvn_print1st(sessList(12), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


% ---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.manual.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(13), 'uni', false);

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(13)));

fs_cvn_print1st(sessList(13), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


% ---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.manual.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 20, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(14), 'uni', false);

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(14)));

fs_cvn_print1st(sessList(14), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

% ---
% 17
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 4, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 20, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(16), 'uni', false);

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(16)));

fs_cvn_print1st(sessList(16), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

% ---
% 18
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'lh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 20, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(17), 'uni', false);

t = fs_labelinfo('roi.lh.o-vs-scr.alt.label', fs_subjcode(sessList(17)));

fs_cvn_print1st(sessList(17), anaList(1), ...
    {{'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label', 'roi.lh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


% rLO
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 2, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(19), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(19)));

fs_cvn_print1st(sessList(19), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

%---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 5, 'maxiter', 200, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(6), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(6)));

fs_cvn_print1st(sessList(6), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);

%---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(8), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(8)));

fs_cvn_print1st(sessList(8), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);



%---

[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(14), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(14)));

fs_cvn_print1st(sessList(14), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);



%---
% 16
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(15), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(15)));

fs_cvn_print1st(sessList(15), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


%---
% 17
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(16), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(16)));

fs_cvn_print1st(sessList(16), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


%---
% 18
fs_drawlabel(sessList(17), anaList(2), 'o-vs-scr', 1.3, 'alt');  
[labelMatCell1, clustrVtx1] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.alt.label',...
    x, outPath, 'ncluster', 3, 'reflabel', 'rh.MT.thresh.label', 'peakonly', 0, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(17), 'uni', false); % :end

t = fs_labelinfo('roi.rh.o-vs-scr.alt.label', fs_subjcode(sessList(17)));

fs_cvn_print1st(sessList(17), anaList(2), ...
    {{'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label', 'roi.rh.o-vs-scr.alt.label'}},...
    outPath, 'viewpt', -2, 'visualimg', 0, ...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2);


%% Print the screenshots of the "final" labels


% print
labelListCell = {{'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'lh.MFS.label'};
    {'roi.lh.word-vs-face-object-scrambled.label', 'lh.OTS.label'};
    {'roi.lh.o-vs-scr.label', 'lh.MT.thresh.label'};
    {'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', 'rh.MFS.label'};
    {'roi.rh.o-vs-scr.label', 'rh.MT.thresh.label'};
    {'roi.lh.f-vs-o.ffa1.label', 'roi.lh.f-vs-o.ffa2.label', 'roi.lh.word-vs-face-object-scrambled.label', 'roi.lh.o-vs-scr.label'};
    {'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', 'roi.rh.o-vs-scr.label'}
    }; 

fs_cvn_print1st(sessList, anaList, labelListCell(6:7), ...
    outPath, 'visualimg', 0, 'showinfo', 0, 'waitbar', 1, 'viewpt', -2, 'annot', '',...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors);

fs_cvn_print1st(sessList, anaList, labelListCell(6:7), ...
    outPath, 'visualimg', 0, 'showinfo', 1, 'waitbar', 1, 'viewpt', -2, 'annot', 'aparc',...
    'thresh', 1.3i, 'clim', [-5 5], 'subfolder', 2, 'roicolors', fs_colors,...
    'showinfo', 1, 'cvnopts', {'overlayalpha', 0.5});


% output the csv file
labelList = {
    'roi.lh.f-vs-o.ffa1.label';
    'roi.lh.f-vs-o.ffa2.label';
    'roi.lh.word-vs-face-object-scrambled.label';
    'roi.lh.o-vs-scr.label';
    'roi.rh.f-vs-o.ffa1.label';
    'roi.rh.f-vs-o.ffa2.label';
    'roi.rh.o-vs-scr.label'
    };

labelInfo = fs_labelinfo(labelList, fs_subjcode(sessList), 'bycluster', 1);
writetable(labelInfo, fullfile('~', 'Desktop', 'faceword_E1_Label_HJ.csv'));


%% LOC 150, 200, 300mm^2

% lh: 100, 150, 200, 300
[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.label',...
    x, outPath, 'reflabel', 'roi.lh.o-vs-scr.label', 'peakonly', 0, ...
    'gmfn', 'roi.lh.o-vs-scr.gm', 'maxsize', 300, 'savesize', 1, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList([1,3:end]), 'uni', false); % :8, 10:13, 15, 17,18, 20

[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.lh.f13.o-vs-scr.alt.label',...
    x, outPath, 'reflabel', 'roi.lh.o-vs-scr.label', 'peakonly', 0, ...
    'gmfn', 'roi.lh.o-vs-scr.gm', 'maxsize', 150, 'savesize', 1, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList(2), 'uni', false); % :end

% rh: 100, 150, 200, 300
[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.rh.f13.o-vs-scr.label',...
    x, outPath, 'reflabel', 'roi.rh.o-vs-scr.label', 'peakonly', 0, ...
    'gmfn', 'roi.rh.o-vs-scr.gm', 'maxsize', 300, 'savesize', 1, ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList([1:end]), 'uni', false); % :8, 10:13, 15, 17,18, 20

% % double check FFA1/2, VWFA
% cellfun(@(x) fs_trimlabel('roi.rh.f13.f-vs-o.ffa12.label',...
%     x, outPath, 'reflabel', 'roi.rh.f-vs-o.ffa1.label', 'peakonly', 0, ...
%     'gmfn', 'roi.rh.f-vs-o.ffa1.gm', 'maxsize', 100, 'savesize', 1, ...
%     'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
%     sessList([1:end]), 'uni', false); % :8, 10:13, 15, 17,18, 20

% print LO label info
labelList_LO = {
    'roi.lh.o-vs-scr.label';
    'roi.lh.o-vs-scr.a100.label';
    'roi.lh.o-vs-scr.a150.label';
    'roi.lh.o-vs-scr.a200.label';
    'roi.lh.o-vs-scr.a300.label';
    'roi.rh.o-vs-scr.label';
    'roi.rh.o-vs-scr.a100.label';
    'roi.rh.o-vs-scr.a150.label';
    'roi.rh.o-vs-scr.a200.label';
    'roi.rh.o-vs-scr.a300.label';
    };

labelInfo_LO = fs_labelinfo(labelList_LO, fs_subjcode(sessList), 'bycluster', 1);
writetable(labelInfo_LO, fullfile('~', 'Desktop', 'faceword_E1_Label_LO_HJ.csv'));

%% double check FFA1/2 VWFA

% backup the FFA1/2 and VWFA lables
% fs_cplabel('', fullfile('~', 'Desktop', 'labelbackup'), 'roi*');

[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.rh.f13.f-vs-o.ffa12.label',...
    x, outPath, 'reflabel', 'roi.rh.f-vs-o.ffa1.label', 'peakonly', 0, ...
    'gmfn', 'roi.rh.f-vs-o.ffa1.gm', 'maxsize', 100, 'savesize', 0, ...'method', 'concentric', ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList([15]), 'uni', false); % 15 ffa1 rh; 

over = fs_labeloverlap({{'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label'}}, fs_subjcode(sessList(15)), outPath);
fs_updatelabel('roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', fs_subjcode(sessList(15)), '', 1, 1);
fs_updatelabel('roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', fs_subjcode(sessList(15)), '', 1, 2);


[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.rh.f13.f-vs-o.ffa12.label',...
    x, outPath, 'reflabel', 'roi.rh.f-vs-o.ffa1.label', 'peakonly', 0, ...
    'gmfn', 'roi.rh.f-vs-o.ffa1.gm', 'maxsize', 100, 'savesize', 0, ...'method', 'concentric', ...
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList([3]), 'uni', false); % 3 ffa1 rh; 
over = fs_labeloverlap({{'roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label'}}, fs_subjcode(sessList(3)), outPath);
fs_updatelabel('roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', fs_subjcode(sessList(3)), '', 1, 1);
fs_updatelabel('roi.rh.f-vs-o.ffa1.label', 'roi.rh.f-vs-o.ffa2.label', fs_subjcode(sessList(3)), '', 1, 2);


[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.rh.f13.f-vs-o.ffa12.label',...
    x, outPath, 'reflabel', 'roi.rh.f-vs-o.ffa2.label', 'peakonly', 0, 'ncluster', 3, ...
    'gmfn', 'roi.rh.f-vs-o.ffa2.gm', 'maxsize', 100, 'savesize', 0, ... 'method', 'concentric', ...  
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList([12]), 'uni', false); % 12 ffa2 rh; 


[labelMatCell150, clustrVtx150] = cellfun(@(x) fs_trimlabel('roi.lh.f13.word-vs-face-object-scrambled.label',...
    x, outPath, 'reflabel', 'roi.lh.word-vs-face-object-scrambled.label', 'peakonly', 0, 'ncluster', 3, ...
    'gmfn', 'roi.lh.word-vs-face-object-scrambled.gm', 'maxsize', 100, 'savesize', 0, ... 'method', 'concentric', ...  
    'lagnvtx', 10, 'maxiter', 100, 'showinfo', 1, 'extraopt1st', { 'cvnopts', {'overlayalpha', 0.5'}}), ...
    sessList, 'uni', false); % 12 ffa2 rh; 

%% Make plots for representative ROIs in manuscript

labelList = {
    {'roi.lh.f-vs-o.ffa1.label','roi.lh.f-vs-o.ffa2.label', 'roi.lh.word-vs-face-object-scrambled.label','roi.lh.o-vs-scr.label'};
    {'roi.rh.f-vs-o.ffa1.label','roi.rh.f-vs-o.ffa2.label', 'roi.rh.o-vs-scr.label'}};


opts = {'visualimg', 0, 'viewpt', {[-40, -45, -40]}, ...
    'dispsig', 0, 'subfolder', 2, 'imgext', 'pdf', 'dispcolorbar', 0, ...
    'roiwidth', 1, 'cvnopts', {'rgbnan', 1}};
cellfun(@(x) fs_cvn_printlabel({labelList(1)}, x, 0, outPath, 1, opts), ...
    sessList([4, 5, 18]), 'uni', false);
opts = {'visualimg', 0, 'viewpt', {[40, -45, 40]}, ...
    'dispsig', 0, 'subfolder', 2, 'imgext', 'pdf', 'dispcolorbar', 0, ...
    'roiwidth', 1, 'roicolors', fs_colors([1, 2, 4]), 'cvnopts', {'rgbnan', 1}};
cellfun(@(x) fs_cvn_printlabel({labelList(2)}, x, 0, outPath, 1, opts), ...
    sessList([4, 5, 18]), 'uni', false);




