%% Input
labelNames = { % ...
    'roi.lh.f13.f-vs-o.ffa1.label', ...
    'roi.lh.f20.f-vs-o.ffa1.label', ...
    'roi.lh.f13.f-vs-o.ffa2.label',...
    'roi.lh.f13.w-vs-o.label', ...
    'roi.lh.f13.f-vs-o.label', ...
    'roi.lh.f20.f-vs-o.label', ...
    'roi.lh.f40.f-vs-o.label',...
    'roi.rh.f13.f-vs-o.ffa1.label', ...
    'roi.rh.f13.f-vs-o.ffa2.label',...
    'roi.rh.f20.f-vs-o.ffa2.label',...
    'roi.rh.f40.f-vs-o.ffa2.label', ...
    'roi.rh.f13.f-vs-o.label',...
    'roi.rh.f20.f-vs-o.label', ...
    'roi.rh.f40.f-vs-o.label'};
% labelNames = {'roi.rh.f20.f-vs-o.label'};
runClassifiers = 1; % 1:nclassifiers
% 1-libsvm; 2-nn; 3-naive bayes; 4-lda; 5-svm(matlab)
runLoc = 0; % run analysis for localizer

%% Preparation
% Set the paths for beta files and the labels
FS = fs_setup;
subjPath = FS.subjects;
fmriPath = fullfile(subjPath, '..', 'Data_fMRI/');

subjDir = dir(fullfile(fmriPath, 'faceword*_self'));
nSubj = numel(subjDir);
nLabel = numel(labelNames);

% pre-define info for CosMoMVPA
% classifiers
classifiers = {@cosmo_classify_libsvm, ...
    @cosmo_classify_nn, ...
    @cosmo_classify_naive_bayes,...
    @cosmo_classify_lda, ...
    @cosmo_classify_svm};

nclassifiers=numel(classifiers);
classifier_names=cellfun(@func2str,classifiers,'UniformOutput',false);

fprintf('\n\nUsing %d classifiers: %s\n', length(runClassifiers), ...
    cosmo_strjoin(classifier_names(runClassifiers), ', '));

measure = @cosmo_crossvalidation_measure;  % function handle
args.output = 'fold_predictions';

% Pre-define the table for saving (accuracy) data
uniTable = table;
outputTable = table;
if runLoc; uniLocTable = table; end

%% Run the analysis 
wait_f = waitbar(0, '0.00% finished');

% for each ROIs (labels)
for iLabel = 1:nLabel
    
    thisLabelName = labelNames{iLabel};
    
    hemi = fs_hemi(thisLabelName);
    
    % Run the analysis for each subject separately
    for iSubj = 1:nSubj
        
        expCode = ceil(iSubj/(nSubj/2));
        
        thisSubj = subjDir(iSubj).name;  % this subject name (functional)
        subjCode = fw_subjcode(thisSubj); % the subject code in SUBJECTS_DIR
        
        % the lable file (mask)
        thisLabelFile = fullfile(subjPath, subjCode, 'label', thisLabelName);
        
        if ~exist(thisLabelFile, 'file')
            warning('There is no label file (%s) for Subject %s.', thisLabelName, thisSubj); 
            continue % go to next loop (skip this subject)
        end
        
        % converting the label file to logical matrix
        [dtMatrix, nVertex] = fs_label2mat(thisLabelFile);
        vertexROI = dtMatrix(:,1);
        
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
        
        runList = importdata(fullfile(boldPath, runFile))';
        runNames = arrayfun(@(x) sprintf('%03d', x), runList, 'UniformOutput', false);
        nRun = numel(runList);
        
        if runLoc
            
            analysisName = ['loc_self.', hemi];
            thisAnalysisFolder = fullfile(boldPath, analysisName);
            thisBoldFilename = fullfile(thisAnalysisFolder, 'beta.nii.gz'); % the functional data file
            
            % load paradigm file
            thisRunFolder = fullfile(boldPath, runNames{1});
            parFileDir = dir(fullfile(thisRunFolder, parFile));
            parInfo = fs_readpar(fullfile(parFileDir.folder, parFileDir.name));

            % load the nifti from FreeSurfer
            dt_all = cosmo_fmri_fs_dataset(thisBoldFilename); % with the whole brain
            dt_all.samples = dt_all.samples(1 : size(parInfo, 1), :);
            
            % apply the mask
            roiMask = zeros(1, size(dt_all.samples, 2));
            roiMask(vertexROI) = 1; 
            this_dt = cosmo_slice(dt_all, logical(roiMask), 2); % apply the roi mask to the whole dataset
            
            % add attributes
            this_dt.sa.targets = parInfo.Condition;
            this_dt.sa.labels = parInfo.Label;
            
            nRowLocUni = size(this_dt.samples, 1);
        
            this_loc_table = table;
            this_loc_table.ExpCode = repmat(expCode, nRowLocUni, 1);
            this_loc_table.ROI = repmat({thisLabelName}, nRowLocUni, 1);
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
            [parInfo, nCon] = fs_readpar(fullfile(boldPath, runNames{iRun}, parFile));
            
            % load the nifti from FreeSurfer
            dt_all = cosmo_fmri_fs_dataset(thisBoldFilename); % with the whole brain
            dt_all.samples = dt_all.samples(1:nCon, :);
            
            % apply the mask
            roiMask = zeros(1, size(dt_all.samples, 2));
            roiMask(vertexROI) = 1; 
            this_dt = cosmo_slice(dt_all, logical(roiMask), 2); % apply the roi mask to the whole dataset
            
            % add attributes
            this_dt.sa.targets = parInfo.Condition;
            this_dt.sa.labels = parInfo.Label;
            this_dt.sa.chunks = repmat(iRun, nCon, 1);
            
            % save the dt in a cell for further stacking
            ds_cell(1, iRun) = {this_dt};
            
        end
        
        % stack multiple ds.sample
        ds_subj = cosmo_stack(ds_cell,1);
        
        %% Convert the ds_subj to ds for univariate analysis
        nRowUni = size(ds_subj.samples, 1);
        
        this_uni_table = table;
        this_uni_table.ExpCode = repmat(expCode, nRowUni, 1);
        this_uni_table.ROI = repmat({thisLabelName}, nRowUni, 1);
        this_uni_table.nVertices = repmat(nVertex, nRowUni, 1);
        this_uni_table.LabelSize = repmat(labelsize, nRowUni, 1);
        this_uni_table.TalCoordinate = repmat(talCoor, nRowUni, 1);
        this_uni_table.SubjCode = repmat({thisSubj}, nRowUni, 1);
        
        this_uni_table = [this_uni_table, fs_cosmo_univariate(ds_subj)];  %#ok<AGROW>

        uniTable = [uniTable; this_uni_table];  %#ok<AGROW>

        
        %% Run MVPA with CoSMoMVPA
        %     % remove constant features
        %     ds=cosmo_remove_useless_data(ds);
        
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
            for iClass = runClassifiers
                
                % the classifier for this analysis
                args.classifier = classifiers{iClass};
                thisClassfifier = classifier_names{iClass};
                
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
                tmpoutput.ROI = repmat({thisLabelName}, nRowTemp, 1);
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
            
            outputTable = [outputTable; tmpoutput]; %#ok<AGROW>
            
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
    fn_locuni = fullfile('~', 'Desktop', 'FaceWord_Loc_Univariate');
    save(fn_locuni, 'uniLocTable');
    writetable(uniLocTable, [fn_locuni, '.xlsx']);
    writetable(uniLocTable, [fn_locuni, '.csv']);
else
    % save the output results
    fn_cosmo = fullfile('~', 'Desktop', 'FaceWord_CosmoMVPA');
    save(fn_cosmo, 'outputTable');
    outputTable(:, 'Confusion') = [];
    writetable(outputTable, [fn_cosmo, '.xlsx']);
    writetable(outputTable, [fn_cosmo, '.csv']);
    
    fn_uni = fullfile('~', 'Desktop', 'FaceWord_Univariate');
    save(fn_uni, 'uniTable');
    writetable(uniTable, [fn_uni, '.xlsx']);
    writetable(uniTable, [fn_uni, '.csv']);
end

% %% Test
% boldfiledir = fullfile(boldPath, 'main_sm0_self1.rh', 'beta.nii.gz');
% ds_test = cosmo_fmri_dataset(boldfiledir);
% ds_test = cosmo_fmri_fs_dataset(boldfiledir);
% 
% cosmo_disp(ds_test);
% 
% 
% dd_test = MRIread(boldfiledir);
%  
% cosmo_surface_dataset(boldfiledir);
% 
% tt = load_nifti(boldfiledir);
% tuntouch = load_untouch_nii(boldfiledir);


