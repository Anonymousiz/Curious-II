function Trial_vector = mutationOper(Parents,F,subnum)
%Parents��������Ⱥ�������и���
%F ������
%subnum ����Ⱥ����
    for i =1:3 %��Ϊֻ��ѡ3���������
        randSnum(i) = randperm(subnum,1); %ȡ������һ������Ⱥ
        popnum = size(Parents{randSnum(i)},2); %�������Ⱥ�ĸ�����
        randPnum(i) =  randperm(popnum,1); %ȡ������һ������
        tempsub = Parents{randSnum(i)}; %��ȡ����Ⱥ
        Parent(i,:) = tempsub(randPnum(i)).dec; %��ȡ���弯��
    end    
    Trial_vector = Parent(1,:) + F*(Parent(2,:)-Parent(3,:));        
end