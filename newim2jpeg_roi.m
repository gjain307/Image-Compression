function y = im2jpeg_roi(x,t) 
%IM2JPEG Compresses an image using a JPEG approximation.
%   Y = IM2JPEG(X, QUALITY) compresses image X based on 8 x 8 DCT
%   transforms, coefficient quantization, and Huffman symbol
%   coding. Input QUALITY determines the amount of information that
%   is lost and compression achieved.  Y is an encoding structure
%   containing fields: 
%
%      Y.size      Size of X
%      Y.numblocks Number of 8-by-8 encoded blocks
%      Y.t    Quality matrix (as vector)
%      Y.huffman   Huffman encoding structure, as returned by
%                  MAT2HUFF
%
%   See also JPEG2IM.

%   Copyright 2002-2006 R. C. Gonzalez, R. E. Woods, & S. L. Eddins
%   Digital Image Processing Using MATLAB, Prentice-Hall, 2004
%   $Revision: 1.5 $  $Date: 2006/07/15 20:44:34 $
%
%   Revised: 3/20/06 by R.Woods to correct an 'eob' coding problem, to
%   check the 'quality' input for <= 0, and to fix a warning when
%   struct y is created.
% 
% error(nargchk(2,3,  nargin));             % Check input arguments
% if ndims(x) ~= 2 | ~isreal(x) | ~isnumeric(x) | ~isa(x, 'uint8')
%    error('The input must be a UINT8 image.');  
% end
% if nargin ==3 && quality <= 0
%    error('Input parameter QUALITY must be greater than zero.');
% end
% if nargin < 3    
%    quality = 1;   % Default value for quality.
% end       


m = [16 11  10  16  24  40  51  61        % JPEG normalizing array
     12  12  14  19  26  58  60  55       % and zig-zag redordering
     14  13  16  24  40  57  69  56       % pattern.
     14  17  22  29  51  87  80  62
     18  22  37  56  68  109 103 77
     24  35  55  64  81  104 113 92
     49  64  78  87  103 121 120 101
     72  92  95  98  112 100 103 99] ;
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 c = max(t(:));
 quality = zeros(1,c);
 var = 0.1;                     %%%%%% fixing the incremental value for the scaling

 for i=1:c
   quality(i)=1+(i-1)*var;
 end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   m2 = m .* quality;          % m2 is for salient region
%   m1 = m .* quality1;
order = [1 9  2  3  10 17 25 18 11 4  5  12 19 26 33  ...
        41 34 27 20 13 6  7  14 21 28 35 42 49 57 50  ...
        43 36 29 22 15 8  16 23 30 37 44 51 58 59 52  ...
        45 38 31 24 32 39 46 53 60 61 54 47 40 48 55  ...
        62 63 56 64];
[tm,tn]=size(t);                %size of the tag mat
[xm, xn] = size(x);                % Get input size.
x = double(x) - 128;               % Level shift input
r= dctmtx(8);                     % Compute 8 x 8 DCT matrix
a=floor(xm/tm);        %getting block size
b=floor(xn/tn); 
y = zeros(xm, xn);
% Compute DCTs of 8x8 blocks and quantize the coefficients.
for i1=[1:8:xm]
    for i2=[1:8:xn]
        zBLOCK=x(i1:i1+7,i2:i2+7);
        y(i1:i1+7,i2:i2+7) = dct2(zBLOCK);
           for i= 1:c  
               if  t(ceil(i1/a),ceil(i2/b))==i
                   y(i1:i1+7,i2:i2+7) = round(y(i1:i1+7,i2:i2+7)./(m.*quality(i)));
                break;
               end
           end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y = im2col(y, [8 8], 'distinct');  % Break 8x8 blocks into columns
xb = size(y, 2);                   % Get number of blocks
y = y(order, :);                   % Reorder column elements

eob = max(y(:)) + 1;               % Create end-of-block symbol
r = zeros(numel(y) + size(y, 2), 1);
count = 0;
for j = 1:xb                       % Process 1 block (col) at a time
   i = max(find(y(:, j)));         % Find last non-zero element
   if isempty(i)                   % No nonzero block values
      i = 0;
   end
   p = count + 1;
   q = p + i;
   r(p:q) = [y(1:i, j); eob];      % Truncate trailing 0's, add EOB,
   count = count + i + 1;          % and add to output vector
end

r((count + 1):end) = [];           % Delete unusued portion of r
   
y           = struct;
y.size      = uint16([xm xn]);
y.numblocks = uint16(xb);
% y.tag       = uint16(quality1 * 100);
y.huffman   = mat2huff(r);