clear all
close all
clc

%% Ԥ�������
N = 2016;
K = 1008;
R = K/N;

%% ��ӹ���·��
addpath('Encoder')
addpath('Decoder')

%% H��������
[ H, Hp, Hs ] = HxMatrixGen();

%% ����
Eb_N0_dB = 1.5;
alpha = 0:0.1:1;

BER = zeros(1, length(alpha));
for alpha_i = 1:1:length(alpha)
    disp(['alpha = ' num2str(alpha(alpha_i)) ' is simulating...']);
    
    % �趨ֹͣ����
    if Eb_N0_dB <= 1
        maxErrorBlocks = 50;
    else
        maxErrorBlocks = 3;
    end
    
    % �趨�����㷨����������
    iterMax = 30;
    
    %�趨ÿ���������������֡����
    maxBlocks = 10^6;
    
    % �����㷨����������ErrorBits �� ����֡��ErrorBlocks �� ����֡����ѭ����blocks ��ÿ��Eb/N0����ǰ����
    ErrorBits_NMS = 0; 
    ErrorBlocks_NMS = 0;
    blocks_NMS = 0;
    
    for i = 1:1:maxBlocks
        % �㷨2���루s --> x��
        s = randi([0, 1], 1, 1008);
        x = Encoder2(Hs, Hp, s);
        if sum(mod(H*(x'), 2)) > 0
            sprintf('> the '+ num2str(i) + ' th encoding is not right');
        end

        % BPSK����
        d = 1 - 2.*x;

        % AWGN
        SNR_dB = Eb_N0_dB + 10*log10(R) - 10*log10(1/2);
        SNR_linear = 10^(SNR_dB/10);
        sigma = sqrt(1/SNR_linear);
        y = d + sigma*randn(size(d)); % ������

        % ����˽���
        LLR_y = 2*y/(sigma^2);
        
        % NMS����
        v_NMS = LDPCDecoder_NMS( H, LLR_y, alpha(alpha_i), iterMax );
        %�����������֡��ͳ��
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

% ����BER
xlswrite('./BERforFindBestAlpha.xlsx', BER);
semilogy(alpha, BER, 'K-^', 'LineWidth', 1.0, 'MarkerSize', 5); % ����marker ����
xlabel('\alpha'); ylabel('BER')

