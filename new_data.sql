set search_path to mimiciii;

DROP TABLE IF EXISTS new_data;
CREATE TABLE new_data AS
SELECT a.subject_id, a.hadm_id, a.insurance, a.marital_status, a.discharge_location,
       i.icustay_id, i.gender, i.ethnicity, i.admission_type, i.los_hospital, i.los_icu,
       i.hospstay_seq, i.first_hosp_stay, i.icustay_seq, i.first_icu_stay,
       hw.height_first, hw.weight_first,
       o.oasis, o.age, o.icustay_age_group, o.preiculos,
       e.congestive_heart_failure, e.cardiac_arrhythmias, e.valvular_disease, e.pulmonary_circulation, e.peripheral_vascular,
       e.hypertension, e.paralysis, e.other_neurological, e.chronic_pulmonary, e.diabetes_uncomplicated, e.diabetes_complicated,
       e.hypothyroidism, e.renal_failure, e.liver_disease, e.peptic_ulcer, e.aids, e.lymphoma, e.metastatic_cancer, e.solid_tumor,
       e.rheumatoid_arthritis, e.coagulopathy, e.obesity, e.weight_loss, e.fluid_electrolyte, e.blood_loss_anemia,
       e.deficiency_anemias, e.alcohol_abuse, e.drug_abuse, e.psychoses, e.depression
FROM admissions a
INNER JOIN icustay_detail i ON a.subject_id=i.subject_id
INNER JOIN heightweight hw ON a.subject_id=hw.subject_id
INNER JOIN oasis o ON a.subject_id=o.subject_id
INNER JOIN elixhauser_ahrq e ON a.subject_id=e.subject_id
WHERE a.subject_id IS NOT NULL
AND a.discharge_location='HOME'
AND o.icustay_age_group='adult'
AND o.oasis IS NOT NULL
AND e.metastatic_cancer=0;

\COPY (SELECT * FROM new_data) TO 'C:\Users\Shiya\Desktop\MIMIC-III\new_data.csv' WITH CSV
