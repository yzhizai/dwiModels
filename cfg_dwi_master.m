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
DWI2.help = {'DKI analysis using seg or bayes methods'};

cfg = cfg_repeat;
cfg.name = 'DWI Analysis';
cfg.tag = 'dwiAna';
cfg.values = {DWI1, DWI2};
cfg.forcestruct = true;
cfg.help = {'A bundle of DWI analysis modules'};