function n = NumAdheredCell(video, t, dt, isplot)
%% NumAdheredCell: 
%  Hist number of adherent cells at specified time from the video
%
%% Author
%  Zhou Lvwen: zhou.lv.wen@gmail.com
%  March 31, 2016
%%

if nargin==2; dt = 1; isplot = 0; end
if nargin==3;         isplot = 0; end

im2bwLevel = 0.88;           % im2bw level. For detail, help im2bw
sizeRange = [1 6];           % radius range
sizethr = 1.7;               % size threshold
fdcircsen = 0.97;            % sensitivity factor. in [0,1]
warning('off','all');        % disabled warning

% print computing processes: read
pathnametype = regexp(video, '[/\.]','split');
name = pathnametype{end-1};
fprintf('%15.15s', [' ',name,': ']);
fprintf(' read ...');

obj = VideoReader(video);
Nframes = obj.NumberOfFrames;
FrameRate = obj.Framerate;
iframe = (t-dt) * FrameRate;
jframe = (t+dt) * FrameRate;
n = NaN*ones(size(t));

% print computing processes: hist
fprintf('hist ');

for k = 1:length(t)
    fprintf('.');
    % skip the time that does not contain in the video file.
    if iframe(k)<0 | jframe(k)>Nframes; continue; end
    
    % read frames at two specified time t(k)-dt and t(k)+dt; 
    framei = read(obj,iframe(k));
    framej = read(obj,jframe(k));
    
    % convert image to binary image by thresholding
    bwi = im2bw(framei,im2bwLevel);
    bwj = im2bw(framej,im2bwLevel);
    
    % superimpose one frame on the other.
    bw = bwi & bwj; 
    
    % find cells (circles) in bw
    [centers, radii] = imfindcircles(bw, sizeRange, 'ObjectPolarity', ...
        'bright', 'Sensitivity',fdcircsen);
    
    % delete unqualified circles
    [centers, radii] = Del2SmallCircs(centers, radii, sizethr);
    [centers, radii] = Del2CloseCircs(centers, radii);
    
    n(k) = length(radii);    % number of cells (circles)
    
    % plot the evidence image for check
    if isplot; plotframe(framei, framej, centers, radii); drawnow; end
end
fprintf(' done!\n');

% -------------------------------------------------------------------------

function [centers, radii] = Del2SmallCircs(centers, radii, sizethr)
% delete circles that raddi < sizethr
centers(radii<sizethr,:) = [];
radii(radii<sizethr) = [];

% -------------------------------------------------------------------------

function [centers, radii] = Del2CloseCircs(centers, radii)
% delete duplicate cells (circles)
del = [];
for i = 1:length(radii)
    for j = i+1:length(radii)
        ci = centers(i,:); ri = radii(i);
        cj = centers(j,:); rj = radii(j);
        if norm(ci-cj)<(ri+rj)/2;
            del = [del; j];
        end
    end
end
centers(del,:) = [];
radii(del,:) = [];

% -------------------------------------------------------------------------

function h = plotframe(framei, framej, centers, radii)
% plot the evidence image for check
R = framei(:,:,1); G = framej(:,:,2); B = zeros(size(R));
image(cat(3,R,G,B));
h = viscircles(centers,radii,'EdgeColor','b');