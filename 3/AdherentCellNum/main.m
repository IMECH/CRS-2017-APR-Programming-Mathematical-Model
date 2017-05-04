%% Main: Main script for hist number of adherent cells.
%
%% Author
%  Zhou Lvwen: zhou.lv.wen@gmail.com
%  March 31, 2016
%%

t = [ 60  90 120 150 180 210 240 270 300 390 ...
     420 450 480 510 540 570 600 630];           % specified time [unit: s]
 
dt = 1;                                          % time interval  [unit: s]
isplot = 0;

indir = 'videos/';                               % videos directory
folders = dir(indir);                            % sub directories
warning off MATLAB:xlswrite:AddSheet;            % disabled warning for xls

for i = 1:size(folders,1)
    folder = folders(i).name;
    vdir = [indir, folder,'/'];                  % videos' directory
    if ~isdir(vdir)|strcmp(folder,'..'); continue; end;
    
    if folder=='.'; folder = 'videos';  mark = '#'; else mark = '='; end
    fprintf('%-60.60s\n', [repmat(mark,1,34-length(folder)), ' ',...
               folder,' ', repmat(mark,1,length(t)+6)]);
    
    videos = dir([vdir,'*.mp4']);                 % list all videos in vdir
    nvideos = size(videos,1);                    % number of videos
    if nvideos == 0;  % if no videos [the directory is empty]
        fprintf('videos contains no video files !\n'); continue;
    end
    
    % Hist number of adherent cells at specified time from the video
    N = zeros(nvideos, length(t));
    for j = 1:nvideos
        fprintf('[%2d/%2d]', j, nvideos);
        N(j,:) = NumAdheredCell([vdir, videos(j).name], t, dt, isplot); 
    end
    
    % write results to xls files
    xlswrite('results', {videos.name}', folder, 'A2');
    xlswrite('results', [t;N], folder, 'B1');
end