function im = imreadx(ex)

% Read a training example image.
%
% ex  an example returned by pascal_data.m

image=ex.loader.getImage(ex.imIndex);

im = color(image.img);
if ex.flip
  im = im(:,end:-1:1,:);
end
