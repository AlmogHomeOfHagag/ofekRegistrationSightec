
clear 
clc
close all

format longG
%% Read Image Referenced to Geographic Coordinate System
% 
%% Read image reference to a geographic coordinate system.
cd('/media/a/Data/sightec/18.12.2016 ofek/ortophoto 15.1/18.1 ')
filename = 'pora.tif';
RGB = imread(filename);

%% position from tfw file 

fileID = fopen('pora.tfw','r');
formatSpec = '%e';
metaData = fscanf(fileID,formatSpec);

% init
I=RGB;
pos=zeros(size(I,2),size(I,1),2);

% meta deta extraction

coordinatCenter(1)=metaData(end-1);
coordinatCenter(2)=metaData(end);

step=metaData(1);
% calucate coordinte


firstCoorRaw=coordinatCenter(1);%-size(I,1)/2*step;
firstCoorCol=coordinatCenter(2);%-size(I,2)/2*step;

for i=1:size(I,1)
    for j=1:size(I,2)
        pos(j,i,1)=firstCoorRaw+(i-1)*step;
        pos(j,i,2)=firstCoorCol-(j-1)*step;
        
    end
end

%% ofek 

fig0=figure;imshow(RGB)
[x, y] = getpts(fig0);
x=round(x);  y=round(y);
hold on; plot(x,y,'r*')

largeSize(1)=pos(y, x,1);
largeSize(2)=pos(y, x,2);
display(largeSize)
%% sightec and ofek

orto=RGB(3709:6994,8770:11570,:);
ortoPos=pos(3709:6994,8770:11570,:);

% fig2=figure;imshow(orto)
% [x2, y2] = getpts(fig2);
% x2=round(x2);  y2=round(y2);
% hold on; plot(x2,y2,'r*')
% 
% 
% ortoPos(y2, x2,1)-largeSize(1)
% ortoPos(y2, x2,2)-largeSize(2)
% display(ortoPos(y2, x2,1:2));

%% sightec image registration

filenameSightec='/media/a/Data/sightec/18.12.2016 ofek/sightecImage/rec_1.jpg';
rec = imread(filenameSightec);
figure;imshow(rec)


load('pointSlected','recPoint','ortoPoint');

%   [recPoint,ortoPoint]=cpselect(rec(:,:,1),  orto(:,:,1),'Wait',true); 
%   save('pointSlected','recPoint','ortoPoint');
  
  
t_concord = fitgeotrans(recPoint,ortoPoint,'projective');

Rfixed = imref2d(size(orto));
registeredRec = imwarp(rec,t_concord,'OutputView',Rfixed);
figure, h=imshowpair(orto,registeredRec ,'blend');
% imwrite( h.CData  ,'testSave.tif');
fig1=figure;imshowpair(orto,registeredRec ,'blend');

[x2, y2] = getpts(fig1);
x2=round(x2);  y2=round(y2);
hold on; plot(x2,y2,'r*')

text(x2+10 ,y2+50,num2str( ortoPos(y2, x2,1) ) ,'FontSize' ,15 ,'Color',[ 0 1 0] )
text(x2 ,y2-150,num2str( ortoPos(y2, x2,2) ) ,'FontSize' ,15 ,'Color',[ 0 1 0])



display(ortoPos(y2, x2,1:2)   )


