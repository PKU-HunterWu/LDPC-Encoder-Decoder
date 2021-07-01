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

%% �������㷨����Eb/N0�仯�ó���BER FER
alpha = 0.7; beta = 0.5;
Eb_N0_dB = -1:0.5:2;
BER = zeros(4, length(Eb_N0_dB));
FER = zeros(4, length(Eb_N0_dB));
recordStr = [' SP', ' MS', ' NMS', ' OMS'];

% ��־��¼�� mydiary.txt
diary 'mylog.txt'
clock;

for Eb_N0_i = 1:1:length(Eb_N0_dB)
    disp(['Eb/N0=' num2str(Eb_N0_dB(Eb_N0_i)) 'dB is simulating...']);
    % �趨ֹͣ����
    if Eb_N0_dB(Eb_N0_i) <= 1
        maxErrorBlocks = 50;
    else
        maxErrorBlocks = 3;
    end
    
    % �趨�����㷨����������
    iterMax = 30;
    
    %�趨ÿ���������������֡����
    maxBlocks = 10^6;
    
    % �����㷨����������ErrorBits �� ����֡��ErrorBlocks �� ����֡����ѭ����blocks ��ÿ��Eb/N0����ǰ����
    ErrorBits_SP = 0; ErrorBits_MS = 0;
    ErrorBits_NMS = 0; ErrorBits_OMS = 0;
    ErrorBlocks_SP = 0; ErrorBlocks_MS = 0;
    ErrorBlocks_NMS = 0; ErrorBlocks_OMS = 0;
    blocks_SP = 0;blocks_MS = 0;
    blocks_NMS = 0; blocks_OMS = 0;
    
    
    % ���� - BPSK - AWGN
    for i = 1:1:maxBlocks
        
        recordStr = [];
        % �㷨2���루s --> x��
        s = randi([0, 1], 1, 1008);
        x = Encoder2(Hs, Hp, s);
        if sum(mod(H*(x'), 2)) > 0
            sprintf('the '+ num2str(i) + ' th encoding is not right');
            continue;
        end

        % BPSK����
        d = 1 - 2.*x;

        % AWGN
        SNR_dB = Eb_N0_dB(Eb_N0_i) + 10*log10(R) - 10*log10(1/2);
        SNR_linear = 10^(SNR_dB/10);
        sigma = sqrt(1/SNR_linear);
        y = d + sigma*randn(size(d)); % ������

        % ����˽���
        LLR_y = 2*y/(sigma^2);

        %�����㷨�ֱ�����
        %�����㷨�� ĳһEb/N0�� ĳһ֡������ ��������� errorbits
        %�����㷨��ĳһEb/N0������֡����������� ErrorBits
        %�����㷨��ĳһEb/N0������֡������֡�� ErrorBlocks
        %�����㷨��ĳһEb/N0������֡����ѭ���� blocks
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

% ���� FER �� BER
xlswrite('./BERofFourAlgorithm.xlsx', BER);
xlswrite('./FERofFourAlgorithm.xlsx', FER);

figure('numbertitle','off','name','BER of 4 Decode algorithms')
semilogy(Eb_N0_dB, BER(1, :), 'K-^', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % SP ����marker ����
semilogy(Eb_N0_dB, BER(2, :), 'R-o', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % MS  Բ��marker ����
semilogy(Eb_N0_dB, BER(3, :), 'Y-s', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % NMS  ����marker ����
semilogy(Eb_N0_dB, BER(4, :), 'B-d', 'LineWidth', 1.0, 'MarkerSize', 6); % OMS  ����marker ����
xlabel('Eb/N0(dB)'); ylabel('BER');
legend('BER - SP', 'BER - MS', 'BER - NMS', 'BER - OMS')
grid on;

figure('numbertitle','off','name','FER of 4 Decode algorithms')
semilogy(Eb_N0_dB, FER(1, :), 'K--^', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % SP ����marker ����
semilogy(Eb_N0_dB, FER(2, :), 'R--o', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % MS  Բ��marker ����
semilogy(Eb_N0_dB, FER(3, :), 'Y--s', 'LineWidth', 1.0, 'MarkerSize', 6); hold on; % NMS  ����marker ����
semilogy(Eb_N0_dB, FER(4, :), 'B--d', 'LineWidth', 1.0, 'MarkerSize', 6); % OMS  ����marker ����
xlabel('Eb/N0(dB)'); ylabel('FER');
legend('FER - SP', 'FER - MS', 'FER - NMS', 'FER - OMS')
grid on;

diary off