clear all
close all
songs_dir = './lib_mezzi';
threshold = 125;

% read songs list
cd(songs_dir);
songList = dir('*.mp3');
nSongs = size(songList, 1);

%load songs
fprintf("Loading library")
for i = 1: nSongs
    [tracks{i}, fs{i}] = audioread(songList(i).name);
    %fprintf('Size: %d, Fs: %d\n', size(tracks{i},1), fs{i})
end
fprintf("Done.\n")

%transform every song in a one channel track
for j = 1: nSongs
    matchOptions{j} = tracks{j}(:,1);
end

info = audiodevinfo;
info = info.input;
fprintf("\nSelect Microphone:")
for n = 1: length(info)
    fprintf("\n" + info(n).ID + ") " +info(n).Name)
end
mic = input("\n\nWhat microphone would you like to use? >");

% eseguo la cross correlazione
fprintf('\nListening...');

%get ready for recording
recorder = audiorecorder(48000,16,1,mic);
%record 12 seconds
recordblocking(recorder,12);
fprintf('Done.\n');
%while we're computing audio, play what we recorded
play(recorder);

fprintf("Computing..")
%go back to the directory where we have the functions files.
cd("..");
%start timer
tic;
%shazam
[songID,indx] = shazy(matchOptions, nSongs, recorder);
t=toc;
fprintf("Done.\n")

%play the result (oh yes oh yes)
result=audioplayer(matchOptions{songID}(indx:end), fs{songID});
play(result);

%here we are, print the results
if songID >= 1
  fprintf("\nI think this is: %s a %d secondi.\n", extractBefore(songList(songID).name, '.mp3'), int16(indx/fs{songID}));
else 
  fprintf("\nNo matches\n");
end

fprintf("Time: %d sec\n\n", int8(t));

