# Image-Compression
image thresholding otsu method in the discrete blocks of size defined by the user in the
matlab code.This depends on the colormap of the image that whether the image is gray scale
or RGB.

FOR RGB IMAGE:
If the image is RGB then we will first extract the luminance and chrominance components of
the image and then we will do chroma down sampling which will compress only the
chrominance part that is only the color information.This is because we are much more
sensitive to changes in luminance (brightness) than we are to chrominance (color)
differences. Because of this, the JPEG format can discard a lot more color information than
luminance in the compression process. To facilitate the different compression requirements of
the two &quot;channels&quot; of image information, the JPEG file format translates 8-bit RGB data
(Red, Green, Blue) into 8-bit YCbCr data (Luminance, Chroma Blue, Chroma Red). Now,
with the brightness seperated into a separate data channel, it is much easier to change the
compression algorithm used for one channel versus the others.
Then we will apply DCT compression algorithm in the blocks of (NXN) to further compress
the image.After that we will apply otsu thresholding method to rank each block.The ranking
of each block is done on the basis of minimum class variance.Those blocks will get the
higher rank whose no. of pixels have value greater intensity value than the minimum class
variance.
After that quantization of the blocks is done on the basis of ranks.Those blocks will be
quantized more who got higher ranks.Then the image is encoded and the compressed image
and the rank information is stored in a different matrix.

For Gray Scale Images:

In gray scale Images there is no need to transform the image into ycbcr.As there is only
luminous part only so there is no need of chroma sampling also.Rest of the process remains
the same for gray scale images.
