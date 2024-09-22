T0 = 1;   % Period of the sinusoid
F0 = 1/T0; % Fundamental frequency
dt = 0.0001;
t = 0:dt:4*T0;   % Time vector
x = sin(2*pi*F0*t); % Sinusoidal waveform
N = 200;
% Half-wave rectification
x = x.*(x > 0);
xN=(1/pi)+(1/2 * sin(2*pi*F0*t));
for l=1:N
    %formeln för ak tagen från Exempel C-1 i boken
    %skriven på formeln enligt exercise C.3 (reell signal)
    ak = 2/(pi*(1-(2*l)^2));
    xN=xN+(ak*cos((2*pi*F0)*(2*l)*t)); %addition av ak
    
    %plottning av den syntetiserad signal över den ursprungliga signalen
    plot(t,x)
    hold on
    plot(t,xN)
    xlabel('Time (s)')
    ylabel('Amplitude')
    title(num2str(l))
    axis([-0.2 4.2 -0.1 1.2])
    hold off
    %pausa med 0.25s
    pause(1)
end 