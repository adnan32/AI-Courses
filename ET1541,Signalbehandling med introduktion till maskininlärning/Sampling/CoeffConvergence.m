%Skriptet visar hur man estimerar ak parametrarna för en fyrkantsvåg
%med den Diskreta Fourier Serien, då vi bara har tillgång till en samplad
%periodisk signal f[n]
close all
clear all
clc

k=5; %välj koefficient ak
Nmax=60; %Maximal antal sampel under signalens ena period
ak=[]; %tom vektor för att spara olika estimat med 
for N=4:4:Nmax %for-loop för att öka antal sampel N
    f=[ones(1,N/4) zeros(1,N/2) ones(1,N/4)];%skapa den samplad fyrkantsvåg över en period 0 till 2*pi  
    akN=0;%nollställ parametern
    for n=0:N-1%for-loop för att skatta ak parameter
        %formeln tagen ur formelsamling s.12 i kap. 1.6.2
        %(ck är samma som ak i boken)
        akN=akN+f(n+1)*exp(-j*((2*pi)/N)*k*n); %itterativ summa för att estimera ak
    end
    ak(end+1)=akN/N;%spara estimatet (inte den mest effektivaste sättet)
end
plot(4:4:Nmax,(sin((pi*k)/2)/(pi*k))*ones(1,length(4:4:Nmax)),'r')%plotta den teoretiska värdet
hold on; %behåll förra plotten
plot(4:4:Nmax,ak); %plotta estimatet med de olika val av N
hold off
xlabel('N');
