clc;
clear all;
close all;
warning off;

file=dir('*.lsm');
filename=file.name;

% [Data LSMinfo] = lsmread(fileName);

% [stack, img_read] = tiffread2(filename, img_first, img_last);
[stack, img_read] = tiffread2(filename);


img_number=img_read/2;
StartFrame=1;
% EndFrame=140;
EndFrame=img_number;

%%
% load BF image of red blood cells from LSM channel 2
for ii=1:img_number
    BF_red_blood_tif_stack{ii}=stack(ii*2-1).green;
end
disp('Red_blood_cell_BF_data_loaded!')




[cell_number]=RedBloodCounter2(BF_red_blood_tif_stack,StartFrame,EndFrame);
%%

% load PS image of red blood cells from LSM channel 1
for ii=1:img_number
    PS_red_blood_tif_stack{ii}=stack(ii*2-1).red;
end
disp('Red_blood_cell_PS_data_loaded!')

[PS_cell_number,PS_intensity]=PS_SignalCounter(PS_red_blood_tif_stack,StartFrame,EndFrame);