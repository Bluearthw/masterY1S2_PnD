function plain = fec_decode(encoded)

% TODO: Implement this yourself!

K = 7;
rate = 1/2;
%Generate Trellis diagram
trellis = poly2trellis(K, [171 133]); 

%Viterbi Algorithem to decode convolution codes
 plain = vitdec(encoded, trellis, 5*K, 'trunc', 'hard');
end

