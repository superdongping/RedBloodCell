function [cell_number]=RedBloodCounter2(tif_stack,StartFrame,EndFrame)


% This program is used to count the red blood cell number from the bright
% field images.
% The raw tif image should be together with this program
% If there is any question, contact Ping Dong via ping.dong@duke.edu
%

clc;
close all;
warning off;

disp('Raw images loaded!')

cell_number=[];

for k=StartFrame:EndFrame
    % k=[tif_number];

    % k=1;
    % figure(1)

    I=tif_stack {k};

    bw = I;
    % figure(01)
    % imshow(bw)
    % figure(100)
    % h_fig=figure(100);
    %  I_BW = ~im2bw(I, 0.45);

    I_BW = ~imbinarize(I, 'adaptive','ForegroundPolarity','dark');

    % imshow(I_BW)
    bw=I_BW;

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


    mask = imextendedmin(D,2);
    % imshowpair(bw,mask,'blend')


    D2 = imimposemin(D,mask);
    Ld2 = watershed(D2);
    bw3 = bw;
    bw3(Ld2 == 0) = 0;
    % imshow(bw3)

% dilation 
    se90 = strel('line',1,90); %  se90 = strel('line',2,90);
    se0 = strel('line',1,0);

    BWsdil = imdilate(bw3,[se90 se0]);
    % imshow(BWsdil)
    % title('Dilated Gradient Mask')



    BWdfill = imfill(BWsdil,'holes');
    % imshow(BWdfill)


    I_s_BW_m2 = medfilt2(BWdfill,[3,3]); % Medium Filter, get rid of pepper noise

    % imshow(I_s_BW_m2);



    BWdfill = imfill(I_s_BW_m2,'holes');
    % imshow(BWdfill)
    %

    % Count the connected area
    L = bwlabeln(I_s_BW_m2, 8);
    S = regionprops(L, 'Area');
    area_H=6000;
    area_L=80;


    % Count the connected area
    L = bwlabeln(I_s_BW_m2, 8);
    S = regionprops(L, 'Area');
    pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);  % To be set the area threshold
    pos_ex = ~pos;
    bw2 = ismember(L, find(pos));
    bw2_ex = ismember(L, find(pos_ex));


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
    figure(105);
    imshow(I)
    hold on;


    plot(C1(:,1), C1(:,2), 'r+', 'MarkerSize', 10);
    %  plot(C1_ex(:,1), C1_ex(:,2), 'g+', 'MarkerSize', 10);
    hold off;
    %  title([tmp_file, '  Cell Number:', num2str(N)]);

    pos = ([S.Area] <= area_H) & ([S.Area] >= area_L);

    bw2 = ismember(L, find(pos));
    S1 = [S.Area];
    S1 = S1(pos);
    C = regionprops(bw2, 'Centroid');  % to be processed
    % Get the center of connected areas
    C1 = [C.Centroid];
    C1 = reshape(C1, 2, length(C1)/2)';
    c_pos=C1;

    cell_number=[cell_number;N];
end

figure(300)
subplot(2,1,1)
plot(cell_number)
% ylim([0 100])
xlabel('Image number')
ylabel('Red_blood_cell_number')
% title('raw data')


xlswrite('total_red_blood_cell.xlsx',cell_number)

end