function Create_RGB(R,G,B,Referance_Path)

% G = imread(G_Path);
% R = imread(R_Path);
% B = imread(B_Path);


ref_img_region =G;
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
subplot(2,1,2);
imshow(ColorImg_aligned,[])
title('Recreated colored Image')

end

function aligned = align(green,red)
    [red_row,red_col] = size(red);
    [green_row,green_col] = size(green);

    % checking SSD for cropped part of the images for faster calculation 
    cropped_red = red(ceil((red_row-50)/2) : ceil((red_row-50)/2) + 50,ceil((red_col-50)/2) :ceil((red_col-50)/2) + 50);
cropped_green = green(ceil((green_row-50)/2) : ceil((green_row-50)/2) + 50,ceil((green_col-50)/2) :ceil((green_col-50)/2) + 50);

    MiN = inf;
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

