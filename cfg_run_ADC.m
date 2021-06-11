function out = cfg_run_ADC(job)

im = job.Img{1}; % can be 4D matrix
bvals = job.Bval{1}; % can be vector matching 4th dimension of im

outName = job.outfile;

% run model fit
V = spm_vol(im);
Y = spm_read_vols(V);
fid = fopen(bvals);
b = fscanf(fid,'%f ');
fclose(fid);

b = reshape(b, [], 1);

idx = b == 0;

Y_0 = repmat(Y(:, :, :, idx), 1, 1, 1, size(Y, 4));

Y_log = log(Y./Y_0);
Y_log(Y_log > 0) = NaN;
Y_log(isinf(Y_log)) = NaN;

X = [-b, b.^2/6];

[Xq, Xr] = qr(X, 0);
coef = Xr\Xq';

x11 = zeros(size(Y(:, :, :, 1)));

for i_a = 1:size(Y_log, 4)
   x11_i = Y_log(:, :, :, i_a)*coef(1, i_a); 
   
   x11 = x11 + x11_i;
end

D = x11;

[pat, tit, ext] = fileparts(im);
outName_D = fullfile(pat, [tit, '_', outName, '_D', ext]);

V_D = V(1);
V_D.fname = outName_D;

spm_create_vol(V_D);

spm_write_vol(V_D, D);