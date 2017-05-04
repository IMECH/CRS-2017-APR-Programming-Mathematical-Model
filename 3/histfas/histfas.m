function histfas(folder)
% HISTFAS: hist focal adhesions form tif files
%  zhou lvwen: zhou.lv.wen@gmail.com
%  8/20/2015

%% path & files
if nargin==0; folder=''; end
if ~isdir('results'); mkdir('results'); end 

path = ['images/',folder,'/']; % tifs' path
tifs = dir([path,'*.jpg']);       % tifs' name
ntifs = size(tifs,1);
xls = ['results/',folder];     % output excell file

%% parameters
p = 0.2;                   % Brightness threshold: exclusive of R < max(R)*p
ncnd = 4;                  % specifies 4-connected objects, can be 4 or 8
im_uint = 16;
warning off MATLAB:xlswrite:AddSheet;

%% size rank
sml =  32;                 % small : sml <= size < mde
med =  48;                 % medium: mde <= size < big
big = 400;                 % big   : big <= size
rank = [sml, med, big];
ntot = zeros(ntifs,1);
nrank = zeros(ntifs, length(rank)); % number of fas labed as each size rank 

xlswrite(xls, {'case','tot','sml','med','big'}, 'Sheet1', 'A1');
xlswrite(xls, {'PARAMETERS', ''; '',''; 'p:', p;                ...
               'tot:', [num2str(sml),'<=size ',             ]; ...
               'sml:', [num2str(sml),'<=size<', num2str(med)]; ...
               'med:', [num2str(med),'<=size<', num2str(big)]; ...
               'big:', [num2str(big),'<=size ']}, 'Sheet2', 'A1');

%% 
fprintf([repmat('=',1,26), folder, repmat('=',1,26), '\n']);
for i = 1:ntifs
    tif = tifs(i).name;           % k-th tif file
    fprintf([tif, ' ... read ...']);   
    RGB = imread([path, tif]); % read image: red & green & blue
    R = RGB(:,:,1);            % red

    level = p * im2double(max(R(:)));
    bw = im2bw(R, level); 
    
    fprintf(' hist ...');   
    [fa, nfa] = bwlabel(bw, ncnd);
    fasize = hist(fa(fa>0), 1:nfa);

    fasize = fasize(fasize>=sml)';
    ntot(i) = length(fasize);
    
    lb = rank; ub = [rank(2:end) inf];
    for j = 1:length(rank);
       nrank(i,j) = sum( lb(j)<=fasize & fasize<ub(j) );
    end
   
    fprintf(' write ...'); 
    
    if isempty(fasize); fasize=NaN; end
    xlswrite(xls, fasize, tif, 'A1');
    fprintf(' done! [%2d/%2d] \n', i, ntifs);
end
xlswrite(xls, {tifs.name}',  'Sheet1', 'A2');
xlswrite(xls, [ntot, nrank], 'Sheet1', 'B2');
