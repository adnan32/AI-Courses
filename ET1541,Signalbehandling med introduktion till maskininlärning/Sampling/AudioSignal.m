%För PC med Data Acquisition Toolbox (DAT) och add-on instalerad bör detta skript
%fungera som den är. För Mac, se nedanför för mer info.
clear all
close all
clc

%Mac datorer
%Tyvärr stöds inte Data Acquisition Toolbox, så inspelning av ljud måste
%ske via extern mjukvara. Använd sedan audioread() för att läsa in data in
%i MATLAB från audiofilen. Alternativt samarbeta med någon som har en PC
%dator.

%PC dator 
d = daq.getDevices;%hittar hårdvaran som stöds av DAT på datorn
dev = d(2);%kontrolerar att index där mikrofonerna detekterades av MATLAB är samma, annars byt index

s = daq.createSession('directsound');
addAudioInputChannel(s, dev.ID, 1:2);%skapar ingång för audio med två kanaler (nuförtiden vanligt att bärbara PC datorer har två mikrofoner

s.Rate = 192000; %samplingsfrekvensen i Hz
s.DurationInSeconds = 4;%inspleningstid i sec

'start' %printas ut i Comman Window när inspelning börjar, här kan du börja prata eller spela upp musik
[data,time] = s.startForeground;%startar ispelning och ger audio data med två kanaler i data samt tidsaxeln i time efter inspelning avslutats
'stop' %printas ut i Comman Window när inspelning avslutat.

%Kopierar relevant data som nyttjas i nedanstående kod
audio=data(:,1); %audio från kanal ett, för kanal två byt 1 till 2
fs=s.Rate; %samplingsfrekvens
t=time; %tidsvektirn

%PC och Mac
%Generell kod om stöds av både PC och Mac. Se bara till att parametrar:
%audio (innehåller den samplad ljud)
%fs (är samplingsfrekvensen)
%t (innehåller tidsaxel)
%har fått den relevanta data

fs=1000;
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
spectrogram(audio,'yaxis')