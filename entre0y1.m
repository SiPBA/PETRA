function img = entre0y1(img)
img(isnan(img))=0;
    img = img - min(img(:));
    img = img / max(img(:));