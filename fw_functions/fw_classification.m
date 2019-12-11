function [mvpaTable, uniTable, uniLocTable] = fw_classification(labelList, classifiers, runLoc, output_path)
% This function reads data from FreeSurfer and use CoSMoMVPA perform leave
% one out classifcation. The data for univariate analyses also could be
% obtained.
%
% Inputs: 
%    labelNames         label names for all ROIs
%    classifiers        classifiers provided by CoSMoMVPA
%    runLoc             (logical) run localizer
%    outputFolder        the folder where the output data will be saved
% Outputs:
%    mvpaTable          the yes or no data from classfication
%    uniTable           data for univariate analyses
%    uniLocTable        data of localizer for univarite analyses
%
% Created by Haiyang Jin (9/12/2019)

nLabel = numel(labelList);
if nargin < 2 || isempty(classifiers)
    [classifiers, class_names, nClass] = fs_cosmo_classifier; % {@cosmo_classify_libsvm}
else
    [classifiers, class_names, nClass] = fs_cosmo_classifier(classifiers);
end

if nargin < 3 || isempty(runLoc)
    runLoc = 0;
end

if nargin < 4 || isempty(output_path)
    output_path = fullfile('.');
end
output_path = fullfile(output_path, 'Classification');
if ~exist(output_path, 'dir'); mkdir(output_path); end

% define the pairs for classification
classifyPairs_E1 = {'face_intact', 'word_intact';
    'face_intact', 'face_exchange';
    'word_intact', 'word_exchange';
    'face_top', 'face_bottom';
    'word_top', 'word_bottom';
    };

classifyPairs_E2 = {'Chinese_intact', 'English_intact';
    'Chinese_intact', 'Chinese_exchange';
    'Chinese_top', 'Chinese_bottom';
    'English_intact', 'English_exchange';
    'English_top', 'English_bottom'};
classExps = {classifyPairs_E1, classifyPairs_E2};


%% Preparation
% Set the paths for beta files and the labels
FW = fw_projectinfo('self');
subjPath = FW.subjects;
fmriPath = FW.fMRI;
subjList = FW.subjList;
nSubj = FW.nSubj;

% CoSMoMVPA
measure = @cosmo_crossvalidation_measure;  % function handle
args.output = 'fold_predictions';


%% Run the analysis 
wait_f = waitbar(0, '0.00% finished');

% Pre-define the table for saving (accuracy) data
uniTable = table;
mvpaTable = table;
uniLocTable = table;

% for each label
for iLabel = 1:nLabel
    
    thisLabelName = labelList{iLabel};
    
    hemi = fs_hemi(thisLabelName);
    
    % Run the analysis for each subject separately
    for iSubj = 1:nSubj
        
        expCode = ceil(iSubj/(nSubj/2));
        
        thisSubj = subjList{iSubj};  % this subject name (functional)
        subjCode = fs_subjcode(thisSubj, projStr.fMRI); % the subject code in SUBJECTS_DIR
        
        % the lable file (mask)
        thisLabelFile = fullfile(subjPath, subjCode, 'label', thisLabelName);
        
        if ~exist(thisLabelFile, 'file')
            warning('There is no label file (%s) for Subject %s.', thisLabelName, thisSubj); 
            continue % go to next loop (skip this subject)
        end
        
        % converting the label file to logical matrix
        [dtMatrix, nVertex] = fs_readlabel(thisLabelFile);
        vtxROI = dtMatrix(:, 1);
        
        % path to bold files
        boldPath = fullfile(fmriPath, thisSubj, 'bold/');
        
         % calculate the size of this label file
        locBetaFile = fullfile(boldPath, ['loc_self.' hemi], 'beta.nii.gz');
        [labelsize, talCoor] = fw_labelsize(thisSubj, thisLabelFile, locBetaFile);
                
        % Obtain the run (folder) names
        if runLoc
            runFile = 'run_loc.txt';
            parFile = 'loc.par';
        else
            runFile = 'run_Main.txt'; 
            parFile = 'main.par';
        end
        
        % read the run file
        [runNames, nRun] = fs_readrun(fullfile(boldPath, runFile));
        
        if runLoc
            
            analysisName = ['loc_self.', hemi];
            thisAnalysisFolder = fullfile(boldPath, analysisName);
            thisBoldFilename = fullfile(thisAnalysisFolder, 'beta.nii.gz'); % the functional data file
            
            % load paradigm file
            file_par = fullfile(boldPath, runNames{1}, parFile);
            parInfo = fs_readpar(file_par);

            % load the nifti from FreeSurfer
            dt_all = fs_cosmo_surface(thisBoldFilename, ...
                'targets', parInfo.Condition,...
                'labels', parInfo.Label); % cosmo_fmri_fs_dataset(thisBoldFilename); % with the whole brain
            
            % apply the mask
            roiMask = zeros(1, size(dt_all.samples, 2));
            roiMask(vtxROI) = 1; 
            this_dt = cosmo_slice(dt_all, logical(roiMask), 2); % apply the roi mask to the whole dataset
            
            % saving data
            nRowLocUni = size(this_dt.samples, 1);
        
            this_loc_table = table;
            this_loc_table.ExpCode = repmat(expCode, nRowLocUni, 1);
            this_loc_table.Label = repmat({thisLabelName}, nRowLocUni, 1);
            this_loc_table.nVertices = repmat(nVertex, nRowLocUni, 1);
            this_loc_table.LabelSize = repmat(labelsize, nRowLocUni, 1);
            this_loc_table.TalCoordinate = repmat(talCoor, nRowLocUni, 1);
            this_loc_table.SubjCode = repmat({thisSubj}, nRowLocUni, 1);
            
            this_loc_table = [this_loc_table, fs_cosmo_univariate(this_dt)]; %#ok<AGROW>
            
            uniLocTable = [uniLocTable; this_loc_table]; %#ok<AGROW>
            continue
            
        end
        
        % Pre-define the cell array for saving ds
        ds_cell = cell(1, nRun); 
        
        for iRun = 1:nRun
            
            % the bold file
            analysisName = ['main_sm0_self', num2str(iRun), '.', hemi];
            thisBoldFilename = fullfile(boldPath, analysisName, 'beta.nii.gz'); %%% here (the functional data file)
            
            % load paradigm file
            file_par = fullfile(boldPath, runNames{iRun}, parFile);
            parInfo = fs_readpar(file_par);
            
            % load the nifti from FreeSurfer
            dt_all = fs_cosmo_surface(thisBoldFilename, ...
                'targets', parInfo.Condition,...
                'labels', parInfo.Label, ...
                'chunks', iRun); % cosmo_fmri_fs_dataset(thisBoldFilename); % with the whole brain
            
            % apply the mask
            roiMask = zeros(1, size(dt_all.samples, 2));
            roiMask(vtxROI) = 1; 
            this_dt = cosmo_slice(dt_all, logical(roiMask), 2); % apply the roi mask to the whole dataset
            
            % save the dt in a cell for further stacking
            ds_cell(1, iRun) = {this_dt};
            
        end
        
        % stack multiple ds.sample
        ds_subj = cosmo_stack(ds_cell,1);
        
        %% Convert the ds_subj to ds for univariate analysis
        nRowUni = size(ds_subj.samples, 1);
        
        this_uni_table = table;
        this_uni_table.ExpCode = repmat(expCode, nRowUni, 1);
        this_uni_table.Label = repmat({thisLabelName}, nRowUni, 1);
        this_uni_table.nVertices = repmat(nVertex, nRowUni, 1);
        this_uni_table.LabelSize = repmat(labelsize, nRowUni, 1);
        this_uni_table.TalCoordinate = repmat(talCoor, nRowUni, 1);
        this_uni_table.SubjCode = repmat({thisSubj}, nRowUni, 1);
        
        this_uni_table = [this_uni_table, fs_cosmo_univariate(ds_subj)];  %#ok<AGROW>

        uniTable = [uniTable; this_uni_table];  %#ok<AGROW>

        
        %% Run MVPA with CoSMoMVPA
        %     % remove constant features
        %     ds=cosmo_remove_useless_data(ds);
        

        % comparisons 
        classifyPairs = classExps{expCode};
        nPairs = size(classifyPairs, 1);
        
        % Run analysis for each pair
        for iPair = 1:nPairs
            
            % define this classification and its mask
            thisPair = classifyPairs(iPair, :);
            thisPairMask = cosmo_match(ds_subj.sa.labels, thisPair);
            
            % dataset for this classification
            ds_thisPair = cosmo_slice(ds_subj, thisPairMask);
            
            % set the partitions for this dataset
            args.partitions = cosmo_nfold_partitioner(ds_thisPair); % leave 1 out
            
            % for analysis with each classifier
            tmpoutput = table;
            for iClass = 1:nClass
                
                % the classifier for this analysis
                args.classifier = classifiers{iClass};
                thisClassfifier = class_names{iClass};
                
                predicted_ds = measure(ds_thisPair, args);
                
                % calculate the confusion matrix
                thisConMatrix = cosmo_confusion_matrix(predicted_ds);
                
                % calculate and display the accuracy
                accuracy = mean(predicted_ds.sa.targets == predicted_ds.samples);
                desc=sprintf('%s: accuracy %.1f%%', thisClassfifier, accuracy*100);
                fprintf('%s\n',desc);
                
                % save the results
                nRowTemp = numel(predicted_ds.sa.targets);
                
                tmpoutput.ExpCode = repmat(expCode, nRowTemp, 1);
                tmpoutput.Label = repmat({thisLabelName}, nRowTemp, 1);
                tmpoutput.nVertices = repmat(nVertex, nRowTemp, 1);
                tmpoutput.LabelSize = repmat(labelsize, nRowTemp, 1);
                tmpoutput.TalCoordinate = repmat(talCoor, nRowTemp, 1);
                tmpoutput.SubjCode = repmat({thisSubj}, nRowTemp, 1);
                
                tmpoutput.ClassifyPair = repmat({[thisPair{1}, '-', thisPair{2}]}, nRowTemp, 1);
                tmpoutput.Classifier = repmat(thisClassfifier, nRowTemp, 1);
                
                tmpoutput.Run = predicted_ds.sa.folds;
                tmpoutput.Predicted = predicted_ds.samples;
                tmpoutput.Targets = predicted_ds.sa.targets;
                tmpoutput.ACC = predicted_ds.samples == predicted_ds.sa.targets;
                
                tmpoutput.Confusion = repmat({thisConMatrix}, nRowTemp, 1);

            end
            
            mvpaTable = [mvpaTable; tmpoutput]; %#ok<AGROW>
            
        end
        
        % add wait bar
        progress = ((iLabel-1)*nSubj + iSubj) / (nLabel * nSubj);
        progress_msg = sprintf('Label: %s.  Subject: %s \n%0.2f%% finished...', ...
            thisLabelName, thisSubj, progress*100);
        waitbar(progress, wait_f, progress_msg);
        
    end
    
end

close(wait_f); % close the waitbar 

if runLoc
    fn_locuni = fullfile(output_path, 'FaceWord_Loc_Univariate');
    save(fn_locuni, 'uniLocTable');
    writetable(uniLocTable, [fn_locuni, '.xlsx']);
    writetable(uniLocTable, [fn_locuni, '.csv']);
end

% save the output results
fn_cosmo = fullfile(output_path, 'FaceWord_CosmoMVPA');
save(fn_cosmo, 'mvpaTable');
mvpaTable(:, 'Confusion') = [];
writetable(mvpaTable, [fn_cosmo, '.xlsx']);
writetable(mvpaTable, [fn_cosmo, '.csv']);

fn_uni = fullfile(output_path, 'FaceWord_Univariate');
save(fn_uni, 'uniTable');
writetable(uniTable, [fn_uni, '.xlsx']);
writetable(uniTable, [fn_uni, '.csv']);


end