% sift on ofek and sightec 
clear;
clc;
close all
plotFlag=1;
stepImages=1;
%% set param
restoredefaultpath
% addpath('D:/sightec/ElbitReg/5.6.2016 Elbit reg');
addpath('/media/a/Data/sightec/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/sift')

run('/media/a/Data/sightec/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup.m');

%% get number of images
RGBsrc='/media/a/Data/sightec/18.12.2016 ofek/ortophoto 15.1/18.1 ';
% RGBsrc='D:/sightec/13.06.2016 3DVisualstionSumsungRotor/11.7.2015 Data TelAviv office floor/rgbd_dataset_freiburg1_teddy/rgb';
RGBsrcFolder=[RGBsrc '/frames'];
list=dir([RGBsrc '/frames']);
stratImage=1;

N_images = 2; % numel(dir(fullfile('F:/Elbit170/FramesRGB', '*.tif')));
disp(['Found ', num2str(N_images), ' images.']);

%% load images, crop and extract SIFT features
I = cell(N_images, 1);
I_RGB = cell(N_images, 1);
F_all = cell(N_images, 1);
D_all = cell(N_images, 1);
fprintf('Extracting features... ');
if plotFlag==1
    figure;
end

k=1;
cd('/media/a/Data/sightec/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/mex/mexw64')
for n =  1:1:(N_images)
    
    I_full = imread( [RGBsrcFolder '/rec_', num2str(stepImages*(n-1)+stratImage), '.jpg']  );
    
    display([' '  num2str(n)]);
     
    I_RGB{k} = I_full;
    I{k} = rgb2gray(I_RGB{k});
    [F_all{k}, D_all{k}] = vl_sift(single(I{k}));
    if plotFlag==1
        imshow(I{k})
    end
    k=k+1;
    
end
imageCell=I;

imgW = size(I{1}, 2);
imgH = size(I{2}, 1);
disp(' Done.');

%% set reference features
N_features = 3500;
fprintf(['Choosing ', num2str(N_features), ' uniformly scattered features... ']);

% generate uniformly scattered N_features
x_rand = floor(diag([imgW, imgH])*rand(2, N_features)) + 1;
[knn_idx, knn_dist] = knnsearch(F_all{1}(1:2, :).', x_rand.', 'K', 1);
F_all{1} = F_all{1}(:, knn_idx);
D_all{1} = D_all{1}(:, knn_idx);
disp(' Done.');

%% Match
fprintf('matching... ');
matches = cell(N_images, 1);
matchesImages = cell(N_images, 1);

for n = 1:(N_images-1)
    
    matches{n} = vl_ubcmatch(D_all{n}, D_all{n+1});
    matchesImages{n} = [ stepImages*(n-1)+stratImage , stepImages*(n)+stratImage   ] ;
    
    fprintf('---');
    display( num2str(n));
    fprintf('---');

end
disp(' Done.');
%%  plot matchs
pathSave=['/media/a/Data/sightec/18.12.2016 ofek/ortophoto 15.1/18.1 /step' num2str(stepImages)];

mkdir([pathSave '/KF' num2str(stratImage) ]);
close all
for i=1:(N_images-1)
    
    clc
    matchesImages{i} 
    
    coorspondenceIndex= matches{i};
    pointsA=F_all{i};
    pointsB=F_all{i+1};
    pointsA=pointsA(1:2,coorspondenceIndex(1,:));
    pointsB=pointsB(1:2,coorspondenceIndex(2,:));
    coorspondencePoints=[pointsA ;pointsB];
    
    I1=I_RGB{i};
    I2=I_RGB{i+1};
    save([pathSave '/KF' num2str(stratImage) '/matches' num2str(matchesImages{i}(1)) 'and' num2str(matchesImages{i}(2)) '.mat'] ,...
        'coorspondencePoints','I1','I2')
    
    size(coorspondenceIndex,2)
    
end

%% display image 1 ,2

% for j=10:100
%     close all
%     figure;imshow(I{1});
%     hold on;plot(pointsA(1,j),pointsA(2,j),'*');
%     figure;imshow(I{2});
%     hold on;plot(pointsB(1,j),pointsB(2,j),'*');
%    pause;
% 
% end

% clear;clc
close all

stratImage=1;
list=dir([pathSave '/KF' num2str(stratImage) ]);
N_images=stepImages;

for i=1:(N_images-1)
    
    clc
    load([pathSave '/KF' num2str(stratImage) '/' list(i+2).name  ] ,...
        'coorspondencePoints','I1','I2')
  %  display([ 'Coorspondence between ' list(i+2).name(8:10) ' and ' list(i+2).name(14:16)    ]);
    
    I_RGB{i}=I1;
    I_RGB{i+1}=I2;
    pointsA= coorspondencePoints(1:2,:);
    pointsB= coorspondencePoints(3:4,:);
    
    display([ 'Number of coorspondence  ' num2str(size(coorspondencePoints,2) )]);
    close all
    
    m=(pointsA(2,:)-pointsB(2,:))./(pointsA(1,:)-pointsB(1,:)) ;
    distance=(pointsA(2,:)-pointsB(2,:)).^2+(pointsA(1,:)-pointsB(1,:)).^2;
    %% outliers for distance
    nbin=linspace(min(distance),max(distance),100);
    hist(distance,nbin)
    
    y=hist(distance,nbin);
    y1=y/sum(y);
    
    y1 = cumsum(y1);
    pos=find(y1>0.7,1);
    indexDistance=  (distance < nbin(pos));
    
    %% outliers for angles lines
    nbin=linspace(min(m),max(m),100);
    hist(m,nbin)
    
    y=hist(m,nbin);
    y1=y/sum(y);
    
    y1 = cumsum(y1);
    pos=find(y1>0.6,1);
    indexM=  (m < nbin(pos));
    
    index=logical(indexDistance.*indexM);
    pointsA=pointsA(:,index);
    pointsB=pointsB(:,index);
    showMatchedFeatures(I1,I2,pointsA',pointsB');
    
    
    pause;
end


