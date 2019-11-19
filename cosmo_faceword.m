%% Input
labelNames = {'roi.rh.f20.f-vs-o.label'};
runClassifiers = 1; % 1:nclassifiers
% 1-libsvm; 2-nn; 3-naive bayes; 4-lda; 5-svm(matlab)

%% Preparation
% Set the paths for beta files and the labels
studyPath = fullfile('/Volumes/Atlantic/research/fMRI/faceword/freesurfer/');
fmriPath = fullfile(studyPath, 'Data_fMRI/');
mriPath = fullfile(studyPath, 'subjects/');

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

%% Run the analysis 

% for each ROIs (labels)
for iLabel = 1:nLabel
    
    thisLabelName = labelNames{iLabel};
    
    hemi = fs_hemi(thisLabelName);
    
    % Run the analysis for each subject separately
    for iSubj = [1:5, 7:nSubj] % 1:nSubj
        
        expCode = ceil(iSubj/(nSubj/2));
        
        % this subject name (functional)
        thisSubj = subjDir(iSubj).name;
        subjCodeFile = dir(fullfile(subjDir(iSubj).folder, subjDir(iSubj).name, 'subjectname'));
        [~, subjCode] = system(['cat ', fullfile(subjCodeFile.folder, subjCodeFile.name)]);
        subjNameSplit = strsplit(subjCode, '_');
        
        % the lable file (mask)
        labelFolder = erase(thisSubj, '_self');
        thisLabelPath = dir(fullfile(mriPath, [labelFolder '*'], 'label', thisLabelName));
        
        if isempty(thisLabelPath)
            warning('There is no label file (%s) for Subject %s.', thisLabelName, thisSubj); 
            continue % go to next loop (skip this subject)
        end
        
        thisLabelFile = fullfile(thisLabelPath.folder, thisLabelPath.name);
        
        % converting the label file to logical matrix
        labelMatrix = importdata(thisLabelFile, ' ', 2); % read the label file
        vertexROI = labelMatrix.data(:,1);
        nVertex = str2double(labelMatrix.textdata{2}); % number of vertices
        
        % path to bold files
        boldPath = fullfile(fmriPath, thisSubj, 'bold/');
        
         % calculate the size of this label file
        locBetaFile = fullfile(boldPath, ['loc_self.' hemi], 'beta.nii.gz');
        labelsize = fs_labelsize(thisSubj, thisLabelFile, locBetaFile);
                
        % Obtain the run (folder) names
        runList = importdata(fullfile(boldPath, 'run_Main.txt'))';
        runNames = arrayfun(@(x) sprintf('%03d', x), runList, 'UniformOutput', false);
        nRun = numel(runList);
        
        % Pre-define the cell array for saving ds
        ds_cell = cell(1, nRun);
        
        for iRun = 1:nRun
            
            % the bold file
            analysisName = ['main_sm0_self', num2str(iRun), '.', hemi];
            thisAnalysisFolder = fullfile(boldPath, analysisName);
            thisBoldFilename = fullfile(thisAnalysisFolder, 'beta.nii.gz'); %%% here (the functional data file)
            
            % load the nifti from FreeSurfer
            dt_all = cosmo_fmri_fs_dataset(thisBoldFilename); % with the whole brain
            
            % apply the mask
            roiMask = zeros(1, size(dt_all.samples, 2));
            roiMask(vertexROI) = 1; 
            this_dt = cosmo_slice(dt_all, logical(roiMask), 2); % apply the roi mask to the whole dataset
            
            % add attributes
            thisRunFolder = fullfile(boldPath, runNames{iRun});
            parFileDir = dir(fullfile(thisRunFolder, 'main.par'));
            parInfo = fs_readpar(fullfile(parFileDir.folder, parFileDir.name));
            
            this_dt.sa.targets = parInfo.Condition;
            this_dt.sa.labels = parInfo.Label;
            this_dt.sa.chunks = repmat(iRun, size(parInfo, 1), 1);
            
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
        this_uni_table.SubjCode = repmat({thisSubj}, nRowUni, 1);
        
        this_uni_table = [this_uni_table, fs_cosmo_univariate(ds_subj)]; %#ok<AGROW>

        uniTable = [uniTable; this_uni_table]; %#ok<AGROW>

        
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
            
            % define this classification
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
        
    end
    
end

% save the output results
fn_cosmo = fullfile('~', 'Desktop', 'FaceWord_Cosmo');
save(fn_cosmo, 'outputTable');
outputTable(:, 'Confusion') = [];
writetable(outputTable, [fn_cosmo, '.xlsx']);
writetable(outputTable, [fn_cosmo, '.csv']);

fn_uni = fullfile('~', 'Desktop', 'FaceWord_Uni');
save(fn_uni, 'uniTable');
writetable(uniTable, [fn_uni, '.xlsx']);
writetable(uniTable, [fn_uni, '.csv']);

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


