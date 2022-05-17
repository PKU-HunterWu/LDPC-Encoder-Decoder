function [ H, Hp, Hs ] = HxMatrixGen( )
%HxMatrixGen 根据要求生成完整的H、Hp、Hs矩阵
%   需使用.mat数据文件并置于本目录下，返回H、Hp、Hs矩阵

% 向量或矩阵的索引值从1开始
% 矩阵可以进行子矩阵赋值：H(1:56, 57:112) = Hij_Matrix;
%% Pre Definition
n = 2016; % 编码序列总比特数 or H矩阵列数
k = 1008; % 信息序列比特数 or H矩阵行数
r = k/n; % 编码速率
z = 56; % Hij_Matrix方阵大小

%% Coding Algorithm 2
% Generate H, Hp, Hs
H = zeros(k, n);
Hij_Matrix = zeros(z, z);
H_Block_Obj = load(['./Matrix(2016,1008)Block56.mat']); % 读取.mat文件，返回值为struct
H_Block = H_Block_Obj.H_block;
[mb, nb] = size(H_Block);
kb = nb - mb;

% Generate H
for i = 1:1:mb
    for j = 1:1:nb
       idx = H_Block(i, j);
       Hij_Matrix = zeros(z, z);
       if(idx == 0)
           continue;
       end
       Hij_Matrix(1, idx) = 1;
       %if(idx == 56 && j <= kb)
       %    Hij_Matrix(1, idx) = 0;
       %end
       
       for k = 2:1:z
           idx = idx + 1;
           if(idx > z)
               idx = 1;
           end
           Hij_Matrix(k, idx) = 1;
       end
       H((i-1)*z+1:i*z, (j-1)*z+1:j*z) = Hij_Matrix;
    end
end

H(1, 1008) = 0;
% Generate Hp, Hs
Hp = H(1:mb*z, 1:mb*z);
Hs = H(1:mb*z, mb*z+1:nb*z);

end

