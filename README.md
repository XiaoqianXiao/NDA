# NDA Data Processing Scripts

This repository contains scripts for processing and formatting research data for submission to the National Database for Autism Research (NDA).

## Overview

The project consists of two main Jupyter notebooks that transform research data from REDCap and BIDS formats into NDA-compliant CSV files.

## Quick Start: Step-by-Step Workflow

Follow these steps in order to process your data for NDA submission:

### Step 0: Generate GUIDs (if not already done)

**Purpose**: Generate Global Unique Identifiers (GUIDs) for all subjects. GUIDs are required for NDA submission and must be generated before processing data.

**Required Files**:

1. **IFOCUS Subject and Phone Screen Log**:
   - Location: iFOCUS SharePoint
   - Contains: Subject names
   - This file is used to match subjects with their identifiers

2. **Demo CSV from REDCap**:
   - Location: Export from REDCap
   - Contains: 
     - `COB` (City of Birth)
     - `DOB` (Date of Birth)
   - This file provides demographic information needed for GUID generation

**Process**:
1. Download the IFOCUS Subject and Phone Screen Log from iFOCUS SharePoint
2. Export the demo CSV from REDCap containing COB and DOB fields
3. **Feed all information into NDA GUID Client** to generate GUIDs:
   - Use the NDA GUID Client application/tool
   - Input the subject information from both files
   - The GUID Client will generate unique identifiers for each subject
4. Save the output as `GUID_NoHIPinfo.csv` with columns: `ID` and `GUID`
5. Ensure the `ID` column matches the subject IDs used in your REDCap data

**Important Notes**:
- **HIPAA Compliance**: All HIPAA-protected information (including subject names, DOB, COB) must be kept on SharePoint only. Do not store this information on local computers, shared drives, or other locations outside of SharePoint.
- GUIDs must be generated through NDA's official GUID Client process
- The `GUID_NoHIPinfo.csv` file will be used in Step 4 to map subject IDs to GUIDs
- The `GUID_NoHIPinfo.csv` file should contain only `ID` and `GUID` columns (no HIPAA-protected information)
- Without valid GUIDs, the `subjectkey` field cannot be populated, and data cannot be shared

### Step 1: Download Data from REDCap

1. **Export questionnaire data from REDCap**:
   - Log into your REDCap project
   - For each questionnaire/assessment, export the data as CSV
   - Save all CSV files to a local directory (you'll organize them in Step 3)

2. **Export subject metadata**:
   - Export `IFOCUSS_SubInfo.csv` containing subject demographics
   - Ensure you have `GUID_NoHIPinfo.csv` (generated in Step 0) containing GUID mappings for subjects

3. **Verify you have the following files**:
   - Subject metadata CSV files
   - CSV exports for each questionnaire (GAD7, PHQ9, DSM5, WHODAS, SCID, LSAS, SDS, QIDS, PSWQ, HARS, BABS, Rumination)
   - `NDA_REDCap_matches.xlsx` (column name mapping file)

### Step 2: Set Up Directory Structure

Create the following directory structure on your local machine:

```
NDA_dir/
├── sumission_YYYYMMDD/          # Replace YYYYMMDD with your submission date
│   ├── demo/
│   │   ├── IFOCUSS_SubInfo.csv
│   │   └── GUID_NoHIPinfo.csv
│   ├── CSV_from_Redcap/
│   │   └── [place REDCap CSV exports here]
│   └── filled/                   # Output directory (created automatically)
│       └── [NDA-compliant CSV files will be generated here]
├── data_structure_templates/
│   └── approved/
│       └── [NDA template CSV files - one per questionnaire]
└── data_structure_defination/
    └── [NDA definition CSV files]
```

**Action items**:
- Create the directory structure
- Move your REDCap CSV exports to `CSV_from_Redcap/`
- Place subject metadata files in `demo/`
- Ensure NDA template files are in `data_structure_templates/approved/`

### Step 3: Process Image Data (if applicable)

**Note**: This step runs on Hyak (UW computing cluster) where the BIDS imaging data is stored.

1. **Set up on Hyak**:
   - Ensure your BIDS-formatted NIfTI files are accessible on Hyak
   - Verify you have `image03_definitions.csv` in your definitions directory

2. **Run `extract_image_info.ipynb`**:
   - Open the notebook on Hyak
   - Update configuration in the first cell:
     - Set `project_root` to your BIDS data directory
     - Set `definitions_dir` to directory containing `image03_definitions.csv`
     - Set `output_csv_path` to where you want the output saved
   - Run all cells sequentially
   - The notebook will generate `NDA_image03_extracted.csv`

3. **Transfer image metadata to local machine**:
   ```bash
   rsync -a -e "ssh -o IPQoS=throughput" [username]@klone.hyak.uw.edu:[remote_path]/NDA_image03_extracted.csv [local_path]/sumission_YYYYMMDD/
   ```
   
   Replace:
   - `[username]` with your Hyak username
   - `[remote_path]` with the path where the file was generated on Hyak
   - `[local_path]` with your local NDA directory path
   - `YYYYMMDD` with your submission date

4. **Verify the file**:
   - Check that `NDA_image03_extracted.csv` is in your submission directory
   - The file will be used in Step 4

### Step 4: Process Questionnaire Data

1. **Open `check_questionare_names.ipynb`** in Jupyter

2. **Install dependencies** (if not already installed):
   ```bash
   pip install pandas openpyxl numpy
   ```

3. **Update configuration** in the first cells:
   - Set `NDA_dir` to your base NDA directory path
   - Set `version` to your submission version (e.g., 'sumission_20260115')
   - Verify that `template_dir` points to your templates directory
   - Verify that `defination_dir` points to your definitions directory

4. **Verify file paths**:
   - Check that `meta_file_path` points to `IFOCUSS_SubInfo.csv`
   - Check that `GUID_file_path` points to `GUID_NoHIPinfo.csv`
   - Verify `redcap_file_dir` points to `CSV_from_Redcap/`
   - Verify `match_file_path` points to `NDA_REDCap_matches.xlsx`

5. **Run all cells sequentially**:
   - The notebook will process each questionnaire one by one
   - Each questionnaire will generate a CSV file in the `filled/` directory
   - Monitor for any errors or warnings

6. **Verify outputs**:
   - Check the `filled/` directory for all expected CSV files
   - Each questionnaire should have a corresponding output file
   - Verify file sizes are reasonable (not empty)

### Step 5: Review and Validate Output

1. **Verify required elements** (CRITICAL - data cannot be shared without these):
   - **`subjectkey`**: Must be present and populated in every file
   - **`src_subject_id`**: Must be present and populated in every file
   - **`interview_date`**: Must be present, in MM/DD/YYYY format, and populated in every file
   - **`interview_age`**: Must be present, calculated in months, and populated in every file
   - **Action**: Open each CSV file and verify these four columns exist and have no missing values

2. **Check output files**:
   - Open each CSV file in the `filled/` directory
   - Verify data looks correct
   - Check that dates are in MM/DD/YYYY format
   - Verify missing values use correct codes (-9, -99, 555, 999)

3. **Common checks**:
   - Subject IDs match between files
   - GUIDs are populated correctly and match across files
   - Interview ages are calculated (in months) and consistent with interview dates
   - No unexpected missing data in required fields
   - All required questionnaires are present

4. **Ready for submission**:
   - All files in `filled/` directory are ready for NDA upload
   - All required elements are present and populated in every file
   - Verify file naming matches NDA requirements
   - **Final check**: Ensure no missing values in `subjectkey`, `src_subject_id`, `interview_date`, or `interview_age` across all files

---

## Scripts Reference

### 1. `check_questionare_names.ipynb`

**Purpose**: Processes questionnaire and clinical assessment data from REDCap and converts it to NDA-compliant format.

**Processes the following questionnaires**:
- `ndar_subject01`: Subject demographics
- `cde_gad701`: Generalized Anxiety Disorder 7-item scale
- `cde_phq901`: Patient Health Questionnaire-9
- `cde_dsm5crossad01`: DSM-5 Cross-Cutting Symptom Measure
- `cde_whodas01`: WHO Disability Assessment Schedule
- `scidv_rv01`: Structured Clinical Interview for DSM-5
- `lsas01_sr`: Liebowitz Social Anxiety Scale (Self-Report)
- `lsas01_cr`: Liebowitz Social Anxiety Scale (Clinician-Rated)
- `sds01`: Sheehan Disability Scale
- `qids01`: Quick Inventory of Depressive Symptomatology
- `pswq01`: Penn State Worry Questionnaire
- `hars01`: Hamilton Anxiety Rating Scale
- `babs01`: Brown Assessment of Beliefs Scale
- `rumination01`: Rumination Response Scale
- `image03`: Neuroimaging metadata

**Key Features**:
- Calculates `interview_age` in months from date of birth and interview date
- Handles missing values according to NDA specifications (e.g., -9, -99, 555)
- Maps categorical values (e.g., phenotype descriptions, race codes)
- Formats dates to MM/DD/YYYY format
- Merges GUIDs from metadata files
- Applies data type conversions based on NDA definitions

**Input Files**:
- `IFOCUSS_SubInfo.csv`: Subject metadata
- `GUID_NoHIPinfo.csv`: GUID mappings
- `NDA_REDCap_matches.xlsx`: Column name mappings (one sheet per questionnaire)
- REDCap CSV exports (one per questionnaire)
- NDA template CSV files (from `approved` directory)
- `NDA_image03_extracted.csv`: Image metadata file (generated by `extract_image_info.ipynb` on Hyak)

**Output**: CSV files in `filled` directory, one per questionnaire

---

### 2. `extract_image_info.ipynb`

**Purpose**: Extracts metadata from BIDS-formatted NIfTI neuroimaging files and converts it to NDA image03 format.

**Functionality**:
- Scans directory tree for NIfTI files (`.nii`, `.nii.gz`)
- Extracts metadata from BIDS JSON sidecar files
- Maps BIDS metadata to NDA image03 fields
- Identifies scan types (structural, functional, field maps, etc.)
- Calculates image dimensions, resolution, and orientation
- Filters out localizer/scout scans

**Key Features**:
- Extracts subject ID and visit from BIDS filename patterns (`sub-*`, `ses-*`)
- Calculates image orientation (Axial, Coronal, Sagittal) from DICOM vectors
- Maps BIDS scan types to NDA scan types:
  - Structural: MPRAGE, FLASH, MP2RAGE, T1, T2, FLAIR, PD
  - Functional: fMRI
  - Field maps: Field Map
  - Diffusion: MR diffusion
- Handles 3D and 4D images (with time dimension)
- Extracts scanner information (manufacturer, model, software versions)
- Sets default values for structural scans (176x256x256 mm FOV, 1mm resolution)

**Input Files**:
- BIDS-formatted NIfTI files with JSON sidecar files
- `image03_definitions.csv`: NDA field definitions and data types

**Output**: `NDA_image03_extracted.csv` with all extracted image metadata

**Note**: This notebook is designed to run on Hyak (UW computing cluster) where the BIDS data is stored. The output file needs to be transferred to your local computer for use with `check_questionare_names.ipynb`.

**Filters**:
- Excludes localizer/scout/setter scans
- For T1w structural scans, only processes files with `desc-defaced` tag
- Excludes T2 structural scans from final output

---

## Dependencies

Required Python packages:
- `pandas`: Data manipulation and CSV processing
- `openpyxl`: Reading Excel mapping files
- `numpy`: Numerical operations (for image orientation calculations)
- `json`: Parsing BIDS JSON metadata files (built-in)

Install dependencies:
```bash
pip install pandas openpyxl numpy
```

Or using Poetry (if configured):
```bash
poetry install
```

---

## Data Processing Details

### Required Elements for All Data Structures

**Critical**: The following elements are **required** for all NDA data structures. If any of these are missing, your data **will not be able to be shared** through NDA:

- `subjectkey`: Global Unique Identifier (GUID) for the subject
- `src_subject_id`: Source subject identifier
- `interview_date`: Date of the interview/assessment (format: MM/DD/YYYY)
- `interview_age`: Age at time of interview in months

**Important Notes**:
- These fields must be present and populated in **every** data structure file
- Missing values in these required fields will cause NDA to reject the submission
- The scripts automatically populate these fields, but always verify they are present before submission
- `subjectkey` (GUID) must match across all files for the same subject
- `interview_date` and `interview_age` must be consistent (age should match the date)

### Age Calculation
Interview age is calculated in months with specific rounding rules:
- Age is rounded to chronological month
- 15 days = 0 months
- 16 days = 1 month

### Missing Value Handling
Different questionnaires use different missing value codes:
- `-9`: Missing (GAD7, PHQ9, DSM5, WHODAS, LSAS, BDD)
- `-99`: Missing (SCID MDD)
- `555`: Missing (SCID BDD past month)
- `999`: Missing (QIDS)

### Date Formatting
All dates are converted to `MM/DD/YYYY` format for NDA submission.

### Image Metadata Extraction
- Extracts DICOM metadata from BIDS JSON files
- Calculates image dimensions from shape data or acquisition matrix
- Determines voxel resolution from pixel spacing and slice thickness
- Identifies image orientation from DICOM ImageOrientationPatient vectors

---

## Troubleshooting

**Common Issues**:

1. **File not found errors**: 
   - Verify all paths in configuration cells match your directory structure
   - Check that file names match exactly (case-sensitive)
   - Ensure all required files are in the correct directories

2. **Column mapping errors**: 
   - Check that REDCap column names match those in `NDA_REDCap_matches.xlsx`
   - Verify the Excel file has a sheet for each questionnaire
   - Ensure column names haven't changed in REDCap exports

3. **Date parsing warnings**: 
   - Dates are parsed flexibly, but ensure consistent formats
   - Check that date columns contain valid date values
   - Verify date formats in REDCap exports

4. **Missing GUIDs**: 
   - **If GUIDs haven't been generated yet**: Follow Step 0 to generate GUIDs using the IFOCUS Subject and Phone Screen Log (from SharePoint) and demo CSV (from REDCap with COB and DOB)
   - Verify that `GUID_NoHIPinfo.csv` exists and contains both `ID` and `GUID` columns
   - Verify that subject IDs in REDCap data match those in `GUID_NoHIPinfo.csv`
   - Check for leading/trailing spaces in subject IDs
   - Ensure the ID column name matches between files
   - If GUIDs are missing for some subjects, you may need to regenerate GUIDs with complete information

5. **Image processing errors**:
   - Verify BIDS file naming conventions are followed
   - Check that JSON sidecar files exist for each NIfTI file
   - Ensure file paths are accessible on Hyak

6. **Empty output files**:
   - Check that input CSV files contain data
   - Verify subject IDs match between metadata and questionnaire files
   - Check for filtering that might exclude all rows

7. **Missing required elements**:
   - **Critical**: If `subjectkey`, `src_subject_id`, `interview_date`, or `interview_age` are missing, data cannot be shared
   - Verify these columns exist in all output files
   - Check that GUID mapping worked correctly (subjectkey should be populated)
   - Ensure interview_date is in the correct format and not missing
   - Verify interview_age was calculated correctly (should be in months)
   - If any required field is missing, check the input data and mapping files

---

## Submission History

### Submission Version: 20260115

**Excluded Subjects**:
- **Subjects 306, 316, 321**: Excluded from submission due to missing Date of Birth (DOB) information
- **Subject 2001LH**: Excluded from submission due to lack of interview date

**Notes**:
- These subjects were automatically excluded during processing because they lacked required elements (`interview_date` or date of birth needed for `interview_age` calculation)
- Without DOB, `interview_age` cannot be calculated, which is a required field for all data structures
- Without interview date, the required `interview_date` field cannot be populated
- Always verify excluded subjects are intentional and document the reasons for exclusion

---

## Notes

- **HIPAA Compliance**: All HIPAA-protected information (subject names, DOB, COB, etc.) must be kept on SharePoint only. Do not store this information on local computers, shared drives, or other locations outside of SharePoint.
- **GUIDs must be generated before processing data** (see Step 0). All information is fed into the NDA GUID Client to generate GUIDs. Required files: IFOCUS Subject and Phone Screen Log (from SharePoint) and demo CSV from REDCap (with COB and DOB)
- Both scripts require specific directory structures and file naming conventions
- The mapping between REDCap and NDA columns is defined in `NDA_REDCap_matches.xlsx`
- Template files must be in the approved format from NDA
- Image processing filters out localizer scans and non-defaced T1w images
- All output files follow NDA submission requirements
- Always verify outputs before submitting to NDA
