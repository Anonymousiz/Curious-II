function [Archive,novelty_threshold,Parents] = SMONA0118(Parents,D,Archive,novelty_threshold,~,Parameter)
%------------------------------- Reference --------------------------------
%  Vargas D V, Murata J, Takano H, et al. General subpopulation framework 
%  and taming the conflict inside populations[J]. Evolutionary computation, 
%  2015, 23(1): 1-36.
%------------------------------- Copyright --------------------------------
% Copyright (c) 2018-2019 BIMK Group. You are free to use the PlatEMO for
% research purposes. All publications which use this platform or any code
% in the platform should acknowledge the use of "PlatEMO" and reference "Ye
% Tian, Ran Cheng, Xingyi Zhang, and Yaochu Jin, PlatEMO: A MATLAB platform
% for evolutionary multi-objective optimization [educational forum], IEEE
% Computational Intelligence Magazine, 2017, 12(4): 73-87".
%--------------------------------------------------------------------------

    %% Parameter setting
    if nargin > 5
        [CR,F] = deal(Parameter{:});
    elseif nargin == 4
        novelty_threshold = [];
        [CR,F] = deal(0.6,0.1); %1029-0.2,0.1/0.5,0.1 good /0.9,0.1
    else
        [CR,F] = deal(0.6,0.1); %1029-0.2,0.1/0.5,0.1 good /0.9,0.1
    end
    subnum = size(Parents,1); %3������Ⱥ
    Parent_set = Parents{subnum-1}; %ȡ�������ڶ�����Ⱥ
    Parentnum = size(Parent_set,2); %�������Ⱥ�ĸ�����//=4,j����
    if isa(Parent_set(1),'INDIVIDUAL')%ȡ����indx����Ⱥ�ĵ�һ��Ԫ�أ��ж��ǲ��Ǹ���
        calObj  = true;
    else
        calObj = false;
    end
    Global = GLOBAL.GetObj();
    %% Differental evolution 
    for j =1:Parentnum
        %Mutation �������
        Trial_vector = mutationOper(Parents,F,subnum); %�����offspring������ʦ��trial vector
        %����
        Lower = repmat(Global.lower,1,1);
        Upper = repmat(Global.upper,1,1);
        Trial_vector  = min(max(Trial_vector,Lower),Upper); 
        
        %Crossover �������
        parent_vector = Parent_set(j);
        Trial_vector = CrossOper(D,Trial_vector,parent_vector,CR);
        
        %individual ����ת��
        if calObj
        Trial_vector = INDIVIDUAL(Trial_vector);
        end
        
        %select
        k = 5;%1029-10%1114-5
        na = 40;% ��������-100����������-50
        
        %0608�޸�
        flag = 0;
        for i = 1:Global.M
            if parent_vector.obj(i)>Trial_vector.obj(i)
                flag = 1;
            end
        end
        if flag == 1 
        if Parentnum < k
            distvect(j) = disKNN4(parent_vector.obj,Parent_set,Parentnum); %���㵽���Ŀ�����С����
            trial_threshold = disKNN4(Trial_vector.obj,Parent_set,Parentnum);%������k��ֻ����popnum=4
        else
            distvect(j) = disKNN4(parent_vector.obj,Parent_set,k); %���㵽���Ŀ�����С����
            trial_threshold = disKNN4(Trial_vector.obj,Parent_set,k);%������k��ֻ����popnum=4
        end

        
        if trial_threshold > distvect(j)
            Parent_set(j) = Trial_vector;
            %�Ƿ�������ĵ�����������
            [new_vector,novelty_threshold] = addArchive(Archive{3},Trial_vector,novelty_threshold,k,[]);
            Archive{1} = [Archive{1},new_vector];
            Archive{3} = [Archive{3},new_vector];
        end
        end
        %ѭ�������
        Parents{subnum-1} = Parent_set;
    end
end

function dist = disKNN4(Trial_obj,Archive,k)
    Archiveobjs = Archive.objs;
    sum2 = sum((Trial_obj-Archiveobjs).^2,2);
    nearest_neighbors_distance = sqrt(sum2);

    %sorting nearest neighbors
	Rankneighbor= sort(nearest_neighbors_distance);
    
    %k����С���루ƽ����
    dist = sum(Rankneighbor(1:k))/k; %�ۼ�,����ط�������Ҫע��              
end

