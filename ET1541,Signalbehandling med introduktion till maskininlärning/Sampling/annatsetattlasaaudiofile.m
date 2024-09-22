filename = 'Recording.m4a'; % namnet på ljudfilen
info = audioinfo(filename);
duration = info.Duration;

[data, Fs_orig] = audioread(filename); % läser in ljudfilen med audioread

%disp(['Samplingsfrekvens: ', num2str(Fs_orig), ' HZ']); % skriver ut vald samplingsfrekvens
%disp(['Inspleningstid: ', num2str(duration), ' sekunder']); % skriver ut vald inspelningstid
%disp(data);
audio=data(:,1); %audio från kanal ett, för kanal två byt 1 till 2
fs=Fs_orig; %samplingsfrekvens
t=0:seconds(1/Fs_orig):seconds(duration); %tidsvektirn
%PC och Mac
%Generell kod om stöds av både PC och Mac. Se bara till att parametrar:
%audio (innehåller den samplad ljud)
%fs (är samplingsfrekvensen)
%t (innehåller tidsaxel)
%har fått den relevanta data

soundsc(audio,fs);%spela upp ljudet

%plottar audio tidssignalen
figure(1)
plot(t,audio);
xlabel('Time (secs)');
ylabel('Amplitude')

%plottar frekvensinnehållet (kräver Signal Processing Toolbox)
%mer om detta senare i kursen när vi behandlar kapitel 8
%här är den med bara för att ge lite inblick i frekvensinnehållet
figure(2)
spectrogram(audio(:),'yaxis')