
function imsNorm = ptrNormIntMax (ims,pctMax)
    if nargin<2, pctMax = 1; end
    if pctMax<1 || pctMax>100, error ('Invalid pctMax value'); end
        
    s = size(ims);
    if numel(s)==4,
        imsNorm = zeros (size(ims));
        for i=1:s(1)
            imsNorm(i,:,:,:) = intensityNormIm (squeeze(ims(i,:,:,:)),pctMax);
        end
    else
        imsNorm = intensityNormIm (ims, pctMax);
    end
end


function imNorm = intensityNormIm (im, pctMax)   
    im = double(im);
    nv = round(pctMax * numel(im)/100);
    sortVox = sort(im(:),'descend');
    top = mean(sortVox(1:nv));
    imNorm = im/top;
end
