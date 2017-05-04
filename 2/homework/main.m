% MAIN script for Small yellow bike stolen case.
%
% Zhou Lvwen: zhou.lv.wen@gmail.com
% 4 May, 2017

file = 'crime.dat';
% string format of 'Suspects location information'
ssfmt = '\s{0,}[A-Z]\,\s{0,}\d{1,}\,\s{0,}\d{1,}';
% string format of 'Crime time and space information'
stfmt = '\s{0,}\d{1,}\/\s{0,}\d{1,}\/\d{1,}\,\s{0,}\d{1,}\,\s{0,}\d{1,}';

is = 1; nsus = 3; % index and number of suspects
ic = 1; ncrm = 7; % index and number of crimes

[xs, ys, ps] = deal(zeros(nsus,1));  % Suspects location: (xs, ys)
[xc, yc, tc] = deal(zeros(ncrm,1));  % Crimes spatiotemporal: (xc, yc, tc)

% Read data from file
fid = fopen(file,'r');
tline = fgetl(fid);
while ischar(tline)
    if ~isempty(regexp(tline, ssfmt, 'match'))
        data = regexp(tline, ',', 'split');
        xs(is) = str2num(data{2});
        ys(is) = str2num(data{3});
        is = is + 1;
    elseif ~isempty(regexp(tline, stfmt, 'match'))
        data = regexp(tline, ',', 'split');
        tc(ic) = datenum(data{1},'dd/mm/yyyy');
        xc(ic) = str2num(data{2});
        yc(ic) = str2num(data{3});
        ic = ic + 1;
    end
    tline = fgetl(fid);
end
fclose(fid)

map = imread('map.png');
[m, n, ~] = size(map);

gamma = 1/1000;
P = zeros(m,n);
[X,Y] = meshgrid(1:n,1:m);

% temporal weight 
w = 1/5 + (tc-min(tc))/(max(tc)-min(tc)); w = w/sum(w);

for k = 1:ncrm
    dist = abs(X-xc(k)) + abs(Y-yc(k)); % Mahalanobis distance 
    P = P + w(k).*exp(-gamma*dist);     % Sum probability
end
P = P/sum(P(:));

image(map); hold on; axis image; 
alpha(imagesc(P),0.5);
plot(xs,ys,'xr', xc,yc,'ob', 'linewidth',2);

for k = 1:nsus
   dist = sqrt((X-xs(k)).^2 + (Y-ys(k)).^2);
   ps(k) = sum(P(dist<50));
end

fid = fopen('prob.txt','wt')
fprintf(fid,'Results of small yellow bike stolen case\n\n');
fprintf(fid,'(%3s,%3s) %8s\n','x','y', 'prob');
fprintf(fid,'(%3d,%3d) %8.4f\n', [xs, ys, ps]');
fclose(fid)
