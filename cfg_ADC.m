function ADC = cfg_ADC

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

ADC = cfg_exbranch;
ADC.name = 'ADC module';
ADC.tag = 'adc';
ADC.val = {Img, Msk, Bval, outfile};
ADC.prog = @cfg_run_ADC;
ADC.help = {'Fitting the ADC model'};






