function [ v ] = LDPCDecoder_SP( H, LLR_y, iterMax )
%LDPCDecoder_SP LDPCʹ�úͻ��㷨����
%   HΪУ��������Խ����о���LLR_yΪ���յ����źų�ʼ���Ŷȣ�iterMaxΪ����������������vΪ��������Ϣ���й���ֵ

%��ʼ�� u �� v ����
U0i = LLR_y;
Uji = zeros(size(H));
Vij = zeros(size(H'));
[VerificationNodes, VariableNodes] = size(H);
x = zeros(size(LLR_y));

for iter = 1:1:iterMax
   %disp(['the ' num2str(iter) '-th iteration of SP'])
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
            multipleVal = 2*atanh(prod(tanh(Vij(idx, j)/2))/tanh(Vij(idx(k), j)/2));
            
            if multipleVal == inf || multipleVal == -inf
                if multipleVal == inf
                    Uji(j, idx(k)) = 10;
                    disp(['>> Uji is inf when j = ' num2str(j) ', i = ' num2str(idx(k))]);
                else
                    Uji(j, idx(k)) = -10;
                    disp(['>> Uji is -inf when j = ' num2str(j) ', i = ' num2str(idx(k))]);
                end
%                 prodOfSign = prod( sign(Vij(idx, j)) ) / sign(Vij(idx(k), j));
%                 if k == 1
%                     minOfVal = min(abs(Vij(idx(2:end), j)));
%                 elseif k == length(idx)
%                     minOfVal = min(abs(Vij(idx(1:k-1), j)));
%                 else
%                     minOfVal = min(min( abs(Vij(idx(1:k-1), j)) ), min( abs(Vij(idx(k+1:end), j)) ) );
%                 end
%                 Uji(j, idx(k)) = prodOfSign * minOfVal;
%                 
            else
                Uji(j, idx(k)) = multipleVal;
            end
            
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