
function imsNorm = ptrNormIntGlobal (ims,pctMin)
    if nargin<2, pctMin = 100/8; end
    if pctMin<1 || pctMin>100, error ('Invalid pctMin value'); end
        
    s = size(ims);
    if numel(s)==4,
        imsNorm = zeros (size(ims));
        for i=1:s(1)
            imsNorm(i,:,:,:) = intensityNormIm (squeeze(ims(i,:,:,:)), pctMin/100);
        end
    else
        imsNorm = intensityNormIm (ims, pctMin/100);
    end
end


function imNorm = intensityNormIm (im, pctMin)   
    im = double(im);
    selectedVox = im > (pctMin * mean(im(:)));
    avg = mean(im(selectedVox));
    imNorm = im/avg;
end
