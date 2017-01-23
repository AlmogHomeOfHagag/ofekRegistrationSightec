
clear 
clc
close all

format longG
%% Read image reference to a geographic coordinate system.
cd('/media/a/Data/sightec/18.12.2016 ofek/ortophoto 15.1/18.1 ')
filename = 'pora.tif';
RGB = imread(filename);

%% ofek 

% fig0=figure;imshow(RGB)

%% sightec and ofek

orto=RGB(4709:6094,9470:10570,:);
orto=imresize(orto,12.5/20);
ortoGray=rgb2gray(orto);

%% sightec image registration
close all
filenameSightec='/media/a/Data/sightec/18.12.2016 ofek/sightecImage/rec_1.jpg';
rec = imread(filenameSightec);
recGray=rgb2gray(rec);
figure;imshow(recGray)
figure;imshow(ortoGray)
%% extract features
pointsRec = detectMinEigenFeatures(recGray);
% pointsRec = detectSURFFeatures(recGray);
% pointsRec = detectBRISKFeatures(recGray);

[features1,validPoints1] = extractFeatures(recGray,pointsRec);

pointsGray = detectMinEigenFeatures(ortoGray);
% pointsGray = detectSURFFeatures(ortoGray);
% pointsGray = detectBRISKFeatures(ortoGray);

[features2,validPoints2] = extractFeatures(ortoGray,pointsGray);


indexPairs = matchFeatures(features1,features2, 'MatchThreshold',80,'MaxRatio',0.6 );


matchedPoints1 = validPoints1(indexPairs(:,1),:);
matchedPoints2 = validPoints2(indexPairs(:,2),:);


figure; showMatchedFeatures(recGray,ortoGray,matchedPoints1,matchedPoints2,'montage');


