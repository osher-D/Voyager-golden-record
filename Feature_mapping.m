function [outputArg1,outputArg2] = Feature_mapping(Images_path,Option)

% Images trio:

First = imread('A.png');
Second = imread('B.png');
Third = imread('C.png');

% Features:

points1 = detectSURFFeatures(First);
[features1,valid_points1] = extractFeatures(First,points1);

points2 = detectSURFFeatures(Second);
[features2,valid_points2] = extractFeatures(Second,points2);

points3 = detectSURFFeatures(Third);
[features3,valid_points3] = extractFeatures(Third,points3);


% Matching features:

indexPairs12 = matchFeatures(features1,features2);
matchedPoints1 = valid_points1(indexPairs12(1:size(indexPairs12,1),1));
matchedPoints21 = valid_points2(indexPairs12(1:size(indexPairs12,1),2));


indexPairs23 = matchFeatures(features2,features3);
matchedPoints23 = valid_points2(indexPairs23(1:size(indexPairs23,1),1));
matchedPoints32 = valid_points3(indexPairs23(1:size(indexPairs23,1),2));


indexPairs13 = matchFeatures(features2,features3);
matchedPoints13 = valid_points2(indexPairs13(1:size(indexPairs13,1),1));
matchedPoints31 = valid_points3(indexPairs13(1:size(indexPairs13,1),2));


% figure; 
% ax = axes;
% showMatchedFeatures(First,Second,matchedPoints1,matchedPoints21,'montage','Parent',ax);
% hold on
% showMatchedFeatures(Second,Third,matchedPoints23,matchedPoints3,'montage','Parent',ax);

TrioMatchedFeatures(First,Second,Third,matchedPoints1,matchedPoints21,matchedPoints23,matchedPoints32,Option)


outputView = imref2d(size(First));

if size(matchedPoints1.Location,1)>=2
[tform2, ~] = estimateGeometricTransform2D(matchedPoints1,matchedPoints21,"similarity");
I2_transformed = imwarp(Second,tform2,OutputView=outputView);
else
    I2_transformed = Second;
end

if size(matchedPoints13.Location,1)>=2
    [tform3, ~] = estimateGeometricTransform2D(matchedPoints13,matchedPoints31,'similarity');
    I3_transformed = imwarp(Third,tform3,OutputView=outputView);
else
    I3_transformed = Third;
end

Create_RGB(First,I2_transformed,I3_transformed)

end

function TrioMatchedFeatures(I1,I2,I3,matchedPoints1,matchedPoints21,matchedPoints23,matchedPoints3,Option)

figure;
ax = nexttile;
subplot(2,1,1);imshow([I1,I2,I3])
[~,n] = size(I1);

% Match I1 and I2:
lineX = [matchedPoints1.Location(1:10,1)'; n+matchedPoints21.Location(1:10,1)'];
numPts = numel(lineX);
lineX = [lineX; NaN(1,numPts/2)];

lineY = [matchedPoints1.Location(1:10,2)'; matchedPoints21.Location(1:10,2)'];
lineY = [lineY; NaN(1,numPts/2)];

line(lineX, lineY,'Color','y','LineStyle','-','Marker','+');
hold on
% Match I2 and I3:

lineX = [n+matchedPoints23.Location(1:10,1)'; 2*n+matchedPoints3.Location(1:10,1)'];
numPts = numel(lineX);
lineX = [lineX; NaN(1,numPts/2)];

lineY = [matchedPoints23.Location(1:10,2)'; matchedPoints3.Location(1:10,2)'];
lineY = [lineY; NaN(1,numPts/2)];
a = 1;
line(lineX, lineY,'Color','g','LineStyle','-','Marker','o');

end