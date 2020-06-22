clear all
close all
songs_dir = './lib_mezzi';
threshold = 125;

% read songs list
cd(songs_dir);
songList = dir('*.mp3');
n_songs = size(songList, 1);

%load songs
fprintf("Loading library..")
for i = 1:n_songs
    [track, this_fs] = audioread(songList(i).name);
    fs{i} = this_fs;
    matchOptions{i} = track(:,1);
    %fprintf('Size: %d, Fs: %d\n', size(tracks{i},1), fs{i})
end
fprintf("Done.\n")


%select mic
info = audiodevinfo;
info = info.input;
fprintf("\nSelect Microphone:")
for n = 1: length(info)
    fprintf("\n" + info(n).ID + ") " +info(n).Name)
end
mic = input("\n\nWhat microphone would you like to use? >");


fprintf('\nListening...');
%get ready for recording
recorder = audiorecorder(48000,16,1,mic);
%record 
sec_to_record=10;
recordblocking(recorder,sec_to_record);
fprintf('Done.\n');
%while we're computing audio, play what we recorded
play(recorder);

fprintf("Computing..")
%go back to the directory where we have the functions files.
cd("C:\Users\giaco\Documents\UNIVR\III ANNO\II sem\elaboratoESI\");
%start timer
tic;
%shazam
[songID,indx,maxValues] = shazy(matchOptions, n_songs, recorder);
t=toc;
fprintf("Done.\n")

%play the result (oh yes oh yes)
result=audioplayer(matchOptions{songID}(indx:indx+20*fs{songID}), fs{songID});
play(result);

%here we are, print the results
if songID >= 1
  fprintf("\nI think this is: %s a %d secondi.\n", extractBefore(songList(songID).name, '.mp3'), int16(indx/fs{songID}));
else 
  fprintf("\nNo matches\n");
end
fprintf("Time: %d sec\n\n", int8(t));

%plotting
figure;
subplot(2,1,1);
plot(getaudiodata(recorder, 'int16'));
subplot(2,1,2);
plot(matchOptions{songID});
figure;
plot([1:n_songs], maxValues);


