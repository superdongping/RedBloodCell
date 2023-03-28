clc;
clear;
close all;
figure
% Load the red blood cell image
img = imread('3.tif');
% subplot(2,2,1)
imshow(img)

% % Convert the image to grayscale
% gray_img = rgb2gray(img);

% Apply a median filter to reduce noise
% figure
med_img = medfilt2(img);
% imshow(med_img)

% Detect the edges of the cell using the Canny edge detection algorithm
edge_img = edge(med_img, 'canny');
% figure
% imshow(edge_img)

% Calculate the edge gradient magnitude and direction
[grad_mag, grad_dir] = imgradient(med_img);

% Threshold the gradient magnitude to identify edges with strong gradients
thresh = 0.1* max(grad_mag(:));
strong_edges = grad_mag > thresh;

% figure
% imshow(strong_edges)


img_filled = imfill(strong_edges, 'holes');
% figure
% imshow(img_filled)

bw=img_filled;

% L = watershed(I_BW);
% Lrgb = label2rgb(L);
% % figure(02)
% imshow(Lrgb)
%
%
% % figure(03)
% imshow(imfuse(bw,Lrgb))
% axis([10 175 15 155])
% % figure(04)

bw2 = ~bwareaopen(~bw, 10);
% imshow(bw2)

D = -bwdist(~bw2);
% imshow(D,[])

Ld = watershed(D);
% imshow(label2rgb(Ld))

bw2 = bw;
bw2(Ld == 0) = 0;
% imshow(bw2)

% figure
mask = imextendedmin(D,2);

%     imshowpair(bw,mask,'blend')
% imshowpair(bw,mask,'montage')

    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw3 = bw;
    bw3(Ld2 == 0) = 0;
%     imshow(bw3)

% % dilation
%     se90 = strel('line',1,90); %  se90 = strel('line',2,90);
%     se0 = strel('line',1,0);
%
%     BWsdil = imdilate(bw3,[se90 se0]);
%     imshow(BWsdil)
%     title('Dilated Gradient Mask')


% figure
    BWdfill = imfill(bw3,'holes');
%     imshow(BWdfill)




% Count the connected area

% area_H=6000;
% area_L=80;


% Count the connected area
L = bwlabeln(BWdfill, 8);
S = regionprops(L, 'Area');
Area_size=struct2cell(S);
Area_size=cell2mat(Area_size);

figure

edges = [200:100:5000];
h = histogram(Area_size,edges);
xlabel("Red Blood Cell Size")
ylabel("Cell Number (n)")

% define the area of the cell size, normal, middle shrink, high shrink
%% user define
Norm_area_lim = [1701 4500]; 
Mid_shrink_area_lim = [500 1700]; 
% High_shrink_area_lim = [500 1500]; 
%%

pos_norm = ([S.Area] <= Norm_area_lim(2)) & ([S.Area] >= Norm_area_lim(1));
pos_Mid = ([S.Area] <= Mid_shrink_area_lim(2)) & ([S.Area] >= Mid_shrink_area_lim(1));



% pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);  % To be set the area threshold
pos=pos_norm;
pos_ex = ~pos;
pos_ex = pos_Mid;
bw2 = ismember(L, find(pos));
bw2_ex = ismember(L, find(pos_ex));


S1 = [S.Area];
S1 = S1(pos);  % Final Area and number of connected regions

% N = length(S1);  % Number
% disp('Cell Number:')
% disp(N);

% Get the center of connected areas
C = regionprops(bw2, 'Centroid');  % to be processed
C1 = [C.Centroid];
C1 = reshape(C1, 2, length(C1)/2)';

% For exception
C_ex = regionprops(bw2_ex, 'Centroid');  % to be processed
C1_ex = [C_ex.Centroid];
C1_ex = reshape(C1_ex, 2, length(C1_ex)/2)';


% Mark the connected region on the orignal picture
figure(105);
imshow(img)
hold on;


plot(C1(:,1), C1(:,2), 'r+', 'MarkerSize', 10);
plot(C1_ex(:,1), C1_ex(:,2), 'g+', 'MarkerSize', 10);
hold off;
%  title([tmp_file, '  Cell Number:', num2str(N)]);

shrink_cell_number = length(C_ex)
normal_cell_number = length(C)
shrink_cell_number_ratio=shrink_cell_number/(shrink_cell_number+normal_cell_number)





% pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);
% 
% bw2 = ismember(L, find(pos));
% S1 = [S.Area];
% S1 = S1(pos);
% C = regionprops(bw2, 'Centroid');  % to be processed
% % Get the center of connected areas
% C1 = [C.Centroid];
% C1 = reshape(C1, 2, length(C1)/2)';
% c_pos=C1;
% 
% cell_number=[cell_number;N];