clc;
clear all;
close all;
addpath(genpath('externalLib'));
addpath(genpath('variables'));



% Running in parallel, check if the pool of threads is already open
if matlabpool('size') == 0 
    infoLocal = parcluster('local');
    maxWorkers = infoLocal.NumWorkers;
    matlabpool('open',maxWorkers);
end

%% Intrinsic camera parameters for Kinect camera
cameraModel=[-525 0 320;0 -525 240;0 0 1]; 

%% Using points given by proffesor for testing (12)
x_l = [
    434.00 360
    468.00 542
    275.00 393
    297.00 542
    400.00 484
    424.00 625
    242.00 483
    261.00 628
    631.00 541
    655.00 622
    787.00 549
    650.00 443];

x_r = [
    428 352
    447 545
    255 389
    265 545
    407 481
    421 629
    239 481
    248 631
    625 544
    671 627
    797 544 
    668 439];

% Mean of points
mux_l = mean(x_l);
mux_r = mean(x_r);

% Compute T_trans
T_tl = [1 0 -mux_l(1); 0 1 -mux_l(2); 0 0 1];
T_tr = [1 0 -mux_r(1); 0 1 -mux_r(2); 0 0 1];

% Compute RMS
RMS_l =  sqrt( (1/length(x_l))*sum( (x_l(:,1) - mux_l(1)).^2 + (x_l(:,2) - mux_l(2)).^2 ) );
RMS_r =  sqrt( (1/length(x_r))*sum( (x_r(:,1) - mux_r(1)).^2 + (x_r(:,2) - mux_r(2)).^2 ) );

% Compute T_scale
T_sl = [sqrt(2)/RMS_l   0               0
        0               sqrt(2)/RMS_l   0 
        0               0               1];
T_sr = [sqrt(2)/RMS_r   0               0
        0               sqrt(2)/RMS_r   0 
        0               0               1];

% Tnorm
T_nl = T_sl*T_tl
T_nr = T_sr*T_tr

% Adding extra column to make the multiplication
x_l(:,3) = 1;
x_r(:,3) = 1;

% Normalizing points 
uvl = T_nl*x_l'
uvr = T_nr*x_r'

% Build matrix A
A = zeros(length(x_l),9); 
for i=1:length(x_l)
    A(i,:) = [uvl(1,i)*uvr(1,i) uvl(1,i)*uvr(2,i) uvl(1,i) uvl(2)*uvr(1) uvl(2,i)*uvr(2,i) uvl(2,i) uvr(1,i) uvr(2,i) 1];
end

% Compute SVD of A
[U,S,VT] = svd(A);
% Set f to be the last column of V
f = VT(:,end);

return;

totalImages = 20;

%% Read images and depth data (480 x 640 x channels(5) x totalImages(20))
% images(:,:,1:3,i) RGB channels for image i
% images(:,:,4,i) rgb2gray(image i)
% images(:,:,5,i) depth data for image i
% images(:,:,6,i) disparity data for image i 
images=readImages(totalImages,'kinect');

%% Overlay depth data for the first 9 images to test
montage(uint8(images(:,:,4,1:9)))
hold on
depth=montage(uint8(images(:,:,5,1:9)));
set(depth, 'AlphaData', .5 );
colormap jet





