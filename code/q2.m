% ����
cnc_pos = [1 1 2 2 3 3 4 4]; % ÿ��CNC��Ӧ�Ĺ��λ��
tmove = [20 33 46]; % RGV�ƶ�ʱ��*
tprocess1 = 400; % CNC�ӹ���1��������ʱ*
tprocess2 = 378; % CNC�ӹ���2��������ʱ*
tud = repmat([28 31],1,4); % ��CNC����������ʱ��*
tclean = 25; % ��ϴʱ��*
TARGET = 300; % Ŀ��ӹ�����

order1 = [1 5 8 3]; % ����1��CNC����

% ����
queue1 = []; % ����1�ȴ�ָ�����
queue2 = []; % ����2�ȴ�ָ�����
current_pos = 1; % RGVС����λ�� 1/2/3/4
cnc_now = [0 0 0 0 0 0 0 0]; % CNC��ǰ�ӹ������Ϻţ���ʼ��0
cnc_endtime = [0 0 0 0 0 0 0 0]; % CNC��ǰ�ӹ����ϵĽ���ʱ�䣬��ʼ��0
cnc_assign = [2 2 2 2 2 2 2 2]; % CNC����Ĺ���
cnt = 0; % ��ǰ�ӹ�����
cnt_finish = 0; % ��ȫ�ӹ�������
time = 0; % ��ǰ����ʱ��
% ��������󣨶�Ӧexcle����
result = zeros(TARGET,7);  % 1���Ϻ�/2����1CNC��/3���Ͽ�ʼ/4���Ͽ�ʼ/5����2CNC��/6���Ͽ�ʼ/7���Ͽ�ʼ

% ���ݹ���1�ĳ�ʼ˳�� ����cnc_assign
for i = 1:length(order1)
    cnc_assign(order1(i)) = 1;
end

% ��˳���ÿ̨������1��CNC����
for i = 1:length(order1)
    pos = cnc_pos(order1(i)); % ��ȡĿ���λ��
    % ���ƶ���+ ����
    if pos == current_pos % �����ƶ���ֱ������
        result(i,1) = i;
        result(i,2) = order1(i);
        result(i,3) = time; % ��¼���Ͽ�ʼ��ʱ��
        time = time + tud(order1(i)); % ����ʱ������
        cnc_endtime(order1(i)) = time + tprocess1; % ��¼��cnc�����ӹ���ʱ��
        cnc_now(order1(i)) = i; % ��¼��cnc��ǰ�ӹ������Ϻ�
    
    else
        distance = abs(pos - current_pos);
        time = time + tmove(distance); % �ƶ�ʱ������
        result(i,1) = i;
        result(i,2) = order1(i);
        result(i,3) = time;
        time = time + tud(order1(i)); 
        cnc_endtime(order1(i)) = time + tprocess1;
        cnc_now(order1(i)) = i;
    end
    current_pos = pos; % ���µ�ǰλ��
end

cnt = length(order1);
flag = 1; % RGV��һ��ִ�еĹ���1��2���棩
hold = 1; % RGV���ְ��Ʒ����ţ�ֻ����˹���һ��

while cnt_finish < TARGET
    if time <  min(cnc_endtime(cnc_assign==flag))
        time = min(cnc_endtime(cnc_assign==flag)); % �������CNC�����ڼӹ�״̬,ʱ�䡰�����
        continue;
    else
        [queue1, queue2] = checkStatus2(time,cnc_endtime,cnc_assign); % ���������ȴ�����
        if flag == 1 % ����һ��ִ�еĹ���Ϊ1
            assert(isempty(queue1)==0, '����1Ϊ�գ�')
            % ����������ȷ���ԭ�� ǰ��Ŀ��ִ�������ϲ���
            [idx, dis] = getClosest( current_pos, queue1 ); % ����RGV���¸�CNC���������Ŀ��idx ������
            if dis > 0
                time = time + tmove(dis); % �����Ҫ�ƶ��������ƶ���ʱ��
                current_pos = cnc_pos(idx); % �ƶ�
            end
            % ��ʼ ��/���ϲ���
            temp = cnc_now(idx); % ��ȡ�������
            result(temp,4) = time; % ��¼����1���Ͽ�ʼʱ��
            cnt = cnt + 1; % ȡһ���µ�����
            result(cnt,1) = cnt;
            result(cnt,2) = idx;
            result(cnt,3) = time;
            time = time + tud(idx); % �����ϲ���ʱ������
            cnc_now(idx) = cnt; %���¼ӹ��������
            cnc_endtime(idx) = time + tprocess1; % ���¼ӹ����ʱ��
            hold = temp; % ��¼���Ʒ�����
            flag = 2; % ������һ��ִ�й���Ϊ2
            
        else % ����һ��ִ�еĹ���Ϊ2
            assert(isempty(queue2)==0, '����2Ϊ�գ�')
            % ����������ȷ���ԭ�� ǰ��Ŀ��ִ�������ϲ���
            [idx, dis] = getClosest( current_pos, queue2 ); % ����RGV���¸�CNC���������Ŀ��idx ������
            if dis > 0
                time = time + tmove(dis); % �����Ҫ�ƶ��������ƶ���ʱ��
                current_pos = cnc_pos(idx); % �ƶ�
            end
            % �ƶ���ϣ���ʼ��/����
            if cnc_now(idx) > 0 % ̨�����ж���������һ���Ժ�������
                temp = cnc_now(idx); % ��ȡ�������
                result(temp,7) = time; % ��¼����2���Ͽ�ʼʱ��
                sp = 1; % ���̨�����ж���
            else
                sp = 0;
            end
            result(hold,5) = idx;
            result(hold,6) = time;
            time = time + tud(idx); % �����ϲ���ʱ������
            cnc_now(idx) = hold; %���¼ӹ��������
            cnc_endtime(idx) = time + tprocess2; % ���¼ӹ����ʱ��
            if sp == 1 % ̨�����ж���������һ���Ժ�������
                time = time + tclean; % ��ϴʱ������
                cnt_finish = cnt_finish + 1;
            end
            flag = 1; % ������һ��ִ�й���Ϊ2
        end
        
    end
end