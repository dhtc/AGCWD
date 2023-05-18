function enhanced_image = AGCWD(input_image,varargin)
%AGCWD implemenation code for Efficient contrast enhancement Using
%adaptive gamma correction with weighting distribution
%implementation of image contrast enhancment method in paper:https://ieeexplore.ieee.org/document/6336819/
%--------------------------------------------------------------------------
%   Inputs:
%          input_image: can be either gray image or colorful image
%          parameter  : (optional) weighting parameter for the histogram
%          can be [0,1]. Default is 0.5
%
weighting_parameter=0.5;
if(length(varargin)==1)
    weighting_parameter=varargin{1};
end

image = input_image;

%get the pdf of an image
pdf=get_pdf(image);

%modify the pdf
    %get min and max of pdf
    Max=max(pdf);
    Min=min(pdf);
pdf_w = Max*(((pdf-Min)/(Max - Min)).^weighting_parameter);

%get the cdf of the wieghted pdf
cdf_w=cumsum(pdf_w)/sum(pdf_w);

%create the transformation function
l = (0:(2 ^ 16 - 1));
l_max = 2 ^ 16 - 1;% maximum
for i=1:(2 ^ 16)
    l(i)=l_max * (l(i)/l_max)^(1-cdf_w(i));
end
l=uint16(l);
enhanced_image = image;
%apply the new transformation to the image
[height, width] = size(image);
for i = 1:height
    for j = 1:width
        intensity = enhanced_image(i,j);
        enhanced_image(i,j) = l(intensity+1);
    end
end
end
% *************** helper functions ********************
function pdf = get_pdf(image)
%get the probability density function of an image
% Get histogram:
[pixelCounts, ~] = imhist(image, 2 ^ 16);
% Compute probability density function:
pdf = pixelCounts / numel(image);

end
