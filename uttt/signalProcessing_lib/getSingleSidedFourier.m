%% Calculates the single sided Fourier transform of a signal
%  @param[in] s: The input signal (vector 1x N).
%  @param[in] Fs: The sampling frequency of the 's'.
%  @param[out] f: The frequncies where the fourier is calculated.
%  @param[out] P1: The amplitudes of the signal's single sided Fourier.
%
function [f, P1, Y] = getSingleSidedFourier(s, Fs)

    L = length(s);
    X = s;
    Y = fft(X);
    P2 = abs(Y/L);
    
    n = floor(L/2);
    P1 = 2*P2(1:n+1);
    P1(1) = P1(1)/2;
    f = Fs*(0:n)/L;
    
    P1 = P1/max(P1);

end