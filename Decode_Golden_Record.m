function Decode_Golden_Record(AudioPath,Channel_index,ImagesPath)
% Given a "Golden record" like audio file, decode and present the images

% Input Variables:
%       - FullPath : Path to audio file.
%       - Channel_index : Channel to decode - 'L' for left channel and
%                         'R' for right channel.
%                         Default channel is 'R'.

[Voyager_audio,Voyager_audio_Fs] = audioread(AudioPath);

% Select channel:
if strcmp(Channel_index,'L')
    Selected_channel = Voyager_audio(:,1);
else
    Selected_channel = Voyager_audio(:,2);
end

% Drop the firsrt 30 seconds, since they are junk anyways:
Selected_channel(1:30*Voyager_audio_Fs) = [];


% Initialize parameters:
Big_step_size = 734;
Small_step_size = 10;
Image_pixels_count = 734*513;
Bin = 200;
Test_Block = load('Test_Block.mat');
Test_Block = cell2mat(struct2cell(Test_Block));
Block_matching_threshold = 0.7;
Images = cell(0);
scanline_angles = [];
Start = 1;
Stop = Big_step_size;
New_Image = 0;
% figure;
% a1 = axes;
% figure;
% a2 = axes;
Signal = Selected_channel(Start+1:2:(Start+Image_pixels_count));


while Start+Big_step_size+Image_pixels_count <= length(Selected_channel)

    %     Start scanning the audio file:
    %     and look for when preemble starts and ends:
    New_Image = 0;
    x = Signal(1:366);
    y = fftshift(fft(x));
    y_bin = abs(y(Bin))^2/366;
%     plot(a1,abs(y))
%     imshow(reshape(Signal,[],512),[],'Parent',a2);
    if y_bin<0.1
        Start = Start+Big_step_size;
        Stop = Stop+Big_step_size;
        Signal = Selected_channel(Start+1:2:Start+Image_pixels_count);

    else % Preemble started
        while ~New_Image
            x = Signal(1:366);
            y = fftshift(fft(x));
            y_bin = abs(y(Bin))^2/366;

            if y_bin>0.1
                Start = Start+Big_step_size;
                Stop = Stop+Big_step_size;
                Signal = Selected_channel(Start+1:2:Start+Image_pixels_count);

            else % Preemble ended, find scanline:
                while true
                    Signal1 = Signal(1:367*512);
%                     Signal1(end-mod(length(Signal1),512)+1:end) = [];
                    Signal1 = imcomplement(Signal1);
                    Current_window = reshape(Signal1,[],512);
                    x_block1 = Current_window(1:15,1:15);
                    x_block2 = Current_window(end-15+1:end,1:15);
                    if norm(x_block1 - Test_Block) > Block_matching_threshold
%                         && ...
%                        norm(x_block2 - Test_Block) > Block_matching_threshold
                        
                        Start = Start+Small_step_size;
                        Stop = Stop+Small_step_size;
                        Signal = Selected_channel(Start+1:2:Start+Image_pixels_count);

                    else % Image_found
                        I = Selected_channel(Start+1:2:Start+Image_pixels_count);
%                         I(end-mod(length(I),512)+1:end) = [];
                        Corrected_Image = Skew_correction(I);
                        Images{end+1} = Corrected_Image;
%                         scanline_angles(end+1,1) = scanline_angle;
                        sprintf('Number of images detected: %d',length(Images))
                        imwrite(mat2gray(Images{end}),fullfile(ImagesPath,strcat(num2str(char(length(Images) + 64)),'.png')))
                        Start = Start+Image_pixels_count;
                        Stop = Start+Big_step_size;
                        New_Image = 1;
                        break

                    end
                end
            end
        end
    end
end
end


function scanline_angle = find_scanline_frequency_shift(I)
I1 = edge(I,'log');
Top_lim =100;
Bot_lim = 270;
I1(Top_lim:Bot_lim,:) = [];
% Calculate hough transform:
[H,T,R] = hough(I1);
% imshow(H,[],'XData',T,'YData',R,...
%             'InitialMagnification','fit');
% xlabel('\theta'), ylabel('\rho');
% axis on, axis normal, hold on;
% Find peaks and lines in the image:
Hough_threshold = 0.85;
P  = houghpeaks(H,15,'threshold',ceil(Hough_threshold*max(H(:))));
lines = houghlines(I1,T,R,P);
while true
    if length(lines) == 1  && abs(lines.theta)>=-5 && abs(lines.theta)<=5
        Hough_threshold = Hough_threshold-0.5;
        P  = houghpeaks(H,15,'threshold',ceil(Hough_threshold*max(H(:))));
        lines = houghlines(I1,T,R,P);
    else
        break;
    end
end

dist = 0;
for k = 1:length(lines)
    if norm(lines(k).point1 - lines(k).point2) > dist
        scanline_angle = lines(k).theta;
        if abs(scanline_angle)>=-5 && abs(scanline_angle)<=5
            continue;
        end
        if scanline_angle>0
            scanline_angle = scanline_angle-180;
        end
        dist = norm(lines(k).point1 - lines(k).point2);
        xy = [lines(k).point1; lines(k).point2];
        if xy(1,2)>=Top_lim
            xy(:,2) = xy(:,2) + (Bot_lim-Top_lim);
        end
    end
end

% imshow(I,[]),hold on
% plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','cyan');
% hold off


end

function Corrected_Image = Skew_correction(Image)
Fs = 44100;
temp_I = Image(1:367*512);
% imshow(reshape(temp_I(1:367*512),[],512),[]);
% temp_I(end-mod(length(Image),512)+1:end) = [];
% for k = 1:2
    scanline_angle = find_scanline_frequency_shift(reshape(temp_I,[],512));
    New_Fs = Angle_to_frequency(scanline_angle,Fs);

    I =  resample(Image,New_Fs,Fs);
    temp_I = I(1:floor(length(I)/512)*512);
%     temp_I = imresize(reshape(temp_I,[],512),[512,367]) 
%     Fs = New_Fs;
% end
% I(end-mod(length(I),512)+1:end) = [];
Corrected_Image = reshape(imcomplement(temp_I),[],512);
% imshow(Corrected_Image,[]);   
end

function New_fs = Angle_to_frequency(Angle,Fs)
New_fs = fix((-Angle*1.6572874035 + 39266));
end

