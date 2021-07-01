clear all
close all
clc

%% 预定义变量
N = 2016;
K = 1008;
R = K/N;

%% 添加工作路径
addpath('Encoder')
addpath('Decoder')

%% H矩阵生成
[ H, Hp, Hs ] = HxMatrixGen();

%% 仿真
Eb_N0_dB = 1.5;
alpha = 0:0.1:1;

BER = zeros(1, length(alpha));
for alpha_i = 1:1:length(alpha)
    disp(['alpha = ' num2str(alpha(alpha_i)) ' is simulating...']);
    
    % 设定停止条件
    if Eb_N0_dB <= 1
        maxErrorBlocks = 50;
    else
        maxErrorBlocks = 3;
    end
    
    % 设定译码算法最大迭代次数
    iterMax = 30;
    
    %设定每个信噪比下最大仿真帧个数
    maxBlocks = 10^6;
    
    % 四种算法的总误码数ErrorBits 和 总误帧数ErrorBlocks 和 所有帧的总循环数blocks 在每个Eb/N0仿真前清零
    ErrorBits_NMS = 0; 
    ErrorBlocks_NMS = 0;
    blocks_NMS = 0;
    
    for i = 1:1:maxBlocks
        % 算法2编码（s --> x）
        s = randi([0, 1], 1, 1008);
        x = Encoder2(Hs, Hp, s);
        if sum(mod(H*(x'), 2)) > 0
            sprintf('> the '+ num2str(i) + ' th encoding is not right');
        end

        % BPSK调制
        d = 1 - 2.*x;

        % AWGN
        SNR_dB = Eb_N0_dB + 10*log10(R) - 10*log10(1/2);
        SNR_linear = 10^(SNR_dB/10);
        sigma = sqrt(1/SNR_linear);
        y = d + sigma*randn(size(d)); % 加噪声

        % 译码端接收
        LLR_y = 2*y/(sigma^2);
        
        % NMS译码
        v_NMS = LDPCDecoder_NMS( H, LLR_y, alpha(alpha_i), iterMax );
        %误比特数、误帧数统计
        errorbits_NMS = sum(s ~= v_NMS);
        ErrorBits_NMS = ErrorBits_NMS + errorbits_NMS;
        blocks_NMS = blocks_NMS + 1;
        
        if errorbits_NMS ~= 0
            ErrorBlocks_NMS = ErrorBlocks_NMS + 1;
        end
        if ErrorBlocks_NMS > maxErrorBlocks
            break;
        end
    end
    BER(1, alpha_i) = ErrorBits_NMS/(K * blocks_NMS);
end

% 绘制BER
xlswrite('./BERforFindBestAlpha.xlsx', BER);
semilogy(alpha, BER, 'K-^', 'LineWidth', 1.0, 'MarkerSize', 5); % 三角marker 黑线
xlabel('\alpha'); ylabel('BER')

