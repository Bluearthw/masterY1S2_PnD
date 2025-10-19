filename = 'bit_sync.txt';
fid = fopen(filename, 'r');

% 初始化空数组
data = [];

while ~feof(fid)
    line = fgetl(fid);  % 逐行读取
    if strcmp(line, 'x')
        continue;        % 跳过未知值
    else
        bit = str2double(line);  % 将 '0' 或 '1' 转为数值
        if isnan(bit)
            warning('Invalid line: %s', line);
        else
            data(end+1, 1) = bit;  % 添加到列向量
        end
    end
end

fclose(fid);
message = varicode_decode(data);