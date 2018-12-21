close all;
clear all;
clc;
block = 32; % block size for saliancy detection
quality = 1;
im = imread('flowers.bmp');
[m, n, p] = size(im);
YCbCrIm = rgb2ycbcr(im);
y = YCbCrIm(:,:,1);
cb = YCbCrIm(:,:,2);
cr = YCbCrIm(:,:,3);


y1=im2jpeg(y,quality);
y2=jpeg2im(y1);
mode = input('enter downsampling mode\n1)4:4:4\n2)4:2:2\n3)4:2:0\n');

  if(mode==1)
 %%%%%%%%%%%%%%%%%%%%%% 4:4:4 %%%%%%%%%%%%%%%%%%%%%%%%%%%     
      cb1=cb;
       cr1=cr;
                 
       a=im2jpeg(cb1,quality);
       i=jpeg2im(a);

        b=im2jpeg(cr1,quality);
        j=jpeg2im(b);
        cb2 = zeros(m,n);       %upsampling
        cr2 = zeros(m,n);
        cb2=i;
        cr2=j;
%%%%%%%%%%%%%%%%%%%%%%%% 4:2:2 YCbCr ration using replication %%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif(mode==2)
           cb1 = cb;
           cr1 = cr; 
  
           cb1(:,2:2:end) = [];   %%%%%%%%%%%%%%%%%%%%% deleting even columns of cb (downsampling)
           cr1(:,2:2:end) = [];   %%%%%%%%%%%%%%%%%%%%% deleting even columns of cr (downsampling)
    
           a=im2jpeg(cb1,quality);   
           i=jpeg2im(a);
           b=im2jpeg(cr1,quality);
           j=jpeg2im(b);
 
           cb2 = zeros(m,n);       %upsampling
           cr2 = zeros(m,n);

           cb2(:,1:2:end) = i;
           cr2(:,1:2:end) = j;

           cb2(:,2:2:end) = i;
           cr2(:,2:2:end) = j;

%%%%%%%%%%%%%%%%%%%%%%%% 4:2:0 YCbCr ration using replication %%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif(mode==3)
        cb1 = cb;
        cr1 = cr;
       
        %4:2:0
        cb1(:,2:2:end) = [];   %%%%%%%%%%%%%%%%%%%%% deleting even columns of cb (downsampling)
        cb1(2:2:end,:) = [];
        
        cr1(:,2:2:end) = [];   %%%%%%%%%%%%%%%%%%%%% deleting even columns of cr (downsampling)
        cr1(2:2:end,:) = [];
        
        a=im2jpeg(cb1,quality);
        b=im2jpeg(cr1,quality);
        i=jpeg2im(a);
        j=jpeg2im(b);

        cb2 = zeros(m,n);       %upsampling
        cr2 = zeros(m,n);

        cb2(1:2:end,1:2:end) = i;
        cr2(1:2:end,1:2:end) = j;
        
        cb2(1:2:end,2:2:end) = i;
        cr2(1:2:end,2:2:end) = j;

        cb2(2:2:end,2:2:end) = i;
        cr2(2:2:end,2:2:end) = j;
        
        cb2(2:2:end,1:2:end) = i;
        cr2(2:2:end,1:2:end) = j;
                   else
                    error('enter correct choice...');
                
            
        end
           
YCbCrIm1(:,:,1) = y2;
YCbCrIm1(:,:,2) = cb2;
YCbCrIm1(:,:,3) = cr2;

im1 = ycbcr2rgb(YCbCrIm1);
PSNR_after_replication = psnr(im,im1)
Compression_Ratio = imratio(im,y1,a,b)
[mssim_jpeg, ssim_map_jpeg] = ssim(im, im1);
%%%%%%%%%%%%%% Load predefined TAG values to tag %%%%%%%%%%%%%%%%%%
j = input('enter number of threshold' );
t = multi_otsu(im , block, j);
%%%%%%%%%%%%%% Change quality Gradually %%%%%%%%%%%%%%%%%%%%%%%%%%%%

y3 = newim2jpeg_roi(y,t);
roi_y = newjpeg2im_roi(y3,t);
cb3 = newim2jpeg_roi(cb1,t);
roi_cb = newjpeg2im_roi(cb3,t);
cr3 = newim2jpeg_roi(cr1,t);
roi_cr = newjpeg2im_roi(cr3, t);
if(mode==1)
 %%%%%%%%%%%%%%%%%%%%%% 4:4:4 %%%%%%%%%%%%%%%%%%%%%%%%%%%     
     
        cb4 = zeros(m,n);       %upsampling
        cr4 = zeros(m,n);
        cb4=roi_cb;
        cr4=roi_cr;
%%%%%%%%%%%%%%%%%%%%%%%% 4:2:2 YCbCr ration using replication %%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif(mode==2)
            
           cb4 = zeros(m,n);       %upsampling
           cr4 = zeros(m,n);

           cb4(:,1:2:end) = roi_cb;
           cr4(:,1:2:end) = roi_cr;

           cb4(:,2:2:end) = roi_cb;
           cr4(:,2:2:end) = roi_cr;

%%%%%%%%%%%%%%%%%%%%%%%% 4:2:0 YCbCr ration using replication %%%%%%%%%%%%%%%%%%%%%%%%%%%
  elseif(mode==3)
        

        cb4 = zeros(m,n);       %upsampling
        cr4 = zeros(m,n);

        cb4(1:2:end,1:2:end) = roi_cb;
        cr4(1:2:end,1:2:end) = roi_cr;
        
        cb4(1:2:end,2:2:end) = roi_cb;
        cr4(1:2:end,2:2:end) = roi_cr;

        cb4(2:2:end,2:2:end) = roi_cb;
        cr4(2:2:end,2:2:end) = roi_cr;
        
        cb4(2:2:end,1:2:end) = roi_cb;
        cr4(2:2:end,1:2:end) = roi_cr;
           
        end
YCbCrIm_roi(:,:,1) = roi_y;
YCbCrIm_roi(:,:,2) = cb4;
YCbCrIm_roi(:,:,3) = cr4;
im_roi = ycbcr2rgb(YCbCrIm_roi);

% imshow(im), figure;
% imshow(im1),figure;
% imshow(im_roi);
psnr_roi = psnr(im,im_roi)
compression_ratio_after_jpeg_roi_without_overhead = imratio(im,y3,cb3,cr3)   %without overhead
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Overhead Calculation %%%%%%%%%%%%%%
original_size = m*n*p;
compressed_data = original_size/compression_ratio_after_jpeg_roi_without_overhead;
number_of_blocks = m*n/(block*block);
overhead = number_of_blocks*ceil(log2(j))/8;
final_data = compressed_data + overhead;
compression_ratio_after_jpeg_roi_with_overhead = original_size/final_data


[mssim_roi, ssim_map_roi] = ssim(im, im_roi);
