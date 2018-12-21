clc;
clear all;
close all;
cr =[34.0417 34.1541 33.7467];
a = ( ones(1,3) * (512*512*3) ) ./ cr;
b = a + 2048;
Compression_Ratio = ( ones(1,3) * (512*512*3) ) ./ b