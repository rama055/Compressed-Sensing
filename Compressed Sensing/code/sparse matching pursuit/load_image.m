% image = load_image(name) - Loads the image with the given name, no wavelet.
%
% image = load_image(name, wavelet, wavelevel) - Loads the image with the given
%     name, applies given wavelt at wavelevl. Uses 'per' dwtmode.
%
% image = load_image(name, wavelet, wavelevel, dwtmode) - Loads the image with
%     the given name, applies given wavelt at wavelevl. Uses given dwtmode.
% Written by Radu Berinde, MIT, Jan. 2008


function image = load_image(name, wavelet, wavelevel, dwt_mode)

if nargin < 4
    dwt_mode = 'per';
end

if nargin < 2
    wavelet = '';
    wavelevel = 0;
    dwt_mode = '';
end

image.name = name;
image.wavelet = wavelet;
image.wavelevel = wavelevel;
image.dwtmode = dwt_mode;

image.I = im2double(imread(['Images/' name '.jpg']));

if ~strcmp(wavelet, '')
    dwtmode(image.dwtmode);
    [image.Wc, image.Wl] = wavedec2(image.I, wavelevel, wavelet);
end

