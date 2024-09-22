%Skriptet demostrerar hur man plottar koefficienterna ak från
%Fourier Serier Analysen med hjälp av stem().
%I detta fall gäller koefficienterna för en fyrkantsvåg
%OBS! Bara origo och den högra sidan av spektrummet beräknas och plottas.
close all
clear all
clc

N=16; %Val av antal Koefficienter vi vill plotta
T0=4; %periodtiden för den periodiska signalen

ak=zeros(1,N);
for k=1:N
    ak(k)=-4/((pi^2)*((2*k-1)^2));%formeln för ak tagen från Exempel C-1 i boken
end
ak=[0.5 ak]; %lägg till a0

%Här plottas koefficienterna med tecknet bevarad
stem(0:N,ak)
xlabel('Coeff k');
ylabel('Amplitude');

%Här plottas absolutbellopet för koefficienterna
figure
stem(0:N,abs(ak))
xlabel('Coeff k');
ylabel('Magnitude');

%Här plottas absolutbellopet, samt omräknad k ordningen till frekvens
figure
stem((0:N)*(1/T0),abs(ak))
xlabel('Freq. [Hz]');
ylabel('Magnitude');

