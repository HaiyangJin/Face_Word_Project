function faceword_searchlight(subjCode_bold, expCode, isLR, classifier)
% This function does the searchlight analyses for the faceword project
% with CoSMoMVPA. Data were analyzed with FreeSurfer.
%
% Created by Haiyang (24/11/2019)

% subjCode_bold = 'faceword01_self';
% expCode = 1;
% classPair = {'face_intact', 'word_intact'};

cosmo_warning('once');

if nargin < 3 || isempty(isLR)
    isLR = 0;
end
if nargin < 4 || isempty(classifier)
    classifier = @cosmo_classify_libsvm;
end


%% Preparation
FS = fs_setup;
fMRIPath = fullfile(FS.subjects, '..', 'Data_fMRI');

% check if there is the functional subject folder
subjPathBold = fullfile(fMRIPath, subjCode_bold);
if ~exist(subjPathBold, 'dir')
    error('Cannot find %s in the functional folder (%s).', subjCode_bold, fMRIPath);
end

% check if there is surface folder
subjCode = fw_subjcode(subjCode_bold); % subjCode in SUBJECTS_DIR
subjPath = fullfile(FS.subjects, subjCode);
if ~exist(subjPath, 'dir')
    error('Cannot find %s in FreeSurfer subject folder (SUBJECTS_DIR).', subjCode);
end


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


%% Convert surface files (white, pial, and inflated) to ASCII if necessary
surfPath = fullfile(subjPath, 'surf');

surfExt = {'white', 'pial', 'inflated'};
hemis = {'lh', 'rh'};
[~, i_white] = ismember('white', surfExt);
[~, i_pial] = ismember('pial', surfExt);
[~, i_inf] = ismember('inflated', surfExt);

nSurfExt = numel(surfExt);
nHemi = numel(hemis);

% Create a cell for saving ASCII filenames for both hemisphere
ascFileCell = cell(nSurfExt, nHemi);
vCell = cell(nSurfExt, nHemi+1); % left, right, and merged
fCell = cell(nSurfExt, nHemi+1); % left, right, and merged

% Convert surface file to ASCII (with functions in FreeSurfer)
for iSurfExt = 1:nSurfExt
    
    for iHemi = 1:nHemi
        
        % the surface and its asc filename
        thisSurfFile = [hemis{iHemi} '.' surfExt{iSurfExt}];
        thisASC = [thisSurfFile '.asc'];
        
        thisSurfPath = fullfile(surfPath, thisSurfFile);
        thisASCPath = fullfile(surfPath, thisASC);
        
        if ~exist(thisASCPath, 'file')
            % convert the surface file to ASCII file
            asc_fscommand = sprintf('mris_convert %s %s', thisSurfPath, thisASCPath);
            system(asc_fscommand);
        end
        
        % save the filename in the cell
        ascFileCell(iSurfExt, iHemi) = {thisASCPath};
        
        [vCell{iSurfExt, iHemi}, fCell{iSurfExt, iHemi}] = surfing_read(thisASCPath);
    end
    
    % Combine ASCII for two hemispheres together (with the order lh, rh)
    [vCell{iSurfExt, 3}, fCell{iSurfExt, 3}] = merge_surfaces(ascFileCell(iSurfExt, :));
    
end


%% Load functional data
% the path to the bold folder
boldPath = fullfile(fMRIPath, subjCode_bold, 'bold');

% obtain the run names
runList = importdata(fullfile(boldPath, 'run_Main.txt'))';
runNames = arrayfun(@(x) sprintf('%03d', x), runList, 'UniformOutput', false);
nRun = numel(runList);

% Pre-define the cell array for saving ds 
ds_cell = cell(nRun, nHemi + isLR); 

% load functional data for each run separately
for iRun = 1:nRun
    
    % load data for each hemisphere separately (and combined later)
    nVertices = 0;
    for iHemi = 1:nHemi
        % the bold file
        analysisName = ['main_sm0_self', num2str(iRun), '.', hemis{iHemi}];
        thisBoldFilename = fullfile(boldPath, analysisName, 'beta.nii.gz'); %%% here (the functional data file)
        
        % load paradigm file
        parFileDir = fullfile(boldPath, runNames{iRun}, 'main.par');
        parInfo = fs_readpar(parFileDir);
        
        % load the nifti from FreeSurfer
        this_ds = cosmo_fmri_fs_dataset(thisBoldFilename); % with the whole brain
        this_ds.samples = this_ds.samples(1 : size(parInfo, 1), :);
        
        % add sample and dataset attributes
        this_ds.sa.targets = parInfo.Condition;
        this_ds.sa.labels = parInfo.Label;
        this_ds.sa.chunks = repmat(iRun, size(parInfo, 1), 1);
        
        this_ds.a.vol.dim(1) = length(this_ds.a.fdim.values{1});
        
        % run if combine data from both hemispheres
        if isLR
            
            % update this_ds.a.fdim.values{1:1} as the number of vertices for the
            % whole brain (size(ascCell{1,3},1)) the number of vertice for white
            this_ds.a.fdim.values{1:1} = 1:size(vCell{1,3},1);
            
            % update the attribute number for further stack
            if iHemi == 1
                nVertices = numel(this_ds.a.fdim.values{1, 1});
            else
                this_ds.fa.i = this_ds.fa.i + nVertices;
            end
            
        end
        
        % save the dt in a cell for further stacking
        ds_cell(iRun, iHemi) = {this_ds};
        
    end
    
    if isLR
        % combine the dt for the two hemispheres
        ds_cell(iRun, 3) = cosmo_stack(ds_cell(iRun, 1:2), 2);
    end
    
end

% stack multiple ds.sample
if ~isLR
    ds_all(1,1) = cosmo_stack(ds_cell(:, 1)); % left
    ds_all(1,2) = cosmo_stack(ds_cell(:, 2)); % right
end


%% Set analysis parameters
% Use the cosmo_cross_validation_measure and set its parameters
% (classifier and partitions) in a measure_args struct.
measure = @cosmo_crossvalidation_measure;
measure_args = struct();

% Define which classifier to use, using a function handle.
% Alternatives are @cosmo_classify_{svm,nn,naive_bayes}
measure_args.classifier = classifier; % @cosmo_classify_lda;

%% conduct searchlight for two hemisphere seprately
for iHemi = 1:2
    
    thisHemi = hemis{iHemi}; % hemisphere name
    
    % Define the feature neighborhood for each node on the surface
    % - nbrhood has the neighborhood information
    % - vo and fo are vertices and faces of the output surface
    % - out2in is the mapping from output to input surface
    feature_count = 100;
    
    % ds for this hemisphere
    ds_hemi = cosmo_stack(ds_cell(:, iHemi));
    
    %%%%%%%%%%%%%%%%% convert dt from volume to surface %%%%%%%%%%%%%%%%%%%
    ds_temp = ds_hemi;
    ds_hemi.a.fdim.labels = {'node_indices'};
    ds_hemi.a.fdim.values = ds_hemi.a.fdim.values(1,1);
    ds_hemi.fa.node_indices = 1: numel(ds_hemi.a.fdim.values{1,1});
    
    %% Surface setting 
    % white, pial, surface for this hemisphere
    v_inf = vCell{i_inf, iHemi};
    f_inf = fCell{i_inf, iHemi};
    surf_def = {v_inf, f_inf};
    
    fprintf('\n\nCalcualte the surficial neighborhood for %s (%s):\n',...
        subjCode,thisHemi);
    [nbrhood,vo,fo,~]=cosmo_surficial_neighborhood(ds_hemi,surf_def,...
        'count',feature_count);
    % print neighborhood
    fprintf('Searchlight neighborhood definition:\n');
    cosmo_disp(nbrhood);
    fprintf('The output surface has %d vertices, %d nodes\n',...
        size(vo,1), size(fo,1));
    
    for iPair = 1:nPairs
        
        % define this classification
        thisPair = classifyPairs(iPair, :);
        thisPairMask = cosmo_match(ds_hemi.sa.labels, thisPair);
        
        % dataset for this classification
        ds_thisPair = cosmo_slice(ds_hemi, thisPairMask);
        
        %% Set partition scheme. odd_even is fast; for publication-quality analysis
        % nfold_partitioner is recommended.
        % Alternatives are:
        % - cosmo_nfold_partitioner    (take-one-chunk-out crossvalidation)
        % - cosmo_nchoosek_partitioner (take-K-chunks-out  "             ").
        measure_args.partitions = cosmo_nfold_partitioner(ds_thisPair);
        
        % print measure and arguments
        fprintf('Searchlight measure:\n');
        cosmo_disp(measure);
        fprintf('Searchlight measure arguments:\n');
        cosmo_disp(measure_args);
        
        %% Run the searchlight
        svm_results = cosmo_searchlight(ds_thisPair,nbrhood,measure,measure_args);
        
        % print searchlight output
        fprintf('Dataset output:\n');
        cosmo_disp(svm_results);
        
        %% Save results
        % store searchlight results
        output_filename = sprintf('%s.%s-%s.svm', thisHemi, thisPair{1}, thisPair{2});
        output_path = fullfile(boldPath, 'cosmo_searchlight');
        output_fn = fullfile(output_path, output_filename);
        if ~exist(output_path, 'dir')
            mkdir(output_path);
        end
        save([output_fn '.mat'], 'svm_results');
        fs_cosmo_map2label(svm_results, output_fn, f_inf, subjCode);
%         cosmo_map2surface(svm_results, [output_fn '.gii'], 'encoding','ASCII');
%         cosmo_map2surface(svm_results, [output_fn '.niml.dset'], 'encoding', 'ASCII');
        
        %% store counts
        
        
    end
end
