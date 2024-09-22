clear all
close all
clc

b=[1 zeros(1,10) 0.5]; %bk koefficienter för LTI FIR system. I detta exemlep är det one sample difference
N=1024;%Antal punkter i DFT
dw=2*pi/N;%delta omega, frekvens upplösning
kv=-N/2:N/2;%koefficienter k i den fulla DFT


%Systemets frekvenssvar genom Npt-DFT 
B=fft(b,N);

%Systemets Magnituden
Babs=abs(B);%Absolut beloppet 
Babs2=[Babs(N/2+1:end) Babs(1:N/2+1)];%Negativa delen i en DFT ligger i andra halvan av vktorn så måste byta plats (se figure 8-5 i kursboken)
figure
plot(kv*dw,Babs2)
xlabel('Frequency [rad]')
ylabel('Magnitude')

%Systemets Fas
Bfas=angle(B);%Beräknar fasen med rätt kvadrant faskompensering (ekvivalent atan2(imag(B),real(B)), eller atan2d(imag(B),real(B)) för att få svar i grader)
Bfas2=[Bfas(N/2+1:end) Bfas(1:N/2+1)];%Negativa delen i en DFT ligger i andra halvan av vktorn så måste byta plats (se figure 8-5 i kursboken)
figure
plot(kv*dw,Bfas2)
xlabel('Frequency [rad]')
ylabel('Phase [rad]')

%Testsignalen
n=0:N-1;
A=2; %Amplitud
k=100;%ger systemets Babs(k+1)=1.0018 och Bfas(k+1)=1.0462 rad (kompensering för MATLABs vektor index börjar på 1)
fas=0; %Fas angiven i grader
s=A*sin((2*pi/N)*k*n+fas*(pi/180)); %ren signal

y=conv(s,b,'same');%faltnin av signalen med systemet
figure
plot(n(1:end-1)+5,y(1:end-1))%y(1:end-1) kan behövas skjusteras om fördröjd i förhållandet till s2(2:end) 
hold on

%refferenssignal
s2=Babs(k+1)*A*sin((2*pi/N)*k*n+fas*(pi/180)+Bfas(k+1));
plot(n(1:end-1),s2(2:end),'--k')%s2(2:end) kan behövas skjusteras om fördröjd i förhållandet till y(1:end-1)
hold off
 

