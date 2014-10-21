function images = readImages(totalImages, imgPath)

    % Read one image and obtain the dimensions
    fname=sprintf('%s/rgb%02d.jpg',imgPath,0);
    tempImg = double(imread(fname,'jpg'));
    dim = size(tempImg);
    images = zeros(dim(1), dim(2), 6, totalImages);
    parfor_progress(totalImages);
    for i=1:totalImages
        fname=sprintf('%s/rgb%02d.jpg',imgPath,i-1);
        images(:,:,1:3,i)= imread(fname,'jpg');
        images(:,:,4,i)= rgb2gray(imread(fname,'jpg'));
        fname=sprintf('%s/depthMatrix%02d.txt',imgPath,i-1);
        [images(:,:,6,i), images(:,:,5,i)] = read_depth_matrix(fname);
        parfor_progress;
    end
    parfor_progress(0);
