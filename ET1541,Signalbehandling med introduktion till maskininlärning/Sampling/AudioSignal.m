%F�r PC med Data Acquisition Toolbox (DAT) och add-on instalerad b�r detta skript
%fungera som den �r. F�r Mac, se nedanf�r f�r mer info.
clear all
close all
clc

%Mac datorer
%Tyv�rr st�ds inte Data Acquisition Toolbox, s� inspelning av ljud m�ste
%ske via extern mjukvara. Anv�nd sedan audioread() f�r att l�sa in data in
%i MATLAB fr�n audiofilen. Alternativt samarbeta med n�gon som har en PC
%dator.

%PC dator 
d = daq.getDevices;%hittar h�rdvaran som st�ds av DAT p� datorn
dev = d(2);%kontrolerar att index d�r mikrofonerna detekterades av MATLAB �r samma, annars byt index

s = daq.createSession('directsound');
addAudioInputChannel(s, dev.ID, 1:2);%skapar ing�ng f�r audio med tv� kanaler (nuf�rtiden vanligt att b�rbara PC datorer har tv� mikrofoner

s.Rate = 192000; %samplingsfrekvensen i Hz
s.DurationInSeconds = 4;%inspleningstid i sec

'start' %printas ut i Comman Window n�r inspelning b�rjar, h�r kan du b�rja prata eller spela upp musik
[data,time] = s.startForeground;%startar ispelning och ger audio data med tv� kanaler i data samt tidsaxeln i time efter inspelning avslutats
'stop' %printas ut i Comman Window n�r inspelning avslutat.

%Kopierar relevant data som nyttjas i nedanst�ende kod
audio=data(:,1); %audio fr�n kanal ett, f�r kanal tv� byt 1 till 2
fs=s.Rate; %samplingsfrekvens
t=time; %tidsvektirn

%PC och Mac
%Generell kod om st�ds av b�de PC och Mac. Se bara till att parametrar:
%audio (inneh�ller den samplad ljud)
%fs (�r samplingsfrekvensen)
%t (inneh�ller tidsaxel)
%har f�tt den relevanta data

fs=1000;
soundsc(audio,fs);%spela upp ljudet

%plottar audio tidssignalen
figure(1)
plot(t,audio);
xlabel('Time (secs)');
ylabel('Amplitude')

%plottar frekvensinneh�llet (kr�ver Signal Processing Toolbox)
%mer om detta senare i kursen n�r vi behandlar kapitel 8
%h�r �r den med bara f�r att ge lite inblick i frekvensinneh�llet
figure(2)
spectrogram(audio,'yaxis')