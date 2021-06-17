function maps = IVIMmodelfit_spm(im,bvals,fittype,roi,opts)
% function maps = IVIMmodelfit(im,bvals,fittype,roi,opts)
% maps = IVIMmodelfit(im,bvals,fittype,roi,opts)
% IVIMmodelfit(im,bvals)
% 
% Wrapper for monoexponential or stepwise biexponential least-squares 
% fitting, and biexponential bayesian fitting to diffusion weighted MR 
% data. 
%
% Input
% - im is a 4D matrix with b-values representing the 4th dimension, or 
%   the path to a nifti file containing the corresponding data. It contains 
%   the diffusion weighted image data
% - bvals is vector or a path to an FSL-style (space separated) text file 
%   containing the b-values used to obtain the data in im
% - fittype is a string the determines which type of fitting that is used.
%   "seg" (default) gives least-squares fitting while "bayes" gives
%   bayesian fitting
% - roi is a 3D matrix matching im or a path to a nifti file with the
%   corresponding data. It is use to mask out data of interest from im
%   (e.g. a brain mask or a tumor roi). This is recommended for
%   computational speed. roi = [] or roi = '' corresponds to no mask (i.e. 
%   fitting in all voxels)
% - opts is a struct used to set additional options (suitable default 
%   values are provided for all these).
%   * Common: lim (parameter limits in a 2x4 matrix with order [D,S0,f,D*], 
%             see IVIM_seg for advanced use), outfile (name of nifti file
%             containing the parameter maps)
%   * seg:    bthr,dispprog (see IVIM_seg)
%   * bayes:  its, burns, rician, meanonly, prior (see IVIM_bayes)
%   
% - blim is a scalar that determines the b-values used in the first of the 
%   fits (b == blim is included)
% - disp_prog is a scalar boolean. If it is set to "true" the progress of
%   the model fit is printed to the command window
% 
% Output
% - maps is a 4D matrix containing the estimated parameter maps. If im 
%   points out a nifti file, the results are also written to a nifti file
%
% Example
%
% im = "IVIMdata.nii.gz";
% mask = "IVIMdata_mask.nii.gz";
% bvals = "bvals.txt";
% fittype = "seg"; 
% opts.bthr = 200;
% opts.dispprog = false;
% opts.outfile = "IVIMmaps";
% IVIMmodelfit(im,bvals,fittype,mask,opts);
%
%
% By Oscar Jalnefjord 2020-08-04
% 
% If you use this function in research, please cite ref 1 if you use 
% least-squares fitting and ref 2 if you use bayesian fitting:
% [1] Jalnefjord et al. 2018 Comparison of methods for estimation of the 
%     intravoxel incoherent motion (IVIM) diffusion coefficient (D) and 
%     perfusion fraction (f), MAGMA
% [2] Gustafsson et al. 2017 Impact of prior distributions and central 
%     tendency measures on Bayesian intravoxel incoherent motion model 
%     fitting, MRM

%%%%%%%%%%%%%%%%%%%%%
% First input check %
%%%%%%%%%%%%%%%%%%%%%
fittypes = {'seg','bayes'};
if nargin < 3
    fittype = fittypes{1};
else
    if isstring(fittype)
        fittype = char(fittype);
    end
    if ischar(fittype)
        if ~any(strcmp(fittype,fittypes))
            error('Unknown fit type: %s',fittype);
        end
    else
        error('fittype must be a character string');
    end
end

%%%%%%%%%%%%%%
% Check opts %
%%%%%%%%%%%%%%
options = {'bthr','lim','dispprog','its','burns',...
           'rician','meanonly','prior','outfile'};
if isstruct(opts)
    opts_fields = fieldnames(opts);
    for i = 1:length(opts_fields)
        if ~any(strcmp(opts_fields{i},options))
            error('Unknown field "%s" in struct opts',opts_fields{i});
        end
    end
else
    error('opts must be a struct');
end

%%%%%%%%%%%%%%%%%%%
% Read from files %
%%%%%%%%%%%%%%%%%%%
w2f = false; % write results to file
if isstring(im)
    im = char(im);
    [pat, tit, ext] = fileparts(im);
end
if ischar(im)
    [pat, tit, ext] = fileparts(im);
    w2f = true;
    % read b-values
    if isstring(bvals)
        bvals = char(bvals);
    end
    if ischar(bvals)
        try
            fid = fopen(bvals);
            b = fscanf(fid,'%f ');
            fclose(fid);
        catch
            error('Unable to read b-values from file: %s',bvals);
        end
    else
        error('bvals must be a character string');
    end
    
    % read image file
    imfile = im;
    try
%         info = niftiinfo(im);
%         im = niftiread(info);
        V = spm_vol(im);
        im = spm_read_vols(V);
    catch
        error('Unable to read image from file: %s',imfile);
    end
    
    % read roi file
    if nargin > 3
        roifile = roi;
        try
            roi = logical(spm_read_vols(spm_vol(roifile)));
        catch
            error('Unable to read roi from file: %s',roifile);
        end
    end
else % should be array
    if ~isnumeric(im)
        error('im must be a character string or a numeric array');
    end
    if isnumeric(bvals)
        b = bvals;
    else
        error('b must be a numeric vector if im is');
    end
    if nargin < 3
        if ~isnumeric(roi)
            error('roi must be a numeric array if im is');
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%
% Check input arrays %
%%%%%%%%%%%%%%%%%%%%%%

% im should be 4D array
d = size(im);
if length(d) ~= 4
    error('The image must have 4 dimensions');
end

% b should be vector with length equal to 4th dimension of im
if isvector(b)
    if length(b) ~= d(4)
        error('Number of b-values in b must equal the size of the 4th dimension of the image');
    end
else
    error('The b-values must be contained in a vector');
end

% roi should be 
if nargin < 4
    roi = true(d(1:3));
else
    if ~isequal(size(roi),d(1:3))
        error('The ROI must have the same size as the first three dimensions of the image');
    end
end

%%%%%%%%%%%%%%%%%
% Run model fit %
%%%%%%%%%%%%%%%%%

% Turn image into data matrix
Y = im2Y(im,roi);

% Define which parameters to estimate
pars = {'D','S0','f','Dstar'};
lim = [0 0 0 0;3e-3 2*max(Y(:)) 1 1];
blim = 200;
dispprog = true;

n = 10000;
burns = 2000;
rician = false;
meanonly = false;
prior = {'flat','lognorm','lognorm','flat','reci'};
fstart = 0.1*ones(size(Y(:,1)));
Dstart = 1e-3*ones(size(Y(:,1)));
Dstarstart = 20e-3*ones(size(Y(:,1)));

% Run model fit
switch fittype
    case fittypes{1} % segmented
        if any(strcmp('bthr',opts_fields))
            blim = opts.bthr;
        end
        if any(strcmp('dispprog',opts_fields))
            dispprog = opts.dispprog;
        end
        res = IVIM_seg(Y,b,lim,blim,dispprog);
    case fittypes{2} % Bayesian
        if any(strcmp('its',opts_fields))
            n = opts.its;
        end
        if any(strcmp('burns',opts_fields))
            burns = opts.burns;
        end
        if any(strcmp('rician',opts_fields))
            rician = opts.rician;
        end
        if any(strcmp('meanonly',opts_fields))
            meanonly = opts.meanonly;
        end
        if any(strcmp('prior',opts_fields))
            prior = opts.prior;
        end
        res = IVIM_bayes(Y,fstart,Dstart,Dstarstart,mean(Y(:,b==min(b)),2),b,lim(:,[3 1 4 2]),n,rician,prior,burns,meanonly);
end

%%%%%%%%%%%%%%%%%%
% Prepare output %
%%%%%%%%%%%%%%%%%%

maps = nan([size(roi) length(pars)]);
for i = 1:length(pars)
    temp = maps(:,:,:,i);
    switch fittype
        case fittypes{1} % Segmented
            temp(roi) = res.(pars{i});
        case fittypes{2} % Bayesian
            if meanonly
                temp(roi) = res.(pars{i}).mean;
            else
                temp(roi) = res.(pars{i}).mode;
            end
    end
    maps(:,:,:,i) = temp;
end

if w2f
    % check if output 
    if strcmp(imfile(end-2:end),'.gz')
        comp = true;
    else
        comp = false;
    end
%     info.Description = 'IVIM parameter maps';
%     info.ImageSize(4) = length(pars);
%     info.Datatype = 'double';
%     info.BitsPerPixel = 64;
%     info.raw.datatype = 64;
%     info.raw.bitpix = 64;
%     
    outfile = 'IVIMmaps';
    if any(strcmp('outfile',opts_fields))
        outfile = char(opts.outfile);
    end
    if endsWith(outfile,'.nii')
        outfile = outfile(1:end-4);
    elseif endsWith(outfile,'.nii.gz')
        outfile = outfile(1:end-7);
    end
    
%     try
%         outfile = fullfile(pat, outfile);
%         paraNames = {'D', 'S0', 'f', 'Dstar'};
% %         niftiwrite(maps,outfile,info,'Compressed',comp);
%         for i_a = 1:size(maps, 4)
%            Vi = V(1);
%            Vi.fname = strrep(outfile, '.nii', ['_', paraNames{i_a}, '.nii']);
%            Vi.dt = [16, 0];
%            Vi = spm_create_vol(Vi);
%            
%            spm_write_vol(Vi, maps(:, :, :, i_a));
%         end
%     catch e
%         error(['Failed to write parameter maps to file with call: ' ...
%             'niftiwrite(maps,"%s",info,"Compressed",%s);\n\nError message: %s'],outfile,mat2str(comp),e.message);
%     end

    outfile = fullfile(pat, outfile);
    paraNames = {'D', 'S0', 'f', 'Dstar'};
%         niftiwrite(maps,outfile,info,'Compressed',comp);
    for i_a = 1:size(maps, 4)
       Vi = V(1);
       Vi.fname = [outfile, '_', paraNames{i_a}, '.nii'];
       Vi.dt = [16, 0];
       Vi = spm_create_vol(Vi);

       spm_write_vol(Vi, maps(:, :, :, i_a));
    end
end
    