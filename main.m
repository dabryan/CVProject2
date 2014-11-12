clc;
clear all;
close all;
addpath(genpath('externalLib'));
addpath(genpath('variables'));
format short;

%% Intrinsic camera parameters for Kinect camera
K=[-525 0 320;0 -525 240;0 0 1];
W=[0 -1 0;1 0 0; 0 0 1];

%load('Points.mat','x_l','x_r');

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
    787.00 540
    650.00 443];

x_r = [
    428 354
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
display('Points on both cameras after normalization');
% Changing to double precission
uvl = T_nl*x_l'
uvr = T_nr*x_r'

% Build matrix A
A = zeros(length(x_l),9); 
for i=1:length(x_l)
    A(i,:) = [uvl(1,i)*uvr(1,i) uvl(1,i)*uvr(2,i) uvl(1,i) uvl(2,i)*uvr(1,i) uvl(2,i)*uvr(2,i) uvl(2,i) uvr(1,i) uvr(2,i) 1];
end
A

% Compute SVD of A
[U,S,V] = svd(A);
% Set F_n to be the last column of V
display('F normalized');
F_n = reshape(V(:,end),[3,3])';
F_n = F_n'
[U,S,V] = svd(F_n);
% Enforcing Singularity
S(9)=0;
F_n = U*S*V';
% Denormalisation
display('F (fundamental matrix) denormalized');
F = T_nr'*F_n*T_nl
% Essential Matrix
display('Essential matrix E');
E = K'*F*K
% Estimate R&T from E
[U,S,V] = svd(E);
R1=U*W*V';
T1=U(:,3);
R2=U*W'*V';
T2=T1*-1;
T_nl=K/x_l;
T_nr=K/x_r;

% Four possible solutions for R1:2,T1:2
Z_avg=0;
for i=1:4
    switch i
        case 1
            R=R1;
            T=T1;
        case 2
            R=R1;
            T=T2;
        case 3
            R=R2;
            T=T1;
        case 4
            R=R2;
            T=T2;
    end
    for j=1:length(x_l)
        x1=T_nl(1,j);
        y1=T_nl(2,j);
        x2=T_nr(1,j);
        y2=T_nr(2,j);
        A = [
            -1 0 x1 0
            0 -1 y1 0
            -R(1,1)+x2*R(3,1) -R(1,2)+x2*R(3,2) -R(1,3)+x2*R(3,3)  -T(1)+x2*T(3)
            -R(2,1)+y2*R(3,1) -R(2,2)+y2*R(3,2) -R(2,3)+y2*R(3,3)  -T(2)+y2*T(3)];
        [U,S,V] = svd(A);
        % X,Y,Z from last column of V 
        P1(:,j)=V(1:3,end);
        % divided by W
        P1(:,j)=P1(:,j)/V(4,end);
        P2(:,j)=R*P1(:,j)+T;
    end
    % only positive Z
    if mean(P1(3,:))+mean(P2(3,:))>Z_avg
        Z_avg=mean(P1(3,:))+mean(P2(3,:));
        RE=R;
        TE=T;
        P1E=P1;
        P2E=P2;
    end
end
RE
TE
P1E
P2E

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
