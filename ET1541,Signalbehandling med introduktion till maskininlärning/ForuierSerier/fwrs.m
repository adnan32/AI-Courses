N=100; %Antal koefficienter i syntesen 
T0=3.14; %Periodtiden för signalen
t=0:0.00001:3*T0; %tidsvektorn
x = sin(t);       % Sine wave
y = abs(x);       % Full-wave rectification

%Syntes for-loopen med plott för varje tillagd komponent ak
%fyrkantsvågen har 0 i jämna k komponenter.
xN=2/pi; %start på signalen xN(t) med första koefficienten a0
for k=1:N
    %formeln för ak tagen från Exempel C-1 i boken
    %skriven på formeln enligt exercise C.3 (reell signal)
    ak = 4 / (pi * (1 - 4 * k^2));
    xN=xN+(ak*cos(2*pi*k*t/T0)); %addition av ak
    
    %plottning av den syntetiserad signal över den ursprungliga signalen
    plot(t,y)
    hold on
    plot(t,xN)
    xlabel('Time (s)')
    ylabel('Amplitude')
    title(num2str(k))
    axis([-0.2 9.2 -0.1 1.2])
    hold off
    %pausa med 0.25s
    pause(1)
end

