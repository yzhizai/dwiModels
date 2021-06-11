function out = cfg_run_DKI(job)

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
x22 = zeros(size(Y(:, :, :, 1)));

for i_a = 1:size(Y_log, 4)
   x11_i = Y_log(:, :, :, i_a)*coef(1, i_a); 
   
   x11 = x11 + x11_i;
   
   x22_i = Y_log(:, :, :, i_a)*coef(2, i_a);
   
   x22 = x22 + x22_i;
end

D = x11;
K = x22./x11.^2;

D(D<0) = NaN;
K(K<0) = NaN;

[pat, tit, ext] = fileparts(im);
outName_D = fullfile(pat, [tit, '_', outName, '_D', ext]);
outName_K = fullfile(pat, [tit, '_', outName, '_K', ext]);

V_D = V(1);
V_D.dt = [16, 0];

V_K = V(1);
V_K.dt = [16, 0];

V_D.fname = outName_D;
V_K.fname = outName_K;

spm_create_vol(V_D);
spm_create_vol(V_K);

spm_write_vol(V_D, D);
spm_write_vol(V_K, K);