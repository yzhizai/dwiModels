function cfg_run_IVIM(job)


im = job.Img{1}; % can be 4D matrix
mask = job.Msk{1}; % empty ([] or '') means no mask
bvals = job.Bval{1}; % can be vector matching 4th dimension of im
fittype = job.fittype; % 'seg' or 'bayes', default 'seg'

% additional options specific for the fittype and if file input is used
opts.bthr = job.bthr; % threshold for segmented fitting = 200 s/mm2
opts.outfile = job.outfile;

% run model fit
% IVIMmodelfit(im,bvals,fittype,mask,opts);
IVIMmodelfit_spm(im,bvals,fittype,mask,opts);