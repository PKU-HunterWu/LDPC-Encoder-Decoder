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

%% 求四种算法随着Eb/N0变化得出的BER FER
alpha = 0.7; beta = 0.5;
Eb_N0_dB = -1:0.5:2;
BER = zeros(4, length(Eb_N0_dB));
FER = zeros(4, length(Eb_N0_dB));
recordStr = [' SP', ' MS', ' NMS', ' OMS'];

% 日志记录到 mydiary.txt
diary 'mylog.txt'
clock;

for Eb_N0_i = 1:1:length(Eb_N0_dB)
    disp(['Eb/N0=' num2str(Eb_N0_dB(Eb_N0_i)) 'dB is simulating...']);
    % 设定停止条件
    if Eb_N0_dB(Eb_N0_i) <= 1
        maxErrorBlocks = 50;
    else
        maxErrorBlocks = 3;
    end
    
    % 设定译码算法最大迭代次数
    iterMax = 30;
    
    %设定每个信噪比下最大仿真帧个数
    maxBlocks = 10^6;
    
    % 四种算法的总误码数ErrorBits 和 总误帧数ErrorBlocks 和 所有帧的总循环数blocks 在每个Eb/N0仿真前清零
    ErrorBits_SP = 0; ErrorBits_MS = 0;
    ErrorBits_NMS = 0; ErrorBits_OMS = 0;
    ErrorBlocks_SP = 0; ErrorBlocks_MS = 0;
    ErrorBlocks_NMS = 0; ErrorBlocks_OMS = 0;
    blocks_SP = 0;blocks_MS = 0;
    blocks_NMS = 0; blocks_OMS = 0;
    
    
    % 编码 - BPSK - AWGN
    for i = 1:1:maxBlocks
        
        recordStr = [];
        % 算法2编码（s --> x）
        s = randi([0, 1], 1, 1008);
        x = Encoder2(Hs, Hp, s);
        if sum(mod(H*(x'), 2)) > 0
            sprintf('the '+ num2str(i) + ' th encoding is not right');
            continue;
        end

        % BPSK调制
        d = 1 - 2.*x;

        % AWGN
        SNR_dB = Eb_N0_dB(Eb_N0_i) + 10*log10(R) - 10*log10(1/2);
        SNR_linear = 10^(SNR_dB/10);
        sigma = sqrt(1/SNR_linear);
        y = d + sigma*randn(size(d)); % 加噪声

        % 译码端接收
        LLR_y = 2*y/(sigma^2);

        %四种算法分别译码
        %四种算法在 某一Eb/N0下 某一帧传输中 的误比特数 errorbits
        %四种算法在某一Eb/N0下所有帧的总误比特数 ErrorBits
        %四种算法在某一Eb/N0下所有帧的总误帧数 ErrorBlocks
        %四种算法在某一Eb/N0下所有帧的总循环数 blocks
        if ErrorBlocks_SP <= maxErrorBlocks
            v_SP = LDPCDecoder_SP( H, LLR_y, iterMax );
            errorbits_SP = sum(s ~= v_SP);
            ErrorBits_SP = ErrorBits_SP + errorbits_SP;
            blocks_SP = blocks_SP + 1;
            if errorbits_SP ~= 0
                ErrorBlocks_SP = ErrorBlocks_SP + 1; 
            end
            recordStr = [recordStr ' SP'];
        end
        if ErrorBlocks_MS <= maxErrorBlocks
            v_MS = LDPCDecoder_MS( H, LLR_y, iterMax );
            errorbits_MS = sum(s ~= v_MS);
            ErrorBits_MS = ErrorBits_MS + errorbits_MS;
            blocks_MS = blocks_MS + 1;
            if errorbits_MS ~= 0
                ErrorBlocks_MS = ErrorBlocks_MS + 1;
            end
            recordStr = [recordStr ' MS'];
        end
        if ErrorBlocks_NMS <= maxErrorBlocks
            v_NMS = LDPCDecoder_NMS( H, LLR_y, alpha, iterMax );
            errorbits_NMS = sum(s ~= v_NMS);
            ErrorBits_NMS = ErrorBits_NMS + errorbits_NMS;
            blocks_NMS = blocks_NMS + 1;
            if errorbits_NMS ~= 0
                ErrorBlocks_NMS = ErrorBlocks_NMS + 1;
            end
            recordStr = [recordStr ' NMS'];
        end
        if ErrorBlocks_OMS <= maxErrorBlocks
            v_OMS = LDPCDecoder_OMS( H, LLR_y, beta, iterMax );
            errorbits_OMS = sum(s ~= v_OMS);
            ErrorBits_OMS = ErrorBits_OMS + errorbits_OMS;
            blocks_OMS= blocks_OMS + 1;
            if errorbits_OMS ~= 0
                ErrorBlocks_OMS = ErrorBlocks_OMS + 1;
            end
           recordStr = [recordStr ' OMS'];
        end
        
        disp(['    the ' num2str(i) '-th frame of encoding & decoding has finished based on Eb/N0 = ' num2str(Eb_N0_dB(Eb_N0_i)) ', ' recordStr ' is still running.']);
        
        if ErrorBlocks_SP > maxErrorBlocks && ErrorBlocks_MS > maxErrorBlocks && ErrorBlocks_NMS > maxErrorBlocks && ErrorBlocks_OMS > maxErrorBlocks
            break;
        end
    end
    
    BER(1, Eb_N0_i) = ErrorBits_SP/(K * blocks_SP);
    BER(2, Eb_N0_i) = ErrorBits_MS/(K * blocks_MS);
    BER(3, Eb_N0_i) = ErrorBits_NMS/(K * blocks_NMS);
    BER(4, Eb_N0_i) = ErrorBits_OMS/(K * blocks_OMS);

    FER(1, Eb_N0_i) = ErrorBlocks_SP/blocks_SP;
    FER(2, Eb_N0_i) = ErrorBlocks_MS/blocks_MS;
    FER(3, Eb_N0_i) = ErrorBlocks_NMS/blocks_NMS;
    FER(4, Eb_N0_i) = ErrorBlocks_OMS/blocks_OMS;
end

% 绘制 FER 和 BER
xlswrite('./BERofFourAlgorithm.xlsx', BER);
xlswrite('./FERofFourAlgorithm.xlsx', FER);

figure('numbertitle','off','name','BER of 4 Decode algorithms')
semilogy(Eb_N0_dB, BER(1, :), 'K-^', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % SP 三角marker 黑线
semilogy(Eb_N0_dB, BER(2, :), 'R-o', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % MS  圆形marker 红线
semilogy(Eb_N0_dB, BER(3, :), 'Y-s', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % NMS  正方marker 黄线
semilogy(Eb_N0_dB, BER(4, :), 'B-d', 'LineWidth', 1.0, 'MarkerSize', 6); % OMS  菱形marker 蓝线
xlabel('Eb/N0(dB)'); ylabel('BER');
legend('BER - SP', 'BER - MS', 'BER - NMS', 'BER - OMS')
grid on;

figure('numbertitle','off','name','FER of 4 Decode algorithms')
semilogy(Eb_N0_dB, FER(1, :), 'K--^', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % SP 三角marker 黑线
semilogy(Eb_N0_dB, FER(2, :), 'R--o', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % MS  圆形marker 红线
semilogy(Eb_N0_dB, FER(3, :), 'Y--s', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % NMS  正方marker 黄线
semilogy(Eb_N0_dB, FER(4, :), 'B--d', 'LineWidth', 1.0, 'MarkerSize', 6); % OMS  菱形marker 蓝线
xlabel('Eb/N0(dB)'); ylabel('FER');
legend('FER - SP', 'FER - MS', 'FER - NMS', 'FER - OMS')
grid on;

diary off