function Find_RGB_Images(ImagesPath)
close all
filePattern = fullfile(ImagesPath, '*.png');
imagefiles = dir(filePattern);
nfiles = length(imagefiles);

% currentfilename = imagefiles(1).name;
% I1 = imread(currentfilename);
% points1 = detectHarrisFeatures(I1);
% [features1,valid_points1] = extractFeatures(I1,points1);
figure;
k = 1;
while k <= nfiles-2
    
    I1 = imread(imagefiles(k).name);
    points1 = detectHarrisFeatures(I1);
    [features1,valid_points1] = extractFeatures(I1,points1);

    I2 = imread(imagefiles(k+1).name);
    points2 = detectHarrisFeatures(I2);
    [features2,valid_points2] = extractFeatures(I2,points2);
    indexPairs12 = matchFeatures(features1,features2);
    matchedPoints12 = valid_points1(indexPairs12(1:size(indexPairs12,1),1));
    matchedPoints2 = valid_points2(indexPairs12(1:size(indexPairs12,1),2));

    I3 = imread(imagefiles(k+2).name);
    points3 = detectHarrisFeatures(I3);
    [features3,valid_points3] = extractFeatures(I3,points3);
    indexPairs13 = matchFeatures(features1,features3);
    matchedPoints13 = valid_points1(indexPairs13(1:size(indexPairs13,1),1));
    matchedPoints3 = valid_points3(indexPairs13(1:size(indexPairs13,1),2));

    if size(indexPairs12,1)>3  || size(indexPairs13,1)>3
%             Estimate the transformations:        
        outputView = imref2d(size(I1));
        try [tform2, ~] = estimateGeometricTransform2D(matchedPoints12,matchedPoints2,'similarity');
        I2_transformed = imwarp(I2,tform2,OutputView=outputView);
        catch 
            I2_transformed = I2;
        end
        try [tform3, ~] = estimateGeometricTransform2D(matchedPoints13,matchedPoints3,'similarity');
            I3_transformed = imwarp(I3,tform3,OutputView=outputView);
        catch 
            I3_transformed = I3;
        end
        
%             Create RGB from I1,I2 and I3:
        Create_RGB(I1,I2_transformed,I3_transformed)
        pause(1)
        k = k+3;
            
    else
        k = k+1;
        imshow(I1,[])
        pause(1)
        continue
    end

end
end

