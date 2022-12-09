dset = 'ADNI';

% TP-W530
DICOM_directory  = '/sandbox/adni_examples/dicom';
BIDS_directory = '/sandbox/adni_examples/bids';


% MacBook
DICOM_directory  = '/Users/z3402744/Work/ADNI_test';
BIDS_directory   = '/Users/z3402744/Work/ADNI_test/BIDS';

switch dset

	case 'ADNI'

		ADNI = bmp_ADNI ('retrieve');

		[~] = bmp_BIDSgenerator (dataset, DICOM2BIDS, DICOM_directory, BIDS_directory);

		dicom2niix = bmp_ADNI ('dcm2niix');

		system (['dcm2bids_scaffold --output_dir ' BIDS_directory]);  % dcm2bids to generate additional BIDS files.

end