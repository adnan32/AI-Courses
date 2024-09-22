clear all
close all
clc

b=[1 -1]; %bk koefficienter f�r LTI FIR system. I detta exemlep �r det one sample difference
N=1024;%Antal punkter i DFT
dw=2*pi/N;%delta omega, frekvens uppl�sning
kv=-N/2:N/2;%koefficienter k i den fulla DFT


%Systemets frekvenssvar genom Npt-DFT 
B=fft(b,N);

%Systemets Magnituden
Babs=abs(B);%Absolut beloppet 
Babs2=[Babs(N/2+1:end) Babs(1:N/2+1)];%Negativa delen i en DFT ligger i andra halvan av vktorn s� m�ste byta plats (se figure 8-5 i kursboken)
figure
plot(kv*dw,Babs2)
xlabel('Frequency [rad]')
ylabel('Magnitude')

%Systemets Fas
Bfas=angle(B);%Ber�knar fasen med r�tt kvadrant faskompensering (ekvivalent atan2(imag(B),real(B)), eller atan2d(imag(B),real(B)) f�r att f� svar i grader)
Bfas2=[Bfas(N/2+1:end) Bfas(1:N/2+1)];%Negativa delen i en DFT ligger i andra halvan av vktorn s� m�ste byta plats (se figure 8-5 i kursboken)
figure
plot(kv*dw,Bfas2)
xlabel('Frequency [rad]')
ylabel('Phase [rad]')

%Testsignalen
n=0:N-1;
A=2; %Amplitud
k=171;%ger systemets Babs(k+1)=1.0018 och Bfas(k+1)=1.0462 rad (kompensering f�r MATLABs vektor index b�rjar p� 1)
fas=0; %Fas angiven i grader
s=A*sin((2*pi/N)*k*n+fas*(pi/180)); %ren signal

y=conv(s,b,'same');%faltnin av signalen med systemet
figure
plot(n(1:end-1),y(1:end-1))%y(1:end-1) kan beh�vas skjusteras om f�rdr�jd i f�rh�llandet till s2(2:end) 
hold on

%refferenssignal
s2=Babs(k+1)*A*sin((2*pi/N)*k*n+fas*(pi/180)+Bfas(k+1));
plot(n(1:end-1),s2(2:end),'--k')%s2(2:end) kan beh�vas skjusteras om f�rdr�jd i f�rh�llandet till y(1:end-1)
hold off
 

