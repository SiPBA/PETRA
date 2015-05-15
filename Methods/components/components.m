function [error, msj, feats] = components(args)
error = 0; msj = ''; feats = args.feats ;

if isempty (feats)    

    masky=args.mascara; % la mascara binaria debe estar incorporada en los argumentos de entrada
    comp_size=args.comp_size;
    % Factorizacion de la imagen 
    [P Z Y X]=size(args.imgs); fprintf .
    grid= zeros(Z,Y,X);
    grid(1:args.jump:Z-comp_size,1:args.jump:Y-comp_size,1:args.jump:X-comp_size)=1;
    I = find((masky.*grid==1));
    [z,y,x]= ind2sub(size(masky),I);
    NVoxels= length(I);
    
    feats.I=I;
    feats.NVoxels=NVoxels;
    feats.x=x;
    feats.y=y;
    feats.z=z;
    
end
end






