T0 = 2;  % Period of the triangular wave
t = 0:0.0001:4*T0;    % Time vector
x = 2*abs(t-T0*floor(t/T0+0.5))/T0; % Isosceles triangular waveform
N = 150;
%Syntes for-loopen med plott för varje tillagd komponent ak
%fyrkantsvågen har 0 i jämna k komponenter.
xN=1/2; %start på signalen xN(t) med första koefficienten a0
for k=1:N
    %formeln för ak tagen från Exempel C-1 i boken
    %skriven på formeln enligt exercise C.3 (reell signal)
    ak = -4/((pi^2)*((2*k-1)^2));
    xN=xN+(ak*cos((2*pi/T0)*(2*k-1)*t)); %addition av ak
    
    %plottning av den syntetiserad signal över den ursprungliga signalen
    plot(t,x)
    hold on
    plot(t,xN)
    xlabel('Time (s)')
    ylabel('Amplitude')
    title(num2str(k))
    axis([-0.2 8.2 -0.1 1.2])
    hold off
    %pausa med 0.25s
    pause(0.01)
end