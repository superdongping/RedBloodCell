function [PS_cell_number,PS_intensity]=PS_SignalCounter(tif_stack,StartFrame,EndFrame)


% This program is used to count the PS+ number and intensity from the fluorescence image
% The raw tif image should be together with this program
% If there is any question, contact Ping Dong via ping.dong@duke.edu


% clc;
% clear all;
% close all;
warning off;
% 
% tif_file=dir('*.tif');
% tif_number=size(tif_file,1);
% 
% % Load the orignal files and display
% figure(100)
% 
% for i=1:1:tif_number
%     tif_stack {i} = imread(tif_file(i).name) ; % read in first image
%     %     imshow(tif_file(i).name)
%     
% end
% 
% disp('Raw images loaded!')

%%

PS_cell_number=[];
PS_intensity=[];
for k=StartFrame:EndFrame

    I=tif_stack {k};
    
%     figure(105)
%     imshow(I)
    
    PS_intensity_tmp=sum(I(:));
    PS_intensity=[PS_intensity;PS_intensity_tmp];
    
%     title('Original image');
    
    
%     figure(200)
%     h_fig = figure;
    % threshold the image
        I_BW = im2bw(I, 0.014); % to be set 0~1
%     I_BW = imbinarize(I, 'adaptive','ForegroundPolarity','bright');
    
%     imshow(I_BW)
    title('Threshold image');
    
    %      figure(201)
    %     bw2 = ~bwareaopen(~I_BW, 40);
    %     imshow(bw2)
    %
    I_s_BW_m = medfilt2(I_BW,[2,2]); % Medium Filter, get rid of pepper noise
    % figure(7);
%     imshow(I_s_BW_m);
    
    se90 = strel('line',5,90);
    se0 = strel('line',5,0);
    
    BWsdil = imdilate(I_s_BW_m,[se90 se0]);
%     imshow(BWsdil)
%     title('Dilated Gradient Mask')
    
    BWdfill = imfill(BWsdil,'holes');
%     imshow(BWdfill)
%     title('Fill the holes')

    bw2 = ~bwareaopen(~BWdfill, 100);
% imshow(bw2)

D = -bwdist(~bw2);
% imshow(D,[])

Ld = watershed(D);
% imshow(label2rgb(Ld))

% bw2 = bw;
bw2(Ld == 0) = 0;
% imshow(bw2)


mask = imextendedmin(D,2);
% imshowpair(bw2,mask,'blend')


D2 = imimposemin(D,mask);
Ld2 = watershed(D2);
bw3 = bw2;
bw3(Ld2 == 0) = 0;
% imshow(bw3)   
    
% %     I_s_BW_m2 = medfilt2(bw2,[6,6]); % Medium Filter, get rid of pepper noise
%     figure(8);
%     imshow(I_s_BW_m2);
%     

    % Count the connected area
    L = bwlabeln(bw2, 8);
    
    S = regionprops(L, 'Area');
    area_H=6000;
    area_L=100;    

    pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);  % To be set the area threshold
    pos_ex = ~pos;
    bw2 = ismember(L, find(pos));
    bw2_ex = ismember(L, find(pos_ex));
    
    % Plot normal and exceptions
    %{
    figure(101);
    imshow(bw2);
    figure(102);
    imshow(bw2_ex);
    %}
    
    S1 = [S.Area];
    S1 = S1(pos);  % Final Area and number of connected regions
    
    N = length(S1);  % Number
    disp('Cell Number:')
    disp(N);
    
    % Get the center of connected areas
    C = regionprops(bw2, 'Centroid');  % to be processed
    C1 = [C.Centroid];
    C1 = reshape(C1, 2, length(C1)/2)';
    
    % For exception
    C_ex = regionprops(bw2_ex, 'Centroid');  % to be processed
    C1_ex = [C_ex.Centroid];
    C1_ex = reshape(C1_ex, 2, length(C1_ex)/2)';
    
    
    % Mark the connected region on the orignal picture
    figure(205);
    imshow(I_BW)
    hold on;
    plot(C1(:,1), C1(:,2), 'r+', 'MarkerSize', 10);
%     plot(C1_ex(:,1), C1_ex(:,2), 'g+', 'MarkerSize', 10);
    hold off;
    %     title([tmp_file, '  Cell Number:', num2str(N)]);
    
    
    pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);
    
    bw2 = ismember(L, find(pos));
    S1 = [S.Area];
    S1 = S1(pos);
    C = regionprops(bw2, 'Centroid');  % to be processed
    % Get the center of connected areas
    C1 = [C.Centroid];
    C1 = reshape(C1, 2, length(C1)/2)';
    c_pos=C1;    
    
    PS_cell_number=[PS_cell_number;N];
end

sheet1 = 'PS_cell_no';
sheet2 = 'PS_intensity';
% xlswrite(filename,A,sheet,xlRange)


xlswrite('PS_positive_cell_number_and_intensity.xlsx',PS_cell_number,sheet1)
xlswrite('PS_positive_cell_number_and_intensity.xlsx',PS_intensity,sheet2)


figure(301)
subplot(2,1,1)
plot(PS_cell_number)
% ylim([0 100])
xlabel('Image number')
ylabel('PS+ number')
% title('raw data')

subplot(2,1,2)
% PS_cell_number_ratio_s=smooth(PS_cell_number_ratio,5);

plot(PS_intensity)
% ylim([0 100])
xlabel('Image number')
ylabel('PS+ intensity%')
% title('after smooth')

end
