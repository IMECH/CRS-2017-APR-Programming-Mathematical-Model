folders = dir('images');
for i = 1:length(folders)
    folder = folders(i).name;
    if strcmp(folder,'.')|strcmp(folder,'..'); continue; end;
    histfas(folder);
end