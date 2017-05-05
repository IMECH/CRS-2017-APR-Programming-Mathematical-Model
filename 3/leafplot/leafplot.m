colormap('jet')

subplot(2,3,1)
leaf = imread('leaf04.png');
image(leaf); axis image;

subplot(2,3,2)
%R = leaf(:,:,1);
%R(R<80)=1; R(R>=80)=0;
R = double(im2bw(leaf,80/255));
imagesc(R)
axis image

% ------------------------------------------------------------------------

subplot(2,3,3)
[sy,sx] = size(R);
nx = 2:sx-1; ny = 2:sy-1;
leaf = R(ny,nx);
in =            R(ny+1,nx)& ...
     R(ny,nx-1)&R(ny  ,nx)&R(ny,nx+1)& ... 
                R(ny-1,nx);
leaf(in) = 2;
imagesc(leaf)
axis image

% -------------------------------------------------------------------------

subplot(2,3,4)
[y, x] = find(leaf==2);
xmin = min(x)-1; xmax = max(x)+1;
ymin = min(y)-1; ymax = max(y)+1;
imagesc(leaf); hold on
plot([xmin,xmin xmax xmax xmin], ...
     [ymin,ymax,ymax,ymin ymin],'w');
axis image

% -------------------------------------------------------------------------

subplot(2,3,5)
imagesc(leaf)
hold on
plot([xmin,xmin xmax xmax xmin], ...
     [ymin,ymax,ymax,ymin ymin],'w');
for i = 1:4
    plot([xmin,xmax],[ymin,ymin]+(ymax-ymin)/4*i,'w')
end
axis image

% -------------------------------------------------------------------------

subplot(2,3,6)
[h area]=convhull(x,y);
imagesc(leaf)
hold on
plot(x(h),y(h),'w','linewidth',2);
axis image