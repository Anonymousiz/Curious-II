function Trial_vector = CrossOper(D,Trial_vector,parent_vector,CR)
% D�������߿ռ�ά��/�������
% Trial_vector�������Ը���Ļ�������
% parent_vector������������
% CR ������
    rndi = randperm(D,1); %�������һ��������룬ʹ������һ���������
    parent_vector = parent_vector.dec;
    Site = rand(1,D) > CR;
    Site(rndi) = 0;
    Trial_vector(Site) = parent_vector(Site);
end