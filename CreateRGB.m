% Channel 1:
% R = imread('47.png');
% G = imread('48.png');
% B = imread('49.png');

% R = imread('65.png');
% G = imread('66.png');
% B = imread('67.png');

% R = imread('68.png');
% G = imread('69.png');
% B = imread('70.png');

% R = imread('16.png');
% G = imread('17.png');
% B = imread('18.png');

% R = imread('41.png');
% G = imread('42.png');
% B = imread('43.png');

% Channel 2:

% R = imread('1.png');
% G = imread('2.png');
% B = imread('3.png');

% R = imread('28.png');
% G = imread('29.png');
% B = imread('30.png');

% R = imread('41.png');
% G = imread('42.png');
% B = imread('43.png');

% B = imread('48.png');
% G = imread('49.png');
% R = imread('50.png');

% B = imread('53.png');
% G = imread('54.png');
% R = imread('55.png');
    
% B = imread('70.png');
% G = imread('71.png');
% R = imread('72.png');

% B = imread('74.png');
% G = imread('75.png');
% R = imread('76.png');



ref_img_region = G;
[rg,cg] = size(ref_img_region);
ref_img_region = ref_img_region(ceil((rg-50)/2) :ceil((rg-50)/2) + 50,ceil((cg-50)/2) :ceil((cg-50)/2) + 50);
%disp(size(ref_img_region));
ref_img_region = double(ref_img_region);

% Naive way
% ColorImg_aligned = cat(3,R,G,B);
% imshow(ColorImg_aligned);

% SSD way
nR = align(G,R);
nB = align(G,B);
ColorImg_aligned = cat(3,nR,G,nB);
imshow(ColorImg_aligned);


function aligned = align(green,red)
    [red_row,red_col] = size(red);
    [green_row,green_col] = size(green);

    % checking SSD for cropped part of the images for faster calculation 
    cropped_red = red(ceil((red_row-50)/2) : ceil((red_row-50)/2) + 50,ceil((red_col-50)/2) :ceil((red_col-50)/2) + 50);
cropped_green = green(ceil((green_row-50)/2) : ceil((green_row-50)/2) + 50,ceil((green_col-50)/2) :ceil((green_col-50)/2) + 50);

    MiN = 9999999999;
    r_index = 0;
    r_dim = 1;
    % Modifications
    for i = -10:10
        for j = -10:10
            ssd = SSD(cropped_green,circshift(cropped_red,[i,j])); %circshift(A,[i,j])
            if ssd < MiN
                MiN = ssd;
                r_index = i;
                r_dim = j;
            end
        end
    end
    aligned = circshift(red,[r_index,r_dim]);
end       

function ssd = SSD(a1,a2)
    x = double(a1)-double(a2);
    ssd = sum(x(:).^2);
end 