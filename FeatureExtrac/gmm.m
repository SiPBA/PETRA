function [error, msj, feats, options] = gmm (args)
    error = 0; msj = ''; feats = []; options = args.options;

    if isempty (options)
        [Ncl, tipo, truncate, scaling] = get_params (args.params, ...
                                                     64, 'dif', 64, 2);
        if isempty(reg_init(Ncl))
            error = 1;
            msj = 'Número de Gaussianas no válido';
            return
        end
        options.Ncl = Ncl;
        options.tipo = tipo;
        options.scaling = scaling;
        options.truncate = truncate;

        if strcmp (tipo, 'dif'),
            imgsDTA (:,:,:,:) = args.imgs(args.labels == 1, :, :, :);
            imgsNOR (:,:,:,:) = args.imgs(args.labels == 0, :, :, :);
            imgDTA = imScale (squeeze (mean (imgsDTA)), scaling);
            imgNOR = imScale (squeeze (mean (imgsNOR)), scaling);
            imgModel = imgNOR-imgDTA;
        else
            imgsNOR (:,:,:,:) = args.imgs(args.labels == 0, :, :, :);
            imgNOR = imScale (squeeze (mean (imgsNOR)), scaling);
            imgModel = imgNOR;
        end

        [data, M, S, w, h] = clusterImage(imgModel, Ncl);
        options.data = data; options.M = M; options.S = S;
        options.w=w; options.h = h;
    end

    feats = extractFeatures(args.imgs, options.scaling, options.M, ...
                            options.S, options.h);
    feats = feats (:, 1:options.truncate);




function I_sc = imScale(I, scaling)
    if scaling==1, I_sc = I; return; end

    % determine the offset of the scaled image
    s = size(I);
    off_x = 0.5*((s(1)-1) - scaling*floor((s(1)-1)/scaling)) + 1;
    off_y = 0.5*((s(2)-1) - scaling*floor((s(2)-1)/scaling)) + 1;
    off_z = 0.5*((s(3)-1) - scaling*floor((s(3)-1)/scaling)) + 1;

    % positions to evaluate the image
    [yi, xi, zi] = meshgrid(off_x:scaling:s(1), off_y:scaling:s(2), off_z:scaling:s(3));

    % scale image
    I_sct = interp3(I, xi,yi,zi);
    I_sc = permute(I_sct,[2 1 3]);


function [data, M, S, w, h] = clusterImage(I, Ncl, M0, S0, w0)
    % symmetrize and square the image
    s = size(I);
    Imirr(:,:,:) = I(s(1):-1:1,:,:);
    I = (I+Imirr)/2;
    I = I.^2;

    % convert image to data-vector containing positions and intensities
    data = im2vect(I);

    % initialize the clusters
    if nargin<3
        [M0, S0] = initMLE(I, Ncl);
        w0 = ones(1,Ncl)/Ncl;
    end

    % compute the clusters using maximum likelihood estimation (MLE)
    [M,S,w] = MLE(data, Ncl, 1e-5, M0, S0, w0);

    % eventually order the clusters according to their height
    h = zeros(1,Ncl);
    for c=1:Ncl
        h(c) = w(c)/sqrt((2*pi)^3*det(reshape(S(c,:,:),3,3)));
    end
    [h,ind] = sort(h,'descend');
    w(:) = w(ind);
    M(:,:) = M(ind,:);
    S(:,:,:) = S(ind,:,:);

    
function [M0, S0] = initMLE(I, Ncl)
    % initialize parameters
    I = double(I);
    s = size(I);
    M0 = zeros(Ncl,3);
    S0 = zeros(Ncl,3,3);

    % cubic matrix R defines positions of clusters with 0 and 1
    R = reg_init(Ncl);
    g = size(R);

    % distance between cluster centers
    delta = (s/3)./g;

    % put cluster centers on a regular grid where R=1
    k=1;
    for x=1:g(1)
        for y=1:g(2)
            for z=1:g(3)
                % no cluster center if R=0
                if R(x,y,z) == 0 
                    continue; 
                end
                % cluster center
                M0(k,:) = [x y z].*delta + 0.5*[1 1 1] - 0.5*delta;
                M0(k,:) = M0(k,:) + s/3;

                % covariance
                S0(k,:,:) = 3*eye(3).*repmat(delta,3,1);
                k = k+1;
            end
        end
    end
    
    
function R = reg_init (Ncl)
    switch Ncl
        case 4
            R = ones(2,2,1);
        case 8
            R = ones(2,2,2);
        case 9
            R = ones(3,3,1);
        case 12
            R = ones(3,2,2);
        case 16
            R = ones(3,3,2);
            R(2,2,:) = 0;
        case 17
            R = zeros(5,5,5);
            R([1 5],[1 5],[1 5]) = 1;
            R([2 4],[2 4],[2 4]) = 1;
            R(3,3,3) = 1;
        case 18
            R = ones(3,3,2);
        case 20
            R = ones(3,4,2);
            R(2,2:3,:) = 0;
        case 22
            R = ones(3,4,3);
            R(2,2:3,:) = 0;
            R(1,1,[1 3]) = 0;
            R(1,4,[1 3]) = 0;
            R(3,1,[1 3]) = 0;
            R(3,4,[1 3]) = 0;
        case 24
            R = ones(3,3,3);
            R(2,2,:) = 0;
        case 26
            R = ones(3,4,3);
            R(2,2:3,2) = 0;
            R(1,1,[1 3]) = 0;
            R(1,4,[1 3]) = 0;
            R(3,1,[1 3]) = 0;
            R(3,4,[1 3]) = 0;
        case 27
            R = ones(3,3,3);
        case 29
            R = zeros(5,5,5);
            R([1 5],[1 5],[1 5]) = 1;
            R([2 4],[2 4],[2 4]) = 1;
            R(3,3,3) = 1;
            R([1 5],3,3) = 1;
            R(3,[1 5],3) = 1;
            R(3,3,[1 5]) = 1;
            R([2 4],3,3) = 1;
            R(3,[2 4],3) = 1;
            R(3,3,[2 4]) = 1;
        case 30
            R = ones(3,4,3);
            R(2,2:3,:) = 0;
        case 32
            R = ones(4,4,2);
        case 36
            R = ones(3,4,3);
        case 40
            R = ones(3,4,4);
            R(2,2:3,:) = 0;
        case 48
            R = ones(4,4,3);
        case 60
            R = ones(5,4,3);
        case 64
            R = ones(4,4,4);
        case 75
            R = ones(5,5,3);
        case 100
            R = ones(5,5,4);
        case 125
            R = ones(5,5,5);
        otherwise
            R=[];
    end    
    
    
function [M, S, w] = MLE(data, Ncl, maxdev, M0, S0, w0)
    max_iter = 300;

    % extract position vector X and intensity vector I
    data = double(data);
    [N, dim] = size(data);
    dim = dim-1;
    X = data(:,1:dim);      % spatial coordinates of the voxels
    I = data(:,dim+1)';     % voxel intensities
    Itot = sum(I);          % total intensity
    clear data;


    % initialization of cluster parameters
    if (nargin<3), maxdev=1e-5; end
    max_data = max(X);
    min_data = min(X);
    wdth = (max_data-min_data);
    cntr = (max_data+min_data)/2;
    for i=1:Ncl
        if (nargin<4) M0(i,:) = 0.5*wdth.*rand(1,dim)+cntr-wdth/4; end
        if (nargin<5) S0(i,:,:) = 0.33 *eye(dim).*repmat(wdth,dim,1); end
        if (nargin<6) w0(i) = 1/Ncl; end;
    end
    logLik = 0;
    dev = 1;
    step = 0;
    M = M0;
    S = S0;
    w = w0;
    p = zeros(Ncl,N);

    % EM algorithm to update the parameters of the Gaussian mixture
    h = waitbar(0,'Iterando EM ...','WindowStyle','modal','Resize','off');
    while (dev>maxdev && step<max_iter) 
        step = step+1;

        % Gauss functions representing each cluster
        for i=1:Ncl
            p(i,:) = gauss(X, M(i,:), reshape(S(i,:,:),dim,dim));
        end

        ptot = sum(p.*repmat(w', 1, N),1);

        % changes in the log-likelihood
        logLik_old = logLik;
        logLik = sum(I.*log(ptot));
        dev = abs((logLik - logLik_old)/logLik);

        % posterior probability
        q = p.*repmat(w', 1, N)./repmat(ptot,Ncl,1);

        %disp(['step ' num2str(step, '%03d') ', relative deviation ' num2str(dev, '%1.2e') ...
        %    ', log Likelihood ' num2str(logLik, '%5.2f')]);

        Iq = repmat(I,Ncl,1).*q;
        clear q;

        % update the weights
        w = sum(Iq,2)'/Itot;

        % update the cluster centers
        for a=1:dim
            M(:,a) = Iq*X(:,a)./(Itot*w');
        end

        % update the covariances
        for i=1:Ncl
            A = zeros(dim,dim);
            for j=1:N
                A = A + Iq(i,j) * (X(j,:)-M(i,:))' * (X(j,:)-M(i,:));
            end
            S(i,:,:) = A/(w(i)*Itot);
            % avoid that the covariance matrix gets singular
            if (abs(det(reshape(S(i,:,:),dim,dim)))<1e-7)   
                disp('Warning: singular matrix avoided');
                S(i,:,:) = S0(i,:,:);
            end
        end
        waitbar(step/max_iter);
    end
    close(h);
   
    
function features = extractFeatures(imgs, scaling ,M, S, h)
    % extract feature vectors for all images
    num = size(imgs, 1);
    Ncl = size (M, 1);
    features = zeros(num, Ncl);

    hw = waitbar(0,'Extrayendo características ...',...
        'WindowStyle','modal','Resize','off');
    for i = 1:num
        I = imScale (squeeze (imgs (i,:,:,:)), scaling);
        X = im2vect(I);

        % compute individual Gauss functions for each cluster
        p = zeros(Ncl,size(X,1));
        for c=1:Ncl
            p(c,:) = h(c)*gauss(X(:,1:3), M(c,:), reshape(0.25*S(c,:,:),3,3));
        end

        % compute features averaging intensity for each cluster
        for c=1:Ncl
            features(i,c) = p(c,:)*X(:,4); 
        end
        waitbar(i/num);
    end
    close (hw);

    
function data = im2vect(I)
    s = size(I);
    N = s(1)*s(2)*s(3);

    [Y,X,Z] = meshgrid(1:s(2), 1:s(1), 1:s(3));
    data = [reshape(X,N,1), reshape(Y,N,1), reshape(Z,N,1), reshape(I,N,1)];


function p = gauss(X,M,S)
    % number of samples and dimensionality
    [Nsamp,dim] = size(X);

    % normalization factor of the Gaussian
    pref = 1/sqrt((2*pi)^dim*det(S));

    % evaluation of the Gauss function
    C = inv(S);
    p = pref * exp(-0.5*sum((X-repmat(M,Nsamp,1))' .* (C*(X-repmat(M,Nsamp,1))'),1));

