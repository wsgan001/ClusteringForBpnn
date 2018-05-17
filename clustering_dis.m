function [ mdl ] = clustering_dis( data )
% mdl.data: �����ѵ������
% mdl.label: �����ѵ�������ķ���
% mdl.classNum: ������γɵ��������

    mdl.data = data;
    num = size(data, 1);
    label = zeros(1, num);
    pre_index = zeros(1, num); % �����ǩ�����ݵĶ�Ӧ��ϵ,����������Ϊ�ڼ�����ѡ��
    dis = zeros(1, num);
    p_label = 1:num; % data��־����
    [avg,std]=classStatus(data);
    threshold = avg-std; % ������ƽ������
%     fprintf('threshold: %s ',threshold);
    %% �ҳ�����������С��������
    D = pdist2(data, data);
    D(D == 0) = Inf;
    [d, i] = min(D);
    [~, index] = min(d);
    index = i(index);
    % ���������е�����һ�����뵽 finded ������
    finded = data(index, :);
    data(index, :) = []; % ��data����ȥ��������
    pre_index(index) = 1; % ����������Ϊ�ڼ���ѡ��
    p_label(index) = []; % ��������Ĩ��

    class_label=zeros(1, num);% ��ʾ�ڼ�����������һ��
    class_label(index)=1;
    %% ����, �� ��ǰ�� �еĵ���ʣ������ƽ�����룬�ҳ���С���룬�������Ҳ���뵽 ���� �㼯��
    minMat=[];
    classFlag=1;
    dis(1)=0;
    label(1)=1;
    for i=2:num
        min_d = Inf;
        min_avg = Inf;
        for j=1:size(data, 1)% Ѱ�������������м��ĵ�
            cursor = find(class_label==classFlag);
            [d,avg] = distanceChange(data(j, :), mdl.data(cursor,:));% ע��d��avg���ܴ��ڵ�����
            if d < min_d
                min_d = d;
                min_i = j;
                min_avg = avg;
            end
        end
        dis(i) = min_avg;
        minMat=[minMat min_avg];
        if dis(i) <= threshold
            class_label(p_label(min_i))=classFlag;
            label(i)=label(i-1);
        else
            classFlag=classFlag+1;
            class_label(p_label(min_i))=classFlag;
            label(i)=classFlag;
        end
        finded = [finded; data(min_i, :)];
        data(min_i, :) = [];
        pre_index(p_label(min_i)) = i;
        p_label(min_i) = [];
    end
    %%
%     figure;
%     plot(minMat);
%     title('���������ƽ�������������');
%     hold on;
%     plot([0, num + 1], [threshold, threshold]);
%     xlim([0, num + 1]);
%     for i=1:num
%         text(i, dis(i), num2str(find(pre_index==i)));
%     end
    %% 
    classNum=max(class_label);
%     figure;
%     title('δ���кϲ�������ǰ�����������ƽ������������������');
%     plot(dis);
%     hold on;
%     plot([0, num + 1], [threshold, threshold]);
%     xlim([0, num + 1]);
%     % plot label
%     for i=1:num
%         text(i, dis(i), num2str(label(i)));
%     end
    data = finded;
    %% �ϲ�������
    for i=1:classNum
        index = find(label == i);
        if size(index, 2) == 0
            continue
        end
        
        data1 = data(index, :); % ���ڸ�������
        min_d = Inf;
        min_j = 0;
        for j=1:classNum
            if i == j
                continue
            end
            index = find(label == j); % ��һ�����
            if size(index, 2) < size(data1, 1) % ���Ǹ����࣬���������
                continue
            end
            data2 = data(index, :); % ���������
            d1 = mean(pdist(data2)); % �����ƽ������
            d2 = mean(pdist([data1; data2]));  % ����һ���ƽ������
            if d2 / d1 < min_d
                min_d = d2 / d1;
                min_j = j;
            end
        end
%         fprintf('%d %d %.4f %d\n', i, min_j, min_d, sum(label == i));
        if min_d < 1.05 || size(data1,1)<=3
            label(label == i) = min_j;
        end
    end
    
    %% �ָ����ںϲ��ർ�µ� label ������
    maxClassNum = max(label);
    classNum = 0;
    for i=1:maxClassNum
        index = find(label == i);
        if size(index, 2) > 0
            classNum = classNum + 1;
            label(index) = classNum;
        end
    end

    %% ��ͼ���·����׼ȷ��
%     dis(1) = dis(2);
%     figure;
%     plot(dis);
%     hold on;
%     plot([0, num + 1], [threshold, threshold]);
%     xlim([0, num + 1]);
%     % plot label
%     for i=1:num
%         text(i, dis(i), num2str(label(i)));
%     end
    
    %% �ָ���ǩ�� data �Ķ�Ӧ��ϵ
    label = label(pre_index);
    %% �鿴����Ч��
%     figure;
%     scatter(1:num,label,'k'); hold on;
%     plot([num/2+0.5 num/2+0.5],[0,classNum+1],'r--');
%     ylim([0,classNum+1]);
    
    mdl.label = label;
    mdl.classNum = classNum;
end