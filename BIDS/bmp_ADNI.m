function varargout = bmp_ADNI (operation_mode, varargin)
%
% DESCRIPTION
% ====================================================================================
%
%   bmp_ADNI contains a few shortcuts for ADNI cohort, including processing ADNI study
%   data downloaded from ADNI website, creating or retrieving existing DICOM-to-BIDS 
%   mappings, running dcm2niix to convert DICOM to BIDS, and diagnosing/check any 
%   missing by examining actual DICOM folders or comparing with Clinica outputs (TO
%   BE DEVELOPED).
%
%
%
% ARGUMENTS
% ====================================================================================
%
%   bmp_ADNI can be ran in the following modes:
%
%
%     'initiate' mode
%     +++++++++++++++++++++++++++++++++
%
%       Call bmp_ADNI_studyData.m to process ADNI study data, and generate
%       /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat. The MAT file saves
%       MRI_master, DEM_master, forDICOM2BIDS, and forBIDSpptsTsv.
%
%         operation_mode = 'initiate';
%
%         varargout{1} = DEM_master;
%         varargout{2} = MRI_master;
%         varargout{3} = forDICOM2BIDS;
%         varargout{4} = forBIDSpptsTsv;
%
%
%     'create' or 'create_mapping' mode 
%     +++++++++++++++++++++++++++++++++
%       
%        This mode is used to generate DICOM-to-BIDS mappings, and append the mappings 
%        to /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat.
%
%        operation_mode = 'create'; % or 'create_mapping'
%
%        varargin{1} = /path/to/mat/file/to/save, if not 
%                      /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat
%
%        varargout{1} = DICOM2BIDS;
%
%
%     'retrieve' or 'retrieve_mapping' mode
%     +++++++++++++++++++++++++++++++++++++
%
%        This mode load /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat to retrieve 
%        the predefiend mappings.
%
%        operation_mode = 'retrieve'; % or 'retrieve_mapping'
%
%        varargout{1} = DICOM2BIDS;
%
%
%     'dcm2niix' or 'run_dcm2niix' mode
%     +++++++++++++++++++++++++++++++++
%
%        This mode will call dcm2niix to convert DICOM to BIDS. By default,
%        /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat will be read for
%        predefined dcm2niix commands.
%
%        operation_mode = 'dcm2niix'; % or 'run_dcm2niix'
%
%        varargin{1} = /path/to/mat/file, if not 
%                      /path/to/BrainMRIpipelines/BIDS/bmp_ADNI.mat.
%
%        varargout{1} = DCM2NIIX
%
%
%     'refresh' or 'refresh_mat_file' mode
%     +++++++++++++++++++++++++++++++++++++
%
%        This mode refreshes the predefined bmp_ADNI.mat in BMP. This mode is
%        for internal use.
%
%        operation_mode = 'refresh'; % or 'refresh_mat_file'
%
%        varargin{1} = DICOM directory
%        varargin{2} = BIDS directory
%
%        varargout{1} = DCM2NIIX;
%
%
%     'prepare' mode
%     ++++++++++++++++++++++++++++++++++++
%
%        This mode prepares dcm2niix commands and save in 
%        /path/to/BIDS/code/BMP/bmp_ADNI.mat. These commands are with real paths
%        to BIDS and DICOM.
%
%        operation_mode = 'prepare';
%
%        varargin{1} = DICOM directory
%        varargin{2} = BIDS directory
%
%        varargout{1} = DCM2NIIX;
%
%
%     'checkback' mode
%     ++++++++++++++++++++++++++++++++++++
%
%        --== TO BE DEVELOPED ==--
%
%
%     'clinica' mode
%     ++++++++++++++++++++++++++++++++++++
%
%        Look into tsv files in conversion_info folder created by Clinica, and
%        search for ASL for subjects with other modalities (T1/FLAIR/dMRI/fMRI/PET).
%        Will generate dcm2niix commands.
%
%        operation_mode = 'clinica'
%
%        varargin{1} = DICOM directory
%        varargin{2} = BIDS directory
%
%        varargout{1} = CLINICA_ASL
%
%
%     'dcm2niix_clinica' mode
%     ++++++++++++++++++++++++++++++++++++
%
%        Run dcm2niix commands prepared in 'clinica' mode.
%
%        operation_mode = 'dcm2niix_clinica'
%
%        varargin{1} = BIDS directory
%
%        varargout{1} = CLINICA_ASL
%
%
%
%
% SUPPORTED MODALITIES
% ====================================================================================
%
%   - T1w
%   - FLAIR
%   - asl
%
%
% HISTORY
% ====================================================================================
%
%   05 December 2022 - first version.
%
%   09 December 2022 - bmp_BIDSgenerator needs scalar input. Therfore, change
%                      DICOM2BIDS(i) to ADNI.DICOM2BIDS(i).
%
%   19 December 2022 - update to describe DICOM2BIDS using MATLAB tables.
%
%   23 December 2022 - 'clinica' and 'dcm2niix_clinica' modes.
%
%
%
% KNOWN LIMITATIONS
% ====================================================================================
%
%  - Some limitations are commented in-line.
%
%  - Assumes max of 9 runs for each modality.
%
%
%


	BMP_PATH = getenv ('BMP_PATH');



	% possible keywords in DICOM sequence name for each modality in ADNI
	possibleASLkeywords = 	{
							'ASL'
							'cerebral blood flow'
							'perfusion'
							'MoCoSeries'
							};						% 16Dec2022 : 	According to ASL QC files, SEQUENCE with
													% 				'MoCoSeries' corresponds to ASL.

	possibleT1keywords = 	{
							'MPRAGE'
							'T1'
							'IR-SPGR'
							'IR-FSPGR'
							'MP-RAGE'
							'MP RAGE'
							};

	possibleFLAIRkeywords = {
							'FLAIR'
							};



	switch operation_mode


		case 'initiate'

			clear all
			clc

			fprintf ('%s : Running in ''initiate'' mode.\n', mfilename);
			fprintf ('%s : Calling bmp_ADNI_studyData.m to process ADNI study data ... ', mfilename);

			[varargout{1}, varargout{2}, varargout{3}, varargout{4}] = bmp_ADNI_studyData;

			fprintf ('DONE!\n');




		case {'create'; 'create_mapping'}

			if nargin == 2 && endsWith(varargin{1},'.mat')
				output = varargin{1};
			else
				output = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			fprintf ('%s : Running in ''create'' mode. Will save DICOM2BIDS mapping to %s.\n',mfilename,output);

			fprintf ('%s : Loading bmp_ADNI.mat ... ', mfilename);

			ADNI_mat = load (fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat'));

			fprintf ('DONE!\n', mfilename);

			forDICOM2BIDS = ADNI_mat.forDICOM2BIDS;
			
			fprintf ('%s : Start to create DICOM2BIDS mapping.\n', mfilename);


			% Initialise
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			SUBJECT = strcat('ADNI',erase(forDICOM2BIDS.SID,'_'));
			SESSION = forDICOM2BIDS.VISCODE;
			DATATYPE = cell (size (forDICOM2BIDS,1),1);
			DATATYPE(:,1) = {'UNKNOWN'};
			MODALITY = cell (size (forDICOM2BIDS,1),1);
			MODALITY(:,1) = {'UNKNOWN'};
			RUN = ones (size (forDICOM2BIDS,1),1);
			ACQUISITION = cell (size (forDICOM2BIDS,1),1);
			ACQUISITION(:,1) = {'UNKNOWN'};
			SEQUENCE = forDICOM2BIDS.SEQUENCE;
			PATIENTID = forDICOM2BIDS.SID;
			STUDYDATE = strrep(cellstr(forDICOM2BIDS.SCANDATE),'-','');
			IMAGEUID = forDICOM2BIDS.IMAGEUID;
			DICOMSUBDIR = strrep(strrep(strrep(forDICOM2BIDS.SEQUENCE,' ','_'),'(','_'),')','_');


			% Modality
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			MODALITY(find(contains(SEQUENCE,possibleT1keywords,		'IgnoreCase',true)),1) = {'T1w'};
			MODALITY(find(contains(SEQUENCE,possibleFLAIRkeywords,	'IgnoreCase',true)),1) = {'FLAIR'};
			MODALITY(find(strcmp(SEQUENCE,'Axial T2 Star-Repeated with exact copy of FLAIR')),1) = {'UNKNOWN'};
			MODALITY(find(contains(SEQUENCE,possibleASLkeywords,	'IgnoreCase',true)),1) = {'asl'};

			% Datatype
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			DATATYPE(find(strcmp(MODALITY,'T1w')),1) 	= {'anat'};
			DATATYPE(find(strcmp(MODALITY,'FLAIR')),1) 	= {'anat'};
			DATATYPE(find(strcmp(MODALITY,'asl')),1) 	= {'perf'};

			% Run
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			RUN(find(contains(SEQUENCE,{'repeat', 'repe', 'rpt','rep', 'repea'},'IgnoreCase',true)),1) = 2;

			for i = 1 : 9 												% support up to 9 runs
				forDICOM2BIDS_temp = table(	forDICOM2BIDS.SID,...
											forDICOM2BIDS.SCANDATE,...
											forDICOM2BIDS.VISCODE,...
											forDICOM2BIDS.SEQUENCE,...
											RUN);
				forDICOM2BIDS_temp.Properties.VariableNames = {'SID';'SCANDATE';'VISCODE';'SEQUENCE';'RUN'};
				[~, uniqIdx] = unique(forDICOM2BIDS_temp);
				RUN(setdiff(1:size(forDICOM2BIDS_temp,1), uniqIdx),1) = i+1;
			end

			RUN(find(strcmp(SEQUENCE,'Axial 3D PASL (Eyes Open) REPEAT')),1) = 1; 	% this happened once for 036_S_6316 in 2019-08-13. However, we cannot
																					% find another ASL on the same day therefore, we are not assigning
																					% 'run' entity although it said 'REPEAT'.
																					%
			RUN(find(strcmp(SEQUENCE,'Axial 3D PASL (Eyes Open) REPEAT')),1) = 2;	% 16Dec2022 : Run 1 does exist in DICOM, although not
																					%             documented in study data. Therefore,
																					%             resuming RUN = 2. Run 1 should be converted
																					%             in 'checkback' mode.


			% Acquisition
			% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
			ACQUISITION(find(contains(SEQUENCE,'Axial 3D PASL',										'IgnoreCase',true)),1) = {'ax3dpasl'}; 
			ACQUISITION(find(contains(SEQUENCE,{'Ax 3D pCASL'; 'Axial 3D pCASL';'Axial_3D_pCASL'},	'IgnoreCase',true)),1) = {'ax3dpcasl'};
			ACQUISITION(find(contains(SEQUENCE,'Axial 2D PASL',										'IgnoreCase',true)),1) = {'ax2dpasl'};
			ACQUISITION(find(contains(SEQUENCE,'tgse_pcasl_PLD2000',								'IgnoreCase',true)),1) = {'tgsepcasl2000pld'}; 
			ACQUISITION(find(contains(SEQUENCE,'Cerebral Blood Flow',								'IgnoreCase',true)),1) = {'cbf'};
			ACQUISITION(find(contains(SEQUENCE,'Perfusion_Weighted',								'IgnoreCase',true)),1) = {'perfwei'}; 	% Note over 3000 perfusion-
																																			% weighted and relCBF cannot
																																			% find SID. Therefore, DICOM2BIDS
																																			% for these images is not able
																																			% to establish from study data.
																																			% This should be resolved in
																																			% 'checkback' mode to find
																																			% mapping based on existing
																																			% DICOM.

			ACQUISITION(find(contains(SEQUENCE, {	'MPRAGE'
													'MP RAGE'
													'MP-RAGE'}, 					'IgnoreCase', true)),1) = {'mprage'};

			ACQUISITION(find(contains(SEQUENCE, 	'IR-SPGR',						'IgnoreCase', true)),1) = {'irspgr'};

			ACQUISITION(find(contains(SEQUENCE, 	'IR-FSPGR',						'IgnoreCase', true)),1) = {'irfspgr'}; 	% keywords in SEQUENCE, such as '3D' and 'SAGITTAL'
																															% are not included in ACQUISITION for now.

			ACQUISITION(find(contains(SEQUENCE, {	'AX FLAIR'
													'AX T2 FLAIR'
													'AXIAL FLAIR'
													'AX_T2_FLAIR'
													'Axial T2 FLAIR'
													'Axial T2-FLAIR'
													'FLAIR AX'
													'FLAIR AXIAL'},					'IgnoreCase', true)),1) = {'ax'};
			
			ACQUISITION(find(contains(SEQUENCE, 	'Axial 3D FLAIR', 				'IgnoreCase', true)),1) = {'ax3d'};

			ACQUISITION(find(contains(SEQUENCE,	{	'Sagittal 3D FLAIR'
													'Sagittal_3D_FLAIR'
													'Sagittal 3D 0 angle FLAIR'}, 	'IgnoreCase', true)),1) = {'sag3d'};

			ACQUISITION(find(contains(SEQUENCE,		'Sagittal 3D FLAIR_MPR',		'IgnoreCase', true)),1) = {'sag3dmpr'};

			ACQUISITION(find(contains(SEQUENCE,		't2_flair SAG',					'IgnoreCase', true)),1) = {'sag'};


			DICOM2BIDS = table (SUBJECT,SESSION,DATATYPE,MODALITY,RUN,ACQUISITION,SEQUENCE,PATIENTID,STUDYDATE,IMAGEUID,DICOMSUBDIR);


			fprintf ('%s : ADNI DICOM2BIDS mapping has been created.\n', mfilename);

			fprintf ('%s : Saving ADNI DICOM2BIDS to %s ... ', mfilename, output);

			save (output, 'DICOM2BIDS', '-append');

			fprintf ('DONE!\n');

			varargout{1} = DICOM2BIDS;




		case {'retrieve'; 'retrieve_mapping'}

			ADNI_mat = fullfile (BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			
			fprintf ('%s : Running in ''retrieve'' mode.\n', mfilename);
			fprintf ('%s : Loading %s ... ', mfilename, ADNI_mat);

			varargout{1} = load(ADNI_mat).DICOM2BIDS;

			fprintf ('DONE!\n');




		case {'dcm2niix'; 'run_dcm2niix'}

			fprintf ('%s : Running in ''dcm2niix'' mode.\n');

			if nargin == 2 && isfile (varargin{1}) && endsWith(varargin{1},'.mat')
				ADNI_mat = varargin{1};
			else
				ADNI_mat = fullfile(BMP_PATH, 'BIDS', 'bmp_ADNI.mat');
			end

			DCM2NIIX = load(ADNI_mat).DCM2NIIX;

			DCM2NIIX = run_dcm2niix (DCM2NIIX);
			

			fprintf('%s : Saving dcm2niix command outputs to bmp_ADNI.mat.\n', mfilename);

			save (ADNI_mat, 'DCM2NIIX', '-append');

			varargout{1} = DCM2NIIX;



		case {'dcm2niix_clinica'; 'run_dcm2niix_clinica'}

			fprintf ('%s : Running in ''dcm2niix_clinica'' mode.\n');

			BIDS_directory = varargin{1};

			DCM2NIIX = load(fullfile(BIDS_directory,'code','BMP','bmp_ADNI.mat')).CLINICA_ASL;

			CLINICA_ASL = run_dcm2niix (DCM2NIIX);

			fprintf('%s : Saving dcm2niix command outputs to bmp_ADNI.mat.\n', mfilename);

			save (fullfile(BIDS_directory,'code','BMP','bmp_ADNI.mat'), 'CLINICA_ASL', '-append');

			varargout{1} = CLINICA_ASL;


		case {'refresh'; 'refresh_mat_file'} % refresh mode is for internal testing.

			[~,~,~,~] = bmp_ADNI ('initiate'); % call bmp_ADNI_studyData.m to process ADNI study data.

			DICOM2BIDS = bmp_ADNI ('create'); % create DICOM2BIDS

			DCM2NIIX = bmp_BIDSgenerator ('ADNI', DICOM2BIDS, varargin{1}, varargin{2});

			%% not running dcm2niix in refresh mode.

			varargout{1} = DCM2NIIX;



		case {'prepare'} % prepare for real run

			bmp_BIDSinitiator (BIDS_directory, 'ADNI');

			DICOM2BIDS = bmp_ADNI ('retrieve');

			DCM2NIIX = bmp_BIDSgenerator ('ADNI', DICOM2BIDS, varargin{1}, varargin{2}, 'MatOutDir', fullfile (varargin{2}, 'code', 'BMP'));

			varargout{1} = DCM2NIIX;


		case {'checkback'} 	% using info from MRI scans (e.g., ???_S_???? IDs) and comparing with info
							% in MRI_master table in bmp_ADNI.mat, in order to try to savage some of
							% the scans.


			%% TO BE IMPLEMENTED


		case {'clinica'}

			DICOM_directory = varargin{1};
			BIDS_directory  = varargin{2};

			bmp_BIDSinitiator (BIDS_directory, 'ADNI');

			DICOM2BIDS = bmp_ADNI ('retrieve');
			DCM2NIIX   = bmp_BIDSgenerator ('clinica-ADNI', DICOM2BIDS, DICOM_directory, BIDS_directory, 'MatOutDir', fullfile (BIDS_directory, 'code', 'BMP'));

			fprintf ('%s : Reading tsv files in conversion_info folder.\n', mfilename);

			clinica_conv_info_dir = dir (fullfile (BIDS_directory, 'conversion_info'));
			clinica_conv_info_dir_path = fullfile (clinica_conv_info_dir(end).folder, clinica_conv_info_dir(end).name);
			clinica_conv_info_tsv_dir = dir (fullfile (clinica_conv_info_dir_path, '*.tsv'));

			comm_vars = {	
							'Subject_ID'
							'VISCODE'
							'Visit'
							'Sequence'
							'Scan_Date'
							'Study_ID'
							'Series_ID'
							'Image_ID'
							'Is_Dicom'
							'Path'
						};

			uncomm_vars = 	{
							'Phase'				% PET only, but not MRI
							'Field_Strength' 	% MRI only, but not PET
							'Tracer'			% amyloid_pet_paths.tsv only
							'Original'			% all except DWI, FLAIR, fMRI.
							};

			clinica_comm_vars   = cell (0, (size(  comm_vars,1)));
			clinica_uncomm_vars = cell (0, (size(uncomm_vars,1)));

			for i = 1 : size (clinica_conv_info_tsv_dir,1)

				fprintf ('    --  Reading %s ... ', clinica_conv_info_tsv_dir(i).name),

				curr_tab_opts = detectImportOptions (fullfile (clinica_conv_info_tsv_dir(i).folder, clinica_conv_info_tsv_dir(i).name), ...
														'FileType',				'delimitedtext', ...
														'ReadVariableNames',	true, ...
														'MissingRule',			'fill', ...
														'ImportErrorRule',		'error', ...
														'Delimiter',			'\t', ...
														'ExtraColumnsRule',		'error');


				curr_tab_opts.VariableTypes(find(~strcmp(curr_tab_opts.VariableNames, 'Scan_Date'))) = {'char'};
				curr_tab_opts.VariableTypes(find(strcmp(curr_tab_opts.VariableNames, 'Scan_Date'))) = {'datetime'};

				curr_tab = readtable (fullfile (clinica_conv_info_tsv_dir(i).folder, clinica_conv_info_tsv_dir(i).name), curr_tab_opts);

				idx_avail_uncomm_vars   = find ( ismember (uncomm_vars, curr_tab.Properties.VariableNames));
				idx_unavail_uncomm_vars = find (~ismember (uncomm_vars, curr_tab.Properties.VariableNames));

				curr_clinica_uncomm_vars = cell (size(curr_tab,1), size(uncomm_vars,1));

				curr_clinica_uncomm_vars (:, idx_avail_uncomm_vars)   = table2cell(curr_tab(:,uncomm_vars(idx_avail_uncomm_vars)));
				curr_clinica_uncomm_vars (:, idx_unavail_uncomm_vars) = {'UNKNOWN'};

				clinica_uncomm_vars = [clinica_uncomm_vars; curr_clinica_uncomm_vars];
				clinica_comm_vars =   [clinica_comm_vars;   table2cell(curr_tab(:,comm_vars))];

				fprintf ('DONE!\n')


			end

			fprintf ('%s : Gathering all info in tsv files into a table ... ', mfilename);

			clinica_cell = [clinica_comm_vars, clinica_uncomm_vars];

			CLINICA = cell2table (clinica_cell, 'VariableNames', [comm_vars; uncomm_vars]);

			fprintf ('DONE!\n');

			
			fprintf ('%s : Populating known ''Phase'' to other modalites acquired on the same day of scan ... ', mfilename);

			known_phase = CLINICA (:, {'Subject_ID';'VISCODE';'Scan_Date';'Phase'});
			known_phase = known_phase (find(~strcmp(known_phase.Phase,'UNKNOWN')),:);

			for i = 1 : size (known_phase,1)

				nbytes = fprintf ('(%d / %d)', i, size(known_phase,1));

				CLINICA(find(ismember(CLINICA(:,{'Subject_ID';'VISCODE';'Scan_Date'}),known_phase(i,{'Subject_ID';'VISCODE';'Scan_Date'}))),{'Phase'}) = known_phase.Phase(i);

				while nbytes > 0
			         fprintf('\b')
			         nbytes = nbytes - 1;
			    end
			end

			fprintf ('DONE!\n');

			fprintf ('%s : Saving CLINICA table to bmp_ADNI.mat ... ', mfilename);

			save (fullfile(BIDS_directory, 'code', 'BMP', 'bmp_ADNI.mat'), 'CLINICA', '-append');

			fprintf ('DONE!\n');
			

			
			fprintf ('%s : Looking for ASL using information from Clinica tsv files ... ', mfilename);

			CLINICA_ASL = CLINICA (:,{'Subject_ID';'Scan_Date';'VISCODE';'Phase'});

			CLINICA_ASL.ASL_dir = cellfun(@dir, fullfile (	DICOM_directory, ...
															CLINICA_ASL.Subject_ID, ...
															'*ASL*', ...
															strcat(char(CLINICA_ASL.Scan_Date),'*'), ...
															'I*'), ...
												'UniformOutput', false);

			CLINICA_ASL.ASL_exist = ~cellfun(@isempty, CLINICA_ASL.ASL_dir);

			CLINICA_ASL = CLINICA_ASL(find(CLINICA_ASL.ASL_exist),:);

			[~, idx_uniq] = unique(CLINICA_ASL(:,{'Subject_ID';'Scan_Date';'VISCODE'}));

			CLINICA_ASL = CLINICA_ASL(idx_uniq,:);

			fprintf ('DONE!\n');

			fprintf ('%s : Preparing dcm2niix commands for ASL (N = %d) ... ', mfilename, size(CLINICA_ASL,1));

			CLINICA_ASL.DICOM_INPUT_DIR = cellfun(@(x) fullfile(x.folder,x.name), CLINICA_ASL.ASL_dir, 'UniformOutput', false);

			CLINICA_ASL.SESSION_LAB = strrep(strrep(CLINICA_ASL.VISCODE, 'bl', 'M00'),'m','M'); % session label : 'bl' -> 'M00'; 'm???' -> 'M???'

			CLINICA_ASL.BIDS_OUTPUT_DIR = fullfile (BIDS_directory, ...
													strcat('sub-ADNI', strrep(CLINICA_ASL.Subject_ID,'_','')), ...
													strcat('ses-', CLINICA_ASL.SESSION_LAB), ...
													'perf');

			CLINICA_ASL.BIDS_NII_NAME = strcat('sub-ADNI', strrep(CLINICA_ASL.Subject_ID,'_',''), '_ses-', CLINICA_ASL.SESSION_LAB, '_asl');

			curr_datetime = strrep(char(datetime),' ','_');
			CLINICA_ASL.CMD = strcat ('dcm2niix   -6', ...
												' -a y', ...
												' -b y', ...
												' -ba n', ...
												' -c BMP_', curr_datetime, ...
												' -d 1', ...
												' -e n', ...
												' -f', {' '}, CLINICA_ASL.BIDS_NII_NAME, ...
												' -g n', ...
												' -i y', ...
												' -l o', ...
												' -o', {' '}, CLINICA_ASL.BIDS_OUTPUT_DIR, ...
												' -p y', ...
												' -r n', ...
												' -s n', ...
												' -v 0', ...
												' -w 1', ...
												' -x n', ...
												' -z n', ...
												' --big-endian o', ...
												' --progress n', ...
												{' '}, CLINICA_ASL.DICOM_INPUT_DIR);

			fprintf ('DONE!\n');

			fprintf ('%s : Cross-checking with DCM2NIIX derived from ADNI study data to find out missed ones ... ', mfilename);

			DCM2NIIX = DCM2NIIX(find(strcmp(DCM2NIIX.TO_CONVERT,'Yes')),:);

			CLINICA_ASL = CLINICA_ASL(:, {	'Subject_ID'
											'Scan_Date'
											'VISCODE'
											'Phase'
											'DICOM_INPUT_DIR'
											'SESSION_LAB'
											'BIDS_OUTPUT_DIR'
											'BIDS_NII_NAME'
											'CMD'});

			additional_cmd 				= DCM2NIIX.CMD 				(find(~ismember(DCM2NIIX.DICOM_INPUT_DIR,CLINICA_ASL.DICOM_INPUT_DIR)));
			additional_dicominputdir 	= DCM2NIIX.DICOM_INPUT_DIR	(find(~ismember(DCM2NIIX.DICOM_INPUT_DIR,CLINICA_ASL.DICOM_INPUT_DIR)));
			additional_bidsoutputdir 	= DCM2NIIX.BIDS_OUTPUT_DIR	(find(~ismember(DCM2NIIX.DICOM_INPUT_DIR,CLINICA_ASL.DICOM_INPUT_DIR)));
			additional_bidsniiname	 	= DCM2NIIX.BIDS_NII_NAME	(find(~ismember(DCM2NIIX.DICOM_INPUT_DIR,CLINICA_ASL.DICOM_INPUT_DIR)));

			additional_cmd              = strrep (strrep (additional_cmd, 			'ses-bl', 'ses-M00'), 'ses-m', 'ses-M');
			additional_dicominputdir    = strrep (strrep (additional_dicominputdir, 'ses-bl', 'ses-M00'), 'ses-m', 'ses-M');
			additional_bidsoutputdir    = strrep (strrep (additional_bidsoutputdir, 'ses-bl', 'ses-M00'), 'ses-m', 'ses-M');
			additional_bidsniiname      = strrep (strrep (additional_bidsniiname, 	'ses-bl', 'ses-M00'), 'ses-m', 'ses-M');



			CLINICA_ASL(end+1:end+size(additional_cmd,1), {	'CMD'
															'DICOM_INPUT_DIR'
															'BIDS_OUTPUT_DIR'
															'BIDS_NII_NAME'}) = [	additional_cmd, ...
																					additional_dicominputdir, ...
																					additional_bidsoutputdir, ...
																					additional_bidsniiname];

			CLINICA_ASL.Subject_ID(find(cellfun(@isempty, CLINICA_ASL.Subject_ID)))={'UNKNOWN'};
			CLINICA_ASL.VISCODE(find(cellfun(@isempty, CLINICA_ASL.VISCODE)))={'UNKNOWN'};
			CLINICA_ASL.Phase(find(cellfun(@isempty, CLINICA_ASL.Phase)))={'UNKNOWN'};
			CLINICA_ASL.SESSION_LAB(find(cellfun(@isempty, CLINICA_ASL.SESSION_LAB)))={'UNKNOWN'};
			CLINICA_ASL.TO_CONVERT(:) = {'Yes'};

			fprintf ('DONE (Please ignore warning)!\n');


			fprintf ('%s : Saving CLINICA_ASL table to bmp_ADNI.mat ... ', mfilename);

			save (fullfile (BIDS_directory, 'code', 'BMP', 'bmp_ADNI.mat'), 'CLINICA_ASL', '-append');

			fprintf ('DONE!\n');

			
			varargout{1} = CLINICA_ASL;

			%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			%% CAN ADD OTHER MODALITES THAT ARE MISSED IN CLINICA, E.G., T2*, ETC., HERE.
			%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	end

end
	
function DCM2NIIX = run_dcm2niix (DCM2NIIX)

	DCM2NIIX.CMD_OUT = cell(size(DCM2NIIX.CMD));
	DCM2NIIX.CMD_OUT(:,1) = {'UNKNOWN'};
	DCM2NIIX.CMD_STATUS = cell(size(DCM2NIIX.CMD));
	DCM2NIIX.CMD_STATUS(:,1) = {'UNKNOWN'};
	DCM2NIIX.CMD_WARNINGS = cell(size(DCM2NIIX.CMD));
	DCM2NIIX.CMD_WARNINGS(:,1) = {'NONE'};
	DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS = cell(size(DCM2NIIX.CMD));
	DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS(:,1) = {'UNKNOWN'};
	

	for i = 1 : size(DCM2NIIX.CMD,1)

		if ~ isfolder (DCM2NIIX.BIDS_OUTPUT_DIR{i,1})

			status = mkdir (DCM2NIIX.BIDS_OUTPUT_DIR{i,1});

			if ~ status

				DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Fail';

				fprintf(2, '%s : Creating BIDS directory ''%s'' failed. This may be because you don''t have the BIDS directory in bmp_ADNI.mat. You may need to run bmp_BIDSgenerator with proper BIDS_directory argument.\n', mfilename, DCM2NIIX.BIDS_OUTPUT_DIR{i,1});

				continue

			else

				DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Success';

			end

		else

			DCM2NIIX.BIDS_OUTPUT_DIR_MKDIR_STATUS{i,1} = 'Exist';

		end

		if strcmp (DCM2NIIX.TO_CONVERT{i,1}, 'Yes')

			[~, curr_imageuidfoldername] = fileparts (DCM2NIIX.DICOM_INPUT_DIR{i,1});

			fprintf ('%s : (%d / %d) : Running dcm2niix to convert ''%s'' to ''%s''.nii ... ', ...
							mfilename, i, size (DCM2NIIX.CMD,1), curr_imageuidfoldername, DCM2NIIX.BIDS_NII_NAME{i,1});

			[DCM2NIIX.CMD_STATUS{i,1}, DCM2NIIX.CMD_OUT{i,1}] = system (DCM2NIIX.CMD{i,1});

			if contains (DCM2NIIX.CMD_OUT{i,1}, 'warning', 'IgnoreCase', true)

				DCM2NIIX.CMD_WARNINGS{i,1} = DCM2NIIX.CMD_OUT{i,1};

			end

			fprintf (' DONE!\n');

		end

	end

end