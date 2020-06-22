clear all
close all
%global needing
global isListening loadingLabel micrgroup startpanel songs_dir albumpanel titleLabel matchLabel image1 image2
isListening = 0;
songs_dir = './lib_mezzi';
threshold = 125;

% ------------------------------ GUI Setup --------------------------------
window = uifigure('Name', 'ourShazam', 'Position',[100 100 640 480]);

loadingLabel = uilabel(window);
loadingLabel.Position = [262 230 117 22];
loadingLabel.Text = 'Caricamento Libreria';

micrgroup = uibuttongroup(window,'Position',[10 211 595 242], 'Visible', 0);
micrgroup.Title = "Microfoni";

firstradio = [11 196 504 22];
info = audiodevinfo;
info = info.input;
for n = 1: length(info)
    height = 218 - (22*n);
    radio = uiradiobutton(micrgroup,'Position',[11 height 504 22]);
    radio.Text = info(n).Name;
end

% pannello start
startpanel = uipanel(window, 'Visible', 0);
startpanel.BorderType = 'none';
startpanel.Position = [1 1 640 202];
image1 = uiimage(startpanel, 'Position', [226 16 190 187], 'ImageClickedFcn', @shazamPushed);
image1.ImageSource = "shazam.jpg";

% pannello album
albumpanel = uipanel(window, 'Visible', 0);
albumpanel.BorderType = 'none';
albumpanel.Position = [1 1 640 202];
uilabel(albumpanel, 'Text', 'Canzone:', 'Position', [226 151 57 22]);
uilabel(albumpanel, 'Text', 'Match a:', 'Position', [230 130 51 22]);
titleLabel = uilabel(albumpanel, 'Text', 'Sconosciuto', 'Position', [282 151 316 22]);
matchLabel = uilabel(albumpanel, 'Text', 'Sconosciuto', 'Position', [282 130 316 22]);
image2 = uiimage(albumpanel, 'Position', [19 14 178 177], 'ImageClickedFcn', @shazamPushed);

% -------------------------  carico libreria  ----------------------------
loadLibrary();


% -----------------------  funzioni supporto ----------------------------
% handler click su shazam
function shazamPushed(hObject, eventdata)
    global isListening
    
    if isListening == 0
        hObject.ImageSource = "shazam.gif";
        isListening = 1;
        doWork();
    else
        hObject.ImageSource = "shazam.jpg";
        isListening = 0;
        
    end
end

% mostro nella gui il match
function setSong(title, match)
    global albumpanel titleLabel matchLabel image2
    
    titleLabel.Text = title;
    matchLabel.Text = int2str(match) + " secondi";
    image2.ImageSource = "cover/" + title + ".png";
    albumpanel.Visible = 1;
end

% caricamento libreria
function loadLibrary()
    global loadingLabel micrgroup startpanel songs_dir matchOptions fs n_songs songList
    
    cd(songs_dir);
    songList = dir('*.mp3');
    n_songs = size(songList, 1);
    %load songs
    for i = 1:n_songs
        [track, this_fs] = audioread(songList(i).name);
        fs{i} = this_fs;
        matchOptions{i} = track(:,1);
        %fprintf('Size: %d, Fs: %d\n', size(tracks{i},1), fs{i})
    end
    
    loadingLabel.Visible = 0;
    micrgroup.Visible = 1;
    startpanel.Visible = 1;
end

% ascolta e calcola il match
function doWork()
    global matchOptions fs n_songs songList image1
    %get ready for recording
    recorder = audiorecorder(48000,16,1,2); %TODO: prendere dalla gui il mic
    %record 
    sec_to_record=10;
    recordblocking(recorder,sec_to_record);
    fprintf('Done.\n');
    %while we're computing audio, play what we recorded
    play(recorder);

    image1.ImageSource = "computing.gif";
    pause(1)%to update image
    
    %go back to the directory where we have the functions files.
    cd("..");
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
      setSong(extractBefore(songList(songID).name, '.mp3'), int16(indx/fs{songID}));
    else 
      fprintf("\nNo matches\n");
      setSong("Nessun match", -1);
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
end

