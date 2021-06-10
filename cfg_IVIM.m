function IVIM = cfg_IVIM

Img = cfg_files;
Img.name = 'Image: ';
Img.tag = 'Img';
Img.num = [0, 1];
Img.help = {'Choose a 4D DWI file'};

Msk = cfg_files;
Msk.name = 'Mask: ';
Msk.tag = 'Msk';
Msk.num = [0, 1];
Msk.help = {'Choose the corresponding mask file'};

Bval = cfg_files;
Bval.name = 'b value: ';
Bval.tag = 'Bval';
Bval.num = [0, 1];
Bval.filter = {'txt'};
Bval.help = {'Choose the bval text file'};

fitType = cfg_menu;
fitType.name = 'Fit type: ';
fitType.tag = 'fittype';
fitType.labels = {'seg', 'bayes'};
fitType.values = {'seg', 'bayes'};
fitType.help = {'Choose the fit method'};

thr = cfg_entry;
thr.name = 'bval threshold: ';
thr.tag = 'bthr';
thr.num = [1, 1];
thr.strtype = 'i';
thr.help = {'Define the b threshold'};

outfile = cfg_entry;
outfile.name = 'outName: ';
outfile.tag = 'outfile';
outfile.strtype = 's';
outfile.num = [1, 100];
outfile.help = {'The outname of the output parameter files'};

IVIM = cfg_exbranch;
IVIM.name = 'IVIM module';
IVIM.tag = 'ivim';
IVIM.val = {Img, Msk, Bval, fitType, thr, outfile};
IVIM.prog = @cfg_run_IVIM;
IVIM.help = {'Fitting the IVIM parameters using seg or bayes method'};






