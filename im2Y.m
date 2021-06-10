function Y = im2Y(im,mask)
% Transforms functional image data (4D or 3D array) into 
% data matrix with size VxT where V is the number of 
% voxels and T is the number of elements in the functional
% dimensionon (e.g. time, TE, b-value). If a mask is supplied
% only voxels within the mask are extracted.

s = size(im);

if numel(s) > 2
    if nargin > 1
        V = sum(mask(:));
    else
        if numel(s) == 4
            V = numel(im(:,:,:,1));
        else
            V = numel(im(:,:,1));
        end
    end
    Y = zeros(V,s(end));
    for i = 1:s(end)
        if nargin > 1
            %mask_full = false([size(mask) s(end)]);mask_full(:,:,i) = mask;
            temp = im(:,:,:,i);
            temp = temp(mask);
        else
            if numel(s) == 4
                temp = im(:,:,:,i);
            else
                temp = im(:,:,i);
            end
        end
        Y(:,i) = temp(:);
    end
    
else
    Y = im;
end
        