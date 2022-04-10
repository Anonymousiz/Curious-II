function [Archive,novelty_threshold,Parents] = SDEE0611(Parents,obj,D,Archive,novelty_threshold,nnstruct,Parameter)
% Subpop�����滻
% Archive���Ż����¶�
% jDE����
    %% Parameter setting
    subnum = size(Parents,1); % num of subpop
    Parent_set = Parents{obj}; % select the 'obj' subpop
    parentnum = size(Parent_set,2); %�������Ⱥ�ĸ�����,������inii����
    t1 = 0.5; %jDE
    t2 = 0.5; %jDE
    FL = 0.1;%jDE
    FU = 0.3;%jDE
    if isa(Parent_set(1),'INDIVIDUAL')%ȡ����indx����Ⱥ�ĵ�һ��Ԫ�أ��ж��ǲ��Ǹ���
        calObj = true;
    else
        calObj = false;
    end
    Global = GLOBAL.GetObj();
    %% Differental evolution     
    for inii = 1:parentnum
        if nargin > 6
            [CR,F] = deal(Parameter{:});
        elseif nargin == 6 
            % ��̬����Ӧ
            % Ѱ�����Ÿ���
            %[fitnessbestX,indexbestX]=min(Parent_set.obj{obj});
            Xobjs = Parent_set.objs;
            [~,indexbestX]=min(Xobjs(:,obj));
            [CR,F] = deal(Parent_set(indexbestX).add{1},Parent_set(indexbestX).add{2});
        end
        %Mutation �������
        R1 = rand();
        R2 = rand();
        if R2 <= t1
            F =  FL + R1*FU;
        end
        Trial_vector = mutationOper(Parents,F,subnum); %�����offspring������ʦ��trial vector
        %����
        Lower = repmat(Global.lower,1,1);
        Upper = repmat(Global.upper,1,1);
        Trial_vector  = min(max(Trial_vector,Lower),Upper); 
        
        %Crossover �������
        R3 = rand();
        R4 = rand();
        if R4 <= t2
            CR = R3;
        end
        parent_vector = Parent_set(inii); %ȡ��index��Ⱥ�ĵ�j������
        Trial_vector = CrossOper(D,Trial_vector,parent_vector,CR);%�������͵ıȽϺ��滻
        
        %individual ����ת��
        if calObj
            addpro = {CR,F};
            Trial_vector = INDIVIDUAL(Trial_vector,addpro);
        end
    
        %Selection ѡ����� ����Ҫ�ģ�������Ŀ���ܲ��ܴﵽ��          
        parent_obj  = parent_vector.objs;
        Trial_obj  = Trial_vector.objs;
        
        k = 5;   %1029-10%1114-5
        na = 40;%��Ⱥ�����١�100����Ⱥ����ࡪ70
        
        %�����滻
        if Trial_obj(obj) < parent_obj(obj) 
            %����ȡ������Ⱥ���弯�������滻
            Parent_set(inii) = Trial_vector; 
            %�Ƿ�������ĵ�����������
            r1 = rand;
            if r1<0.5 %error
                [new_vector,novelty_threshold] = addArchivee(Archive{3},Trial_vector,novelty_threshold,k,subnum,obj,nnstruct);
                Archive{2} = [Archive{2},new_vector];
                Archive{3} = [Archive{3},new_vector];
            else %dist
                [new_vector,novelty_threshold] = addArchive(Archive{3},Trial_vector,novelty_threshold,k,obj);
                Archive{1} = [Archive{1},new_vector];
                Archive{3} = [Archive{3},new_vector];
            end
        end           
        
        %ѭ������� 
         Parents{obj} = Parent_set; %����ȡ������Ⱥ�滻��ԭ��������Ⱥ 

    end
end

%{
        %ǰa��ֻ�ȽϾ���Ŀ��Ĵ�С
        if size(Archive,2) < a
            if Trial_obj(obj) < parent_obj(obj)
                Parent_set(inii) = Trial_vector; %����ȡ������Ⱥ���弯�������滻
                Archive = [Archive,Trial_vector];%������ĵ�����������
            end
        %��a+1�����㴴�¶�
        elseif size(Archive,2) == a
            novelty_threshold = disKNN3(Trial_vector.obj,Archive,obj,k);
            %%%%%%���پͲ�Ҫ�����if
            %if Trial_obj(index) < parent_obj(index)
                Parent_set(inii) = Trial_vector; %����ȡ������Ⱥ���弯�������滻
                Archive = [Archive,Trial_vector];%������ĵ�����������
            %end
        %����a���������޳�
        else
            %���㴴�¶ȡ�������Ŀ���С
            if disKNN3(Trial_vector.obj,Archive,obj,k) > novelty_threshold
                if Trial_obj(obj) < parent_obj(obj)
                    Parent_set(inii) = Trial_vector; %����ȡ������Ⱥ���弯�������滻
                    Archive = [Archive,Trial_vector];%������ĵ�����������
                end
                novelty_threshold = novelty_threshold*1.1; % ������֪��Ҫ��Ҫ��
            %�����㴴�¶ȡ��������޳�
            else
                novelty_threshold = novelty_threshold*0.9999; % ������֪��Ҫ��Ҫ��
                for m = 1:size(Archive,2)
                    temp(m,:) = Archive(m).obj;
                end
                middle = mean(temp(:,obj));%1,2
                tempsic = (temp(:,obj)<middle);%1,2
                temprand = randperm(size(Archive,2),20);
                tempsic(temprand) = 1;
                Archive = Archive(tempsic);
                clear temp
                clear tempsic
                clear temprand                
            end
        end
%}
