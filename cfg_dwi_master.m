function cfg = cfg_dwi_master

DWI1 = cfg_repeat;
DWI1.name = 'IVIM analysis';
DWI1.tag = 'ivim_analysis';
DWI1.values = {cfg_IVIM};
DWI1.forcestruct = true;
DWI1.help = {'IVIM analysis using seg or bayes methods'};

DWI2 = cfg_repeat;
DWI2.name = 'DKI analysis';
DWI2.tag = 'dki_analysis';
DWI2.values = {cfg_DKI};
DWI2.forcestruct = true;
DWI2.help = {'DKI analysis using QR methods'};

DWI0 = cfg_repeat;
DWI0.name = 'ADC analysis';
DWI0.tag = 'adc_analysis';
DWI0.values = {cfg_ADC};
DWI0.forcestruct = true;
DWI0.help = {'DKI analysis using QR methods'};

cfg = cfg_repeat;
cfg.name = 'DWI Analysis';
cfg.tag = 'dwiAna';
cfg.values = {DWI0, DWI1, DWI2};
cfg.forcestruct = true;
cfg.help = {'A bundle of DWI analysis modules'};