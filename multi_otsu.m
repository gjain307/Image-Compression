function [t]= multi_otsu(im, block, j)

thresh = multithresh(im,j);
[m n p]=size(im);
xm = floor(m/block);
xn = floor(n/block);
t = zeros(xm,xn);
[count x]=imhist(im2uint8(im(:)));              %%%%% histogram for the color image for faster access
p = count/(m*n);
w_back=zeros(1,256);
mean_back=zeros(1,256);
var_back=zeros(1,256);
w_fore=zeros(1,256);
mean_fore=zeros(1,256);
var_fore=zeros(1,256);
within_var=zeros(1,256);
% Calculating Global Threshold using Otsu Method
for i=1:256                         %% Assuming Dark object and bright background 
    w_back(1,i)=sum(p(1:i));
    mean_back(1,i)=sum(p(1:i).*x(1:i))/w_back(1,i);
    var_back(1,i)=sum(((x(1:i)'-mean_back(1,i)).*(x(1:i)'-mean_back(1,i))).*p(1:i)')/w_back(1,i);
    w_fore(1,i)=1- w_back(1,i);
    mean_fore(1,i)=sum(p(i+1:256).*x(i+1:256)) / w_fore(1,i);
    var_fore(1,i)=sum(((x(i+1:256)'-mean_fore(1,i)).*(x(i+1:256)'-mean_fore(1,i))).*p(i+1:256)')/w_fore(1,i);
    within_var(1,i)=w_back(1,i)*var_back(1,i)+w_fore(1,i)*var_fore(1,i);
end
covar =  within_var(thresh);
sorted_covar = sort(covar);     %%% sorting in order
for i=1:j
   rank(i) = find(covar == sorted_covar(i));
end
%rank = seqreverse(rank);   %%%%%%%%% reversing the sequence (optional)
threshold =  thresh(rank)
for k=1:block:m
    for l=1:block:n
        zblock=im(k:k+block-1,l:l+block-1,:);
        for i=1:j
               if find(zblock<=thresh(i))
               b=find(threshold==thresh(i));
               t(ceil(k/block),ceil(l/block))= b;
               break;
               end
        end
        if t(ceil(k/block),ceil(l/block)) == 0
        t(ceil(k/block),ceil(l/block)) = i+1;
        end
            
    end
end
end