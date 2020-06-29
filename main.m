clear all
close all
%global needing
global isListening loadingLabel micrgroup startpanel songs_dir albumpanel titleLabel matchLabel image1 image2 mediaButton slider useGPU
isListening = 0;
songs_dir = './lib_mezzi/';
threshold = 125;

% ------------------------------ GUI Setup --------------------------------
window = uifigure('Name', 'Mashlab', 'Position',[100 100 640 480]);

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
    radio = uiradiobutton(micrgroup,'Position',[11 height 504 22], 'Tag', int2str(n-1));
    radio.Text = info(n).Name;
end

% pannello start
startpanel = uipanel(window, 'Visible', 0);
startpanel.BorderType = 'none';
startpanel.Position = [1 1 640 202];
image1 = uiimage(startpanel, 'Position', [226 16 190 187], 'ImageClickedFcn', @shazamPushed);
image1.ImageSource = "images/shazam.jpg";
useGPU = uicheckbox(startpanel, 'Text', 'Usa GPU', 'Position', [17 172 80 22]);

% pannello album
albumpanel = uipanel(window, 'Visible', 0);
albumpanel.BorderType = 'none';
albumpanel.Position = [1 1 640 202];
uilabel(albumpanel, 'Text', 'Canzone:', 'Position', [226 151 57 22]);
uilabel(albumpanel, 'Text', 'Match a:', 'Position', [230 130 51 22]);
titleLabel = uilabel(albumpanel, 'Text', 'Sconosciuto', 'Position', [282 151 316 22]);
matchLabel = uilabel(albumpanel, 'Text', 'Sconosciuto', 'Position', [282 130 316 22]);
image2 = uiimage(albumpanel, 'Position', [19 14 178 177], 'ImageClickedFcn', @shazamPushed);
mediaButton = uibutton(albumpanel, 'push', 'Text', '?', 'Position', [226 69 28 26], 'ButtonPushedFcn', @mediaPlayerButton);
slider = uislider(albumpanel, 'Enable', 'off', 'FontColor', [0.9412 0.9412 0.9412], 'Position', [270 82 316 3]);
again = uibutton(albumpanel, 'push', 'Text', 'Riconosci Ancora', 'Position', [490 17 109 22], 'ButtonPushedFcn', @mediaPlayerAgain);

% -------------------------  carico libreria  ----------------------------
loadLibrary();


% -----------------------  funzioni supporto ----------------------------
% handler click su shazam
function shazamPushed(hObject, eventdata)
    global isListening
    
    if isListening == 0
        hObject.ImageSource = "images/shazam.gif";
        isListening = 1;
        doWork();
    else
        hObject.ImageSource = "images/shazam.jpg";
        isListening = 0;
        
    end
end

% handler play pausa
function mediaPlayerButton(hObject, eventdata)
    global player slider
    
    if hObject.Text == "II"
        pause(player);
        slider.Value = 0;
        hObject.Text = "?";
    else 
        play(player);
        hObject.Text = "II";
    end
end

% handler mediaplayer secondi
function mediaPlayerTick(hObject, eventdata)
    global slider
    slider.Value = slider.Value+0.5;
end

%reset gui per riconoscimento
function mediaPlayerAgain(hObject, eventdata)
    global albumpanel isListening image1
    image1.ImageSource = "images/shazam.jpg";
    isListening = 0;
    albumpanel.Visible = 0;
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
    
    %songList = dir(strcat(songs_dir,'*.mp3'));
    %n_songs = size(songList, 1);
    %load songs
    
    %for i = 1:n_songs
    %    [track, this_fs] = audioread(strcat(songs_dir, songList(i).name));
    %    fs{i} = this_fs;
    %    matchOptions{i} = track(:,1);
    %    %fprintf('Size: %d, Fs: %d\n', size(tracks{i},1), fs{i})
    %end
   
    %save("database.mat", 'fs', 'matchOptions', 'n_songs', 'songList');
    
    pause(0.1); %to show gui before loading
    load("database.mat");
    
    loadingLabel.Visible = 0;
    micrgroup.Visible = 1;
    startpanel.Visible = 1;
end

% ascolta e calcola il match
function doWork()
    global matchOptions fs n_songs songList songs_dir image1 player slider micrgroup useGPU
    %get ready for recording
    mic = str2double(micrgroup.SelectedObject.Tag);
    recorder = audiorecorder(48000,16,1,mic);
    %record 
    sec_to_record=10;
    recordblocking(recorder,sec_to_record);
    fprintf('Done.\n');
    %while we're computing audio, play what we recorded
    play(recorder);

    image1.ImageSource = "images/computing.gif";
    pause(0.1)%to update image
    
    %start timer
    tic;
    %shazam
    [songID,indx,maxValues] = shazy(matchOptions, n_songs, recorder, useGPU.Value);
    t=toc;
    fprintf("Done.\n")
    correctsong = songList(songID).name;
    
    %initialize mediaplayer
    player=audioplayer(matchOptions{songID}, fs{songID});
    set(player,'TimerFcn',@mediaPlayerTick, 'TimerPeriod', 0.5);
    sLenght = audioinfo(songs_dir + "/" +correctsong).Duration;
    slider.Limits = [0,ceil(sLenght)];
    
    %here we are, print the results
    if songID >= 1
      fprintf("\nI think this is: %s a %d secondi.\n", extractBefore(correctsong, ".mp3"), int16(indx/fs{songID}));
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

