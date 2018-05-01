	Total number of patients & # of admissions for each patient (N=46,520)
Drop table if exists admissioncount;
Create table admissioncount as
Select subject_id, count (*) as num_adm
From admissions
Group by subject_id;

	Subset of patients who have been admitted twice (N=10,320)
Drop table if exists readmission;
Create table readmission as
Select a.row_id, a.subject_id, a.hadm_id, 
            a.admittime, a.dischtime, 
            a.admission_type, discharge_location, 
            a.insurance, a.marital_status, a.ethnicity, 
            a. hospital_expire_flag,
            ac.num_adm
From admissions as a
Inner join admissioncount as ac
On a.subject_id = ac.subject_id
Where ac.num_adm=2
Order by a.subject_id;

	For each readmitted patient previously admitted EMERGENCY/URGENT/ELECTIVE & did not die in the hospital, join 2nd admission to 1st admission (N=4,899)
Drop table if exists readmitted;
Create table readmitted as
Select re1.row_id, re1.subject_id, 
            re1.hadm_id as disch_id, re2.hadm_id as readm_id,
            re1.dischtime as disch_time, re2.admittime as readm_time,
            re2.admittime – re1.dischtime as lag,
            re1.admission_type, re1.discharge_location,
            re1.insurance, re1.marital_status, re1.ethnicity,
            re1.hospital_expire_flag
From readmission re1
Inner join readmission re2
On re2.row_id=re1.row_id + 1
Where re2.subject_id = re1.subject_id
And re1.hospital_expire_flag =0
And re1.admission_type !='NEWBORN';        





	Join OASIS: age, icustay_age_group, oasis, preiculos
	Join ICUSTAY_DETAIL: gender, los_hospital, los_icu
	Join elixhauser_ahrq: …
	N=5,635
Drop table if exists temp;
Create table temp as
Select re.subject_id, re.disch_id, re.lag, re.admission_type, re.discharge_location, 
            re.insurance, re.marital_status, re.ethnicity,
            oa.icustay_age_group, oa.age, oa.oasis, oa.preiculos,
            i.gender, i.los_hospital, i.los_icu, i.icustay_seq,
            e.congestive_heart_failure, e.cardiac_arrhythmias, e.valvular_disease, 
            e.pulmonary_circulation, e.peripheral_vascular, e.hypertension, e.paralysis, e.other_neurological,   
            e.chronic_pulmonary, e.diabetes_uncomplicated, e.diabetes_complicated,
            e.hypothyroidism, e.renal_failure, e.liver_disease, e.peptic_ulcer, e.aids, e.lymphoma,    
            e.metastatic_cancer, e.solid_tumor, e.rheumatoid_arthritis, e.coagulopathy, e.obesity, 
            e.weight_loss, e.fluid_electrolyte, e.blood_loss_anemia, e.deficiency_anemias, e.alcohol_abuse,   
            e.drug_abuse, e.psychoses, e.depression
From readmitted re
Inner join oasis oa On re.disch_id=oa.hadm_id
Inner join icustay_detail i On re.disch_id=i.hadm_id
Inner join elixhauser_ahrq e On re.disch_id=e.hadm_id
Where oa.icustay_age_group='adult' 
And oa.oasis IS NOT NULL
And i.los_hospital IS NOT NULL
Order by re.subject_id;

\copy temp To 'C:/Users/Shiya/Desktop/MIMIC-III/Data/places.csv' DELIMITER ',' CSV HEADER;
