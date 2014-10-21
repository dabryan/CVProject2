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





