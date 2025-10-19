function error_ratio = compare_char_streams(stream1, stream2)
    % Function to compare two character streams and compute the error ratio
    % Inputs:
    %   - stream1: First character stream (string or char array)
    %   - stream2: Second character stream (string or char array)
    % Output:
    %   - error_ratio: Ratio of mismatched characters (percentage)
    
    % Convert to character arrays if they are strings
    if isstring(stream1)
        stream1 = char(stream1);
    end
    if isstring(stream2)
        stream2 = char(stream2);
    end
    
    % Ensure the streams have the same length
    min_len = min(length(stream1), length(stream2));
    
    % Trim the longer stream to match the shorter one
    stream1 = stream1(1:min_len);
    stream2 = stream2(1:min_len);
    
    % Count number of different characters
    num_errors = sum(stream1 ~= stream2);
    
    % Compute error ratio (percentage)
    error_ratio = (num_errors / min_len) * 100;
    
    % Display result
    fprintf('Character Error Ratio: %.2f%% (%d mismatches out of %d characters)\n', ...
            error_ratio, num_errors, min_len);
end
