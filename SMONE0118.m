function [Archive,novelty_threshold,Parents] = SMONE0118(Parents,D,Archive,novelty_threshold,nnstruct,Parameter)
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
    Parent_set = Parents{subnum}; %ȡ�����һ������Ⱥ
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
        %����������_____________________________________________________________
        if Parentnum < k
            distvect(j) = disKNN4(parent_vector,Parent_set,subnum,Parentnum,nnstruct); %���㵽���Ŀ�����С����
            trial_threshold = disKNN4(Trial_vector,Parent_set,subnum,Parentnum,nnstruct);%������k��ֻ����popnum=4
        else
            distvect(j) = disKNN4(parent_vector,Parent_set,subnum,k,nnstruct); %���㵽���Ŀ�����С����
            trial_threshold = disKNN4(Trial_vector,Parent_set,subnum,k,nnstruct);%������k��ֻ����popnum=4
        end
        
        if trial_threshold > distvect(j)
            Parent_set(j) = Trial_vector;
            %�Ƿ�������ĵ�����������
            [new_vector,novelty_threshold] = addArchivee(Archive{3},Trial_vector,novelty_threshold,k,subnum,[],nnstruct);
            Archive{2} = [Archive{2},new_vector];
            Archive{3} = [Archive{3},new_vector];
        end
        end
        %ѭ�������
        Parents{subnum} = Parent_set;
    end
end

function dist = disKNN4(Trial_vector,Archive,subnum,k,nnstruct)
    triOut = RBF_predictor(nnstruct.W,nnstruct.B,nnstruct.Centers,nnstruct.Spreads,Trial_vector.decs);
    triError = abs(Trial_vector.objs - triOut) ;
    for j =1:size(Archive,2)%����Archive�еĸ���
        nearest_neighbors_distance(j)= 0;
        sum1 = 0;
        Parent_set = Archive(j);
        OldOut = RBF_predictor(nnstruct.W,nnstruct.B,nnstruct.Centers,nnstruct.Spreads,Parent_set.decs);
        OldError = abs(Parent_set.objs - OldOut) ;

        for m =1:subnum-2 %��������Ŀ��
            sum1 = sum1+(triError(m)-OldError(m))^2;
        end
        nearest_neighbors_distance(j)=sqrt(sum1);
    end
    
    %sorting nearest neighbors
	Rankneighbor= sort(nearest_neighbors_distance);
    
    %k����С���루ƽ����
    dist = sum(Rankneighbor(1:k))/k; %�ۼ�,����ط�������Ҫע��              
end

