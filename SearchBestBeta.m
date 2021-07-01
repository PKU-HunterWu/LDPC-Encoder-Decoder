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
Eb_N0_dB = 1.0;
beta = 0:0.1:1;

BER = zeros(1, length(beta));
for beta_i = 1:1:length(beta)
    
    disp(['beta = ' num2str(beta(beta_i)) ' is simulating...']);
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
    ErrorBits_OMS = 0; 
    ErrorBlocks_OMS = 0;
    blocks_OMS = 0;
    
    for i = 1:1:maxBlocks
        % �㷨2���루s --> x��
        % disp(['    the ' num2str(i) '-th frame of OMS decoding based on beta = ' num2str(beta(beta_i))]);
        
        s = randi([0, 1], 1, 1008);
        x = Encoder2(Hs, Hp, s);
        if sum(mod(H*(x'), 2)) > 0
            sprintf('the '+ num2str(i) + ' th encoding is not right');
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
        v_OMS = LDPCDecoder_OMS( H, LLR_y, beta(beta_i), iterMax );
        %�����������֡��ͳ��
        errorbits_OMS = sum(s ~= v_OMS);
        ErrorBits_OMS = ErrorBits_OMS + errorbits_OMS;
        blocks_OMS = blocks_OMS + 1;
        
        if errorbits_OMS ~= 0
            ErrorBlocks_OMS = ErrorBlocks_OMS + 1;
        end
        if ErrorBlocks_OMS > maxErrorBlocks
            break;
        end
    end
    BER(1, beta_i) = ErrorBits_OMS/(K * blocks_OMS);
end

% ����BER
xlswrite('./BERforFindBestBeta.xlsx', BER);
semilogy(beta, BER, 'K-^', 'LineWidth', 1.0, 'MarkerSize', 5); % ����marker ����
xlabel('\beta'); ylabel('BER');

