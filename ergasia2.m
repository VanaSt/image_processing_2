clc;
clear;
close all;
format compact;
more off;

% ------------------------------
% PART A
% ------------------------------


% --- Step A1
% read the original RGB image 
Filename='Troizina 1827.jpg';
I=imread(Filename);

% show it
figure;
image(I);
axis image off;
title('Original image');


% --- Step A2
% convert the image to grayscale
A=any_image_to_grayscale_func('Troizina 1827.jpg');


% --- Step B5 
% apply gamma correction (a value of 1.0 doesn't change the image)
GammaValue=1.0; 
A=imadjust(A,[],[],GammaValue); 

% show the grayscale image
figure;
image(A);
colormap(gray(256));
axis image off;
title('Grayscale image');


% --- Step A3
% convert the grayscale image to black-and-white 
Threshold= graythresh(A);
BW = ~im2bw(A,Threshold);

% show the black-and-white image
figure;
image(~BW);
colormap(gray(2));
axis image;
set(gca,'xtick',[],'ytick',[]);
title('Binary image');


% --- Step A4
% make morphological operations to clean the image
A=strel('rectangle', [3 10]);
B=strel('diamond', 1);

% clear stamp
C=imdilate(BW, A);
C=imclearborder(C); 
stamp=and(BW, C);

% show the cleared from stamp, image
figure;
image(~stamp);
colormap(gray(2));
axis image off;
title('Image without Stamp');

% open image and clear noise 
stamp=imopen(stamp, B);

% show cleaned image
figure;
image(~stamp);
colormap(gray(2));
axis image off;
title('Cleaned Image');


% --- Step A5
% make morphological operations for word segmentation 
% find the right length
D = strel('line', 18, 0);  
C=imdilate(stamp, D); 

% find the connected components (using bwlabel) 
% colors
[C, count]=bwlabel(C, 4); % 4-connectivity
%[C, count]=bwlabel(C, 8); % 8-connectivity

% show word segmentation
figure;
image(~C);
colormap(gray(2));
axis image off;
title('Imdilate Image');

RGB = label2rgb(C, 'lines');

figure;
image(RGB);
colormap(gray(2));
axis image off;
title(sprintf('%g components in %d-connectivity',count,4));


% --- Step A6
% borders
for i = 1:count
    [row, col]=find(C == i);
    for j = [row col]
      C(row, col)=i;   
    end
end

RGB = label2rgb(C, 'lines');

figure;
image(RGB);
colormap(gray(2));
axis image off;
title('Image with borders in words');

% extract bounding boxes properties 
% bwconncomp(BW) returns the connected components CC found in the binary image BW
% regionprops measure properties of image regions
CC = bwconncomp(C, 4);
s = regionprops(CC, 'BoundingBox');

% create a matrix nX4. n = bounding box total number and 4 properties of bounding box (x,y,width,height)
bbox  = vertcat(s.BoundingBox);

% show the original image 
figure;
image(I);
axis image off;
title('Final results');

% and show the final bounding boxes 
for idx = 1 : numel(s)
    rectangle('Position', bbox (idx,:), 'edgecolor', [rand rand rand], 'LineWidth', 2);
end


% --- Step A7
% save the bounding boxes in a text file results.txt ...

% Convert from the [x y width height] bounding box format to the [xmin ymin xmax ymax] format 
% Calculate pixel coordinates and extract to a results.txt with dlmwrite function
xmin = bbox (:,1)+0.5;
ymin = bbox (:,2)+0.5;
xmax = xmin + bbox (:,3) - 1;
ymax = ymin + bbox (:,4) - 1;
dlmwrite('results.txt',[xmin,ymin,xmax,ymax],'delimiter','\t');
fprintf('Values extracted to file "results.txt".\n');



% ------------------------------
% PART B
% ------------------------------


% --- Step B1
% load the ground truth
GT=dlmread('Troizina 1827_ground_truth.txt');
% load our results
R=dlmread('results.txt');


% --- Step B2
% calculate IOU for all the results ...
overlapRatio = bboxOverlapRatio(R, GT);

% max value per colunm
IOU=max(overlapRatio);


% --- Step B3
% calculate the Score for this pair of (GammaValue,IOUThreshold) ...
IOUThreshold=0.5; % or 0.3 or 0.7
score=(IOU>=IOUThreshold);
score5=(sum(score)/size(R,1))*100;
fprintf('IOU score is %0.2f%%', score5);

