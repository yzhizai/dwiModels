function DKI = cfg_DKI

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
Bval.name = 'b value:';
Bval.tag = 'Bval';
Bval.num = [0, 1];
Bval.filter = {'txt'};
Bval.help = {'Choose the bval text file'};

outfile = cfg_entry;
outfile.name = 'outName: ';
outfile.tag = 'outfile';
outfile.strtype = 's';
outfile.num = [1, 100];
outfile.help = {'The outname of the output parameter files'};

DKI = cfg_exbranch;
DKI.name = 'DKI module';
DKI.tag = 'dki';
DKI.val = {Img, Msk, Bval, outfile};
DKI.prog = @cfg_run_DKI;
DKI.help = {'Fitting the DKI model'};






