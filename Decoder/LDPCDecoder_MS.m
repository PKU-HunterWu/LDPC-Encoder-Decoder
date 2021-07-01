function [ v ] = LDPCDecoder_MS( H, LLR_y, iterMax )
%LDPCDecoder_SP LDPCʹ�û����㷨����
%   HΪУ��������Խ����о���LLR_yΪ���յ����źų�ʼ���Ŷȣ�iterMaxΪ����������������vΪ��������Ϣ���й���ֵ

%��ʼ�� u �� v ����
U0i = LLR_y;
Uji = zeros(size(H));
Vij = zeros(size(H'));
[VerificationNodes, VariableNodes] = size(H);
x = zeros(size(LLR_y));

for iter = 1:1:iterMax
   %disp(['the ' num2str(iter) '-th iteration of MS'])
    % ���Vij����
    for i = 1:1:VariableNodes
        idx = find(H(:, i) == 1);
        for k = 1:1:length(idx)
             Vij(i, idx(k)) =  U0i(i) + sum(Uji(idx, i)) - Uji(idx(k), i);
        end
    end
    
    % ���Uji����
    for j = 1:1:VerificationNodes
        idx = find(H(j, :) == 1);
        for k = 1:1:length(idx)
            % �ų���Vij(idx(k), j)�������
            prodVal = 1.0;
            for t = 1:1:length(idx)
                if t ~= k
                    prodVal = prodVal * sign( Vij(idx(t), j) );
                end
            end
            % �ų���Vij(idx(k), j)����min
            if k == 1
                minOfVal = min(abs(Vij(idx(2:end), j)));
            elseif k == length(idx)
                minOfVal = min(abs(Vij(idx(1:k-1), j)));
            else
                minOfVal = min(min( abs(Vij(idx(1:k-1), j)) ), min( abs(Vij(idx(k+1:end), j)) ) );
            end
            % Uji(j, idx(k))��ֵ
            Uji(j, idx(k)) = prodVal * minOfVal;
            %Uji(j, idx(k)) = prodOfSign * minOfVal;
        end
    end
    
    %�о�
    for i = 1:1:length(x)
        idx = find(H(:, i) == 1);
        addVal = sum(Uji(idx, i)) + U0i(i);
        if(addVal < 0)
            x(i) = 1;
        else
            x(i) = 0;
        end
    end
    
    %���У���ϵ���� break;
    %�����������
    if mod(H*(x'), 2) == 0
        break;
    end
end

v = x(1009:end);
end

