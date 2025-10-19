function complex_envelope = gmsk_modulate(bits, bt, osr)

%{
  Function
    Modulate a binary bit into a GMSK signal

  Parameters
    bt : Gaussian filter bandwidth-time product. Determine how much
    smoothing is applied
    OSR: oversampling ratio, how many samples per bit are used\
   
  Process
    1.Convert bits to symbols (±1).
    2.Upsample the symbols.
    3.Apply a Gaussian filter to smooth transitions.
    4.Integrate the filtered signal to get the modulation phase.
    5.Generate the complex GMSK signal using exp(1j * phase)
%}

% convert bits to symbols (+1 / -1)
% If bits = [0 1 1 0], then symbols = [-1 1 1 -1].
symbols = bits * 2 - 1;

% apply gaussian filter
filt = gaussian_filter(bt, osr);

%upsample the symbols to match the oversampling rate
% If osr = 4, a symbol [1 -1] will become [1 1 1 1 -1 -1 -1 -1]
data_filtered = conv(repelem(symbols, osr, 1), filt, 'same');

% calculate phase
phase = [0; cumsum(data_filtered) * 0.5 * pi / osr];

% generate complex envelope
complex_envelope = exp(1j * phase);

end