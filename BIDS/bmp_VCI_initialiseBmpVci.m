function BMP_VCI = bmp_VCI_initialiseBmpVci (individual_original_DICOM_directory, cohort_BIDS_directory, BIDS_subject_label, varargin)
%
% varargin{1} = 'notRunningDicomCollection';
%
%

	BMP_VCI.BIDS.modalities = {
										'T1'
										'T2'
										'FLAIR'
										'SWI'
										'DWI'
										'ASL'
										'CVR_fmap'
										'CVR'
										'MP2RAGE'
										'DCE'
									};

	% The following keywords map all sequences to modalities, regardless of
	% whether they are useful and/or to be converted to NIFTI.
	% They are used in organising DICOM folders.
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.T1 = 'T1_MPRAGE_0.8_iso';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.T2 = 'T2_spc_sag_0.8mm';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.FLAIR = 't2_space_dark-fluid_sag_p2_ns-t2prep';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.SWI = 'greME7_p31_256_Iso1mm';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.DWI = 'DIFFUSION';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.ASL = 'asl_3d_tra_p2_iso_3mm_highres';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.CVR_fmap = 'gre_field_mapping 3.8mm';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.CVR = 'CVR_ep2d_bold 3.8mm TR1500 adaptive';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.MP2RAGE = 't1_mp2rage_sag_0.8x0.8x2';
	BMP_VCI.BIDS.seriesDescriptionKeywordToModalityMapping.DCE = 't1_vibe_sag_DCE_2mm XL FOV 40s temporal res';



	% The following mappings only include those seq being useful and to be converted to NIFTI.

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.T1 = {'T1_MPRAGE_0.8_iso'}; 	% "T1_MPRAGE_0.8_iso"
																			    % "T1_MPRAGE_0.8_iso_MPR_Cor"
																			    % "T1_MPRAGE_0.8_iso_MPR_Sag"
																			    % "T1_MPRAGE_0.8_iso_MPR_Tra"
																			    % "T1_MPRAGE_0.8_iso_ND"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.T2 = {'T2_spc_sag_0.8mm'};	% "T2_spc_sag_0.8mm"
																			    % "T2_spc_sag_0.8mm_MPR_Cor"
																			    % "T2_spc_sag_0.8mm_MPR_Sag"
																			    % "T2_spc_sag_0.8mm_MPR_Tra"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.FLAIR = {'t2_space_dark-fluid_sag_p2_ns-t2prep'};	% "t2_space_dark-fluid_sag_p2_ns-t2prep"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.SWI = 	{
															'greME7_p31_256_Iso1mm_Mag'
														    'greME7_p31_256_Iso1mm_Pha'
														    'greME7_p31_256_Iso1mm_Qsm_Combined'
														    'greME7_p31_256_Iso1mm_SWI_Combined'
														    'greME7_p31_256_Iso1mm_SWI_mIP_Combined'
														    };										% "greME7_p31_256_Iso1mm_Mag"
																								    % "greME7_p31_256_Iso1mm_Pha"
																								    % "greME7_p31_256_Iso1mm_Qsm_Combined"
																								    % "greME7_p31_256_Iso1mm_SWI_Combined"
																								    % "greME7_p31_256_Iso1mm_SWI_mIP_Combined"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.DWI =	{
															'AP_BLOCK_1_DIFFUSION_30DIR'
															'AP_BLOCK_2_DIFFUSION_30DIR'
															'AP_FMAP_for DIFFUSION'
															'PA_BLOCK_1_DIFFUSION_30DIR'
															'PA_BLOCK_2_DIFFUSION_30DIR'
															'PA_FMAP_for DIFFUSION'
															};										% "AP_BLOCK_1_DIFFUSION_30DIR"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_ADC"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_ColFA"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_FA"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_TENSOR"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_TENSOR_B0"
																								    % "AP_BLOCK_1_DIFFUSION_30DIR_TRACEW"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_ADC"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_ColFA"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_FA"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_TENSOR"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_TENSOR_B0"
																								    % "AP_BLOCK_2_DIFFUSION_30DIR_TRACEW"
																								    % "AP_FMAP_for DIFFUSION"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_ADC"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_ColFA"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_FA"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_TENSOR"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_TENSOR_B0"
																								    % "PA_BLOCK_1_DIFFUSION_30DIR_TRACEW"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_ADC"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_ColFA"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_FA"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_TENSOR"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_TENSOR_B0"
																								    % "PA_BLOCK_2_DIFFUSION_30DIR_TRACEW"
																								    % "PA_FMAP_for DIFFUSION"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.ASL = {'asl_3d_tra_p2_iso_3mm_highres'};			% "asl_3d_tra_p2_iso_3mm_highres"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.CVR_fmap = {'gre_field_mapping 3.8mm'};			% "gre_field_mapping 3.8mm"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.CVR = {'CVR_ep2d_bold 3.8mm TR1500 adaptive'};	% "CVR_ep2d_bold 3.8mm TR1500 adaptive"
																								    % "CVR_ep2d_bold 3.8mm TR1500 adaptive_PMU"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.MP2RAGE = {
																't1_mp2rage_sag_0.8x0.8x2_INV1'
															    't1_mp2rage_sag_0.8x0.8x2_INV2'
															    't1_mp2rage_sag_0.8x0.8x2_T1_Images'
															    't1_mp2rage_sag_0.8x0.8x2_UNI_Images'
															};										% "t1_mp2rage_sag_0.8x0.8x2_INV1"
																								    % "t1_mp2rage_sag_0.8x0.8x2_INV2"
																								    % "t1_mp2rage_sag_0.8x0.8x2_T1_Images"
																								    % "t1_mp2rage_sag_0.8x0.8x2_UNI_Images"

	BMP_VCI.BIDS.seriesDescriptionToConvertToNIFTI.DCE = {'t1_vibe_sag_DCE_2mm XL FOV 40s temporal res'};																							    																% "t1_vibe_sag_DCE_2mm XL FOV 40s temporal res"
																								    % "t1_vibe_sag_DCE_2mm XL FOV 40s temporal res_ND"


	% details for corresponding BIDS folder/file
	BMP_VCI.BIDS.DICOM2BIDS.T1 = struct('DataType',								'anat', ...
										'Modality',								'T1w', ...
										'Acquisition',							'MPRAGE0p8iso', ...
										'CorrespondingSeriesDescription',		'T1_MPRAGE_0.8_iso');

	BMP_VCI.BIDS.DICOM2BIDS.T2 = struct('DataType',								'anat', ...
										'Modality',								'T2w', ...
										'Acquisition',							'sagSPACE0p8iso', ...
										'CorrespondingSeriesDescription',		'T2_spc_sag_0.8mm');

	BMP_VCI.BIDS.DICOM2BIDS.FLAIR = struct(	'DataType',							'anat', ...
											'Modality',							'FLAIR', ...
											'Acquisition',						'sagSPACE', ...
											'CorrespondingSeriesDescription',	't2_space_dark-fluid_sag_p2_ns-t2prep');

	BMP_VCI.BIDS.DICOM2BIDS.SWI_mag = struct(	'DataType',							'swi', ...
												'Modality',							'GRE', ...
												'Part',								'mag', ...
												'NumEchoes',						7, ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'yes', ...
												'AllVolumesAsSingle4D',				'no', ...
												'CorrespondingSeriesDescription',	'greME7_p31_256_Iso1mm_Mag'); 
												% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.DICOM2BIDS.SWI_pha = struct(	'DataType',							'swi', ...
												'Modality',							'GRE', ...
												'Part',								'phase', ...
												'NumEchoes',						7, ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'yes', ...
												'AllVolumesAsSingle4D',				'no', ...
												'CorrespondingSeriesDescription',	'greME7_p31_256_Iso1mm_Pha'); 
												% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.DICOM2BIDS.SWI_qsm = struct(	'DataType',							'swi', ...
												'Modality',							'Chimap', ...
												'CorrespondingSeriesDescription',	'greME7_p31_256_Iso1mm_Qsm_Combined'); 
												% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.Chimap
												% 		https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.DICOM2BIDS.SWI_swi = struct(	'DataType',							'swi', ...
												'Modality',							'swi', ...
												'CorrespondingSeriesDescription',	'greME7_p31_256_Iso1mm_SWI_Combined');
												% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6

	BMP_VCI.BIDS.DICOM2BIDS.SWI_mip = struct(	'DataType',							'swi', ...
												'Modality',							'minIP', ...
												'CorrespondingSeriesDescription',	'greME7_p31_256_Iso1mm_SWI_mIP_Combined');
												% Ref : https://docs.google.com/document/d/1kyw9mGgacNqeMbp4xZet3RnDhcMmf4_BmRgKaOkO2Sc/edit#heading=h.mqkmyp254xh6
											
	BMP_VCI.BIDS.DICOM2BIDS.DWI_ap1 = struct(	'DataType',							'dwi', ...
												'Modality',							'dwi', ...
												'PhaseEncodingDirection',			'AP', ...
												'RunID',							'01', ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'no', ...
												'AllVolumesAsSingle4D',				'yes', ...
												'CorrespondingSeriesDescription',	'AP_BLOCK_1_DIFFUSION_30DIR');
												% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.DICOM2BIDS.DWI_ap2 = struct(	'DataType',							'dwi', ...
												'Modality',							'dwi', ...
												'PhaseEncodingDirection',			'AP', ...
												'RunID',							'02', ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'no', ...
												'AllVolumesAsSingle4D',				'yes', ...
												'CorrespondingSeriesDescription',	'AP_BLOCK_2_DIFFUSION_30DIR');
												% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.DICOM2BIDS.DWI_pa1 = struct(	'DataType',							'dwi', ...
												'Modality',							'dwi', ...
												'PhaseEncodingDirection',			'PA', ...
												'RunID',							'01', ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'no', ...
												'AllVolumesAsSingle4D',				'yes', ...
												'CorrespondingSeriesDescription',	'PA_BLOCK_1_DIFFUSION_30DIR');
												% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.DICOM2BIDS.DWI_pa2 = struct(	'DataType',							'dwi', ...
												'Modality',							'dwi', ...
												'PhaseEncodingDirection',			'PA', ...
												'RunID',							'02', ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'no', ...
												'AllVolumesAsSingle4D',				'yes', ...
												'CorrespondingSeriesDescription',	'PA_BLOCK_2_DIFFUSION_30DIR');
												% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#diffusion-imaging-data

	BMP_VCI.BIDS.DICOM2BIDS.DWI_fmapAP = struct('DataType',							'fmap', ...
												'Modality',							'epi', ...
												'PhaseEncodingDirection',			'AP', ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'no', ...
												'AllVolumesAsSingle4D',				'yes', ...
												'Description',						'forDwi', ...
												'CorrespondingSeriesDescription',	'AP_FMAP_for DIFFUSION');
											% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.epi
											%		https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#fieldmap-data

	BMP_VCI.BIDS.DICOM2BIDS.DWI_fmapPA = struct('DataType',							'fmap', ...
												'Modality',							'epi', ...
												'PhaseEncodingDirection',			'PA', ...
												'HasMultipleVolumes',				'yes', ...
												'EachVolumeAsSeparate3D',			'no', ...
												'AllVolumesAsSingle4D',				'yes', ...
												'Description',						'forDwi', ...
												'CorrespondingSeriesDescription',	'PA_FMAP_for DIFFUSION');
											% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.epi
											%		https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#fieldmap-data

	BMP_VCI.BIDS.DICOM2BIDS.ASL = struct(	'DataType',								'perf', ...
											'Modality',								'asl', ...
											'HasMultipleVolumes',					'yes', ...
											'EachVolumeAsSeparate3D',				'no', ...
											'AllVolumesAsSingle4D',					'yes', ...
											'CorrespondingSeriesDescription',		'asl_3d_tra_p2_iso_3mm_highres');


	BMP_VCI.BIDS.DICOM2BIDS.CVR_fmap = struct(	'DataType',							'fmap', ...
												'Modality',							'epi', ...
												'Description',						'forCvr', ...
												'CorrespondingSeriesDescription',	'gre_field_mapping 3.8mm'); % Unsure about this fmap.
																												% Assuming it is 'pepolar' fieldmap.
																												% Ref : https://bids-specification.readthedocs.io/en/stable/04-modality-specific-files/01-magnetic-resonance-imaging-data.html#case-4-multiple-phase-encoded-directions-pepolar

	BMP_VCI.BIDS.DICOM2BIDS.CVR = struct(	'DataType',								'func', ...
											'Modality',								'bold', ...
											'Description',							'co2cvr', ...
											'HasMultipleVolumes',					'yes', ...
											'EachVolumeAsSeparate3D',				'no', ...
											'AllVolumesAsSingle4D',					'yes', ...
											'CorrespondingSeriesDescription',		'CVR_ep2d_bold 3.8mm TR1500 adaptive');


	BMP_VCI.BIDS.DICOM2BIDS.MP2RAGE_unit1 = struct(	'DataType',							'anat', ...
													'Modality',							'UNIT1', ...
													'CorrespondingSeriesDescription',	't1_mp2rage_sag_0.8x0.8x2_UNI_Images', ...
													'IsDerivatives',					'yes', ...
													'Software',							'Siemens'); 
													% Ref : https://bids-specification.readthedocs.io/en/stable/glossary.html#objects.suffixes.UNIT1
													%		https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html#quantitative-maps-are-derivatives

	BMP_VCI.BIDS.DICOM2BIDS.MP2RAGE_t1map = struct(	'DataType',							'anat', ...
													'Modality',							'T1map', ...
													'CorrespondingSeriesDescription',	't1_mp2rage_sag_0.8x0.8x2_T1_Images', ...
													'IsDerivatives',					'yes', ...
													'Software',							'Siemens');
													% Ref : https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html#quantitative-maps-are-derivatives

	BMP_VCI.BIDS.DICOM2BIDS.MP2RAGE_inv1 = struct(	'DataType',							'anat', ...
													'Modality',							'MP2RAGE', ...
													'Inversion',						'1', ...
													'CorrespondingSeriesDescription',	't1_mp2rage_sag_0.8x0.8x2_INV1');
													% Ref : https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html

	BMP_VCI.BIDS.DICOM2BIDS.MP2RAGE_inv2 = struct(	'DataType',							'anat', ...
													'Modality',							'MP2RAGE', ...
													'Inversion',						'2', ...
													'CorrespondingSeriesDescription',	't1_mp2rage_sag_0.8x0.8x2_INV2');
													% Ref : https://bids-specification.readthedocs.io/en/stable/appendices/qmri.html

	BMP_VCI.BIDS.DICOM2BIDS.DCE = struct(	'DataType',								'anat', ...
											'Modality',								'T1w', ...
											'ContrastEnhancingAgent',				'gd', ...
											'HasMultipleVolumes',					'yes', ...
											'EachVolumeAsSeparate3D',				'no', ...
											'AllVolumesAsSingle4D',					'yes', ...
											'CorrespondingSeriesDescription',		't1_vibe_sag_DCE_2mm XL FOV 40s temporal res');
											% Ref : https://bids-specification.readthedocs.io/en/latest/appendices/entities.html#ce
											% Note - not much info on DCE is found in BIDS specification. Modify when more info is found.

	

	BMP_VCI.BIDS.individualOriginalDicomDirectory = individual_original_DICOM_directory;
	BMP_VCI.BIDS.individualBmpDicomDirectory = fullfile(fileparts(individual_original_DICOM_directory),'DICOM_BMP');

	BMP_VCI.BIDS.subject_label = BIDS_subject_label;

	BMP_VCI.BIDS.cohortBIDSdirectory  = cohort_BIDS_directory;
	BMP_VCI.BIDS.individualBIDSdirectory = fullfile (BMP_VCI.BIDS.cohortBIDSdirectory, ['sub-' BMP_VCI.BIDS.subject_label]);

	if nargin == 4 && strcmp (varargin{1}, 'notRunningDicomCollection')
		fprintf ('%s : Not running dicomCollection.\n', mfilename);
	else
		BMP_VCI.BIDS.dicomCollection = dicomCollection (individual_original_DICOM_directory, "IncludeSubfolders", true); 	% Note that DICOM folder is used
																												% as input, instead of DICOMDIR
																												% file. This is because output
																												% from dicomCollection with DICOMDIR
																												% will miss some series.
	end

	BMP_VCI.BIDS.stringInFilenamesInDicomCollectionstrToBeReplaced = '/home/jiyang/Work';
	BMP_VCI.BIDS.stringInFilenamesInDicomCollectionstrToReplaceTo  = '/data/vci/pilotPS';

end