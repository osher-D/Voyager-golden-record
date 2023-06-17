function Encode_Golden_Record(Images_path_R,Images_path_L)

% Given two sets of sets of images to decode, create a "Golden record" like
% audio file one could potentially send into space :)


% Input variables:
%       - Images_path_R : Path to first set of imeges.
%       - Images_path_L : Path to second set of imeges.

% Outputs:
%       - Golden_Audio_File : Audio file encoded with input images.

% Read the images, resize and add scan lines:
Images = Read_images(Images_path_R,Images_path_L);

% Add scan frequency impurity:

Images = frequency_impurity(Images);

% Create "GAP" between images, concatenate and generate golden-record like
% audio file named "Personal_Golden_Record_Audio.mp3"


Merge_images(Images);

sprintf('Encoding complete and ready to be launched into space')

end

function Merge_images(Images)

Preemble = load('Preemble.mat');
Preemble = Preemble.Data;
Preemble = imcomplement(Preemble(:));
Right_channel = [];
Left_channel = [];
for k = 1:size(Images,2)

    Right_channel = [Right_channel;Preemble;Images{1,k}];
    Left_channel = [Left_channel;Preemble;Images{2,k}];

end
% make chennels length equeal:
if length(Right_channel)>length(Left_channel)
    Left_channel = [Left_channel;ones(length(Right_channel)-length(Left_channel),1)];
else
    Right_channel = [Right_channel;ones(length(Left_channel)-length(Right_channel),1)];
end

[GNR_Audio,GNR_Fs] = audioread('Paradise City - Guns N Roses.mp3');
GNR_Audio = resample(GNR_Audio,44100,GNR_Fs);
GNR_Audio1 = GNR_Audio(1:44100*30,:);
GNR_Audio2 = GNR_Audio(end-44100*5:end,:);
Audio_data = [GNR_Audio1;[Right_channel,Left_channel];GNR_Audio2];
% cd C:\Users\osher\Desktop;


currentFolder = pwd;
audiowrite(strcat(currentFolder,'\Personal_Golden_Record_Audio.wav'),Audio_data,44100);

end

function I = frequency_impurity(Images)
Max_f =39405; % Hz
Min_f =39395; % Hz
W = 512;
H = 367;

New_Fs = (Max_f - Min_f).*rand(1,2*size(Images,2)) + Min_f;
% New_Fs = linspace(Min_f,Max_f,size(Images,2));
for k = 1:size(Images,2)

    I1 = Images{1,k};
    I1 = I1(:);
    I1 = resample(I1,44100,fix(New_Fs(k)));
    if (length(I1)/W)-(H)<0
        I1 = [I1;zeros(W*H - length(I1),1)];
    else
        I1 = I1(1:W*H);
    end
    I1 = reshape([I1.';I1.'],[],1);
    I{1,k} = I1;
end
for k = 1:size(Images,2)
    I2 = Images{2,k};
    I2= I2(:);
    I2 = resample(I2,44100,fix(New_Fs(k)));
    if (length(I2)/W)-(H)<0
        I2 = [I2;zeros(W*H - length(I2),1)];
    else
        I1 = I1(1:W*H);
    end
    I2 = reshape([I2.';I2.'],[],1);
    I{2,k} = I2;
    %     reshape([I2.';I2.'],[],1);
end


end


function images = Read_images(Images_path_R,Images_path_L)
Test_Block = load('Test_Block.mat');
Test_Block = cell2mat(struct2cell(Test_Block));
Test_Block(:,2:end) = [];
images = cell(2,1);
filePattern = fullfile(Images_path_L, '*.png');
imagefiles = dir(filePattern);
nfiles = length(imagefiles);    % Number of files found
for k=1:nfiles
    currentfilename = imagefiles(k).name;
    currentimage = imread(currentfilename);

    %   Resize (Keep images aspect ratio) and add scan lines at the top of each
    %   image:
    if size(currentimage,3)==3
        images_cells = split_RGB(currentimage,Test_Block);
        images{1,:} = [images{1,:},images_cells(:).'];
    else
        currentimage = imcomplement(ReformatImage(currentimage,Test_Block));
        images{1,end+1} = currentimage;
    end
end
 

filePattern = fullfile(Images_path_R, '*.png');
imagefiles = dir(filePattern);
nfiles = length(imagefiles);    % Number of files found
for k=1:nfiles
    currentfilename = imagefiles(k).name;
    currentimage = imread(currentfilename);

    %   Resize (Keep images aspect ratio) and add scan lines at the top of each
    %   image:
    if size(currentimage,3)==3
        images_cells = split_RGB(currentimage,Test_Block);
        images{2,:} = [images{2,:},images_cells(:).'];
    else
        currentimage = imcomplement(ReformatImage(currentimage,Test_Block));
        images{2,end+1} = currentimage;
    end
end
images1 = images{1,1};
images2 = images{2,1};
images = [images1;images2];
end

function images_cells = split_RGB(currentimage,Test_Block)

currentimage1 = imcomplement(ReformatImage(currentimage(:,:,1),Test_Block));
currentimage2 = imcomplement(ReformatImage(currentimage(:,:,2),Test_Block));
currentimage3 = imcomplement(ReformatImage(currentimage(:,:,3),Test_Block));

images_cells = {currentimage1,currentimage2,currentimage3};
end


function I = ReformatImage(I,Test_Block)

[m,n] = size(I);
W = 512;
H = 328-15; % "Pad" with 'Test_block' to create a scan line
I = 0.001625*double(I)+0.7375; % Ampiric transformation to match original audio file
Pad_val = 1.03;
% %   Define struct array:
% M.Name = 'm';
% M.Val = m;
% N.Name = 'n';
% N.Val = n;
% 
% Window_Width.Name = 'W';
% Window_Width.Val = W;
% Window_Hight.Name = 'H';
% Window_Hight.Val = H;
% 
% structArray = [M N Window_Width Window_Hight];
% 
% [~,ind] = sort(arrayfun (@(x) x.Val, structArray),"descend") ;
% Sorted_array = structArray(ind) ;
% A = {Sorted_array.Name};
% Sizes_vector = (strjoin({A{1,1},A{1,2},A{1,3},A{1,4}}));
% switch Sizes_vector
% 
        if (W/n)*m > H
            I = imresize(I,[H,NaN]);
            [a,b] = size(I);
            I =[Pad_val*ones(a,floor((W-b)/2)) , I , Pad_val*ones(a,ceil((W-b)/2))];
            I = [repmat(Test_Block,[1,W]) ; I];
        else
            I = imresize(I,[NaN,W]);
            [a,b] = size(I);
            I =[Pad_val*ones(floor(H-a),b) ; I];
            I = [repmat(Test_Block,[1,W]) ; I];
        end
%     case 'm n W H'        
%     case 'n m W H'
%     case 'W m n H'
%     case 'W n m H'
%     case 'W H m n'
%     case 'W H n m'
%     case 'm W n H'
%     case 'n W m H'
%     case 'm W H n'
%     case 'n W H m'
%     case 'W m H n'
%     case 'W n H m'
% end
% imshow(I,[])
end
