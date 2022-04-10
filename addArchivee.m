function [new_vector,novelty_threshold] = addArchivee(Archive,Trial_vector,novelty_threshold,k,subnum,obj,nnstruct)
    na = 40; %����=1��code = 4 �о����������Ϊ�˳���
    %����obj���ǵ�Ŀ������Ⱥ
    if isempty(obj)==0 
    %ǰ�漸�����ٵ�
        if size(Archive,2)<k
            new_vector = Trial_vector;        
        elseif novelty_threshold <0.0001
            novelty_threshold = disKNNmin(Trial_vector,Archive,subnum,k,obj,nnstruct);
            new_vector = Trial_vector;                       
        else %��Archive�и���϶���
            trial_threshold = disKNNmin(Trial_vector,Archive,subnum,k,obj,nnstruct);
            if novelty_threshold < trial_threshold
                if size(Archive,2) > na
                    novelty_threshold = novelty_threshold*1.01;%1.1
                end
                new_vector = Trial_vector;                  
            else
                novelty_threshold = novelty_threshold*0.99;   %0.9999
                new_vector = [];
            end
        end        
    %��obj=[]����MONA����Ⱥ    
    else 
        if size(Archive,2)< k
            new_vector = Trial_vector;        
        elseif novelty_threshold <0.0001
            novelty_threshold = disKNNmin(Trial_vector,Archive,subnum,k,obj,nnstruct);
            new_vector = Trial_vector;  
        else %��Archive�и���϶���
            trial_threshold = disKNNmin(Trial_vector,Archive,subnum,k,obj,nnstruct);
            if novelty_threshold < trial_threshold
                if size(Archive,2) > na
                    novelty_threshold = novelty_threshold*1.1;
                end
                new_vector = Trial_vector;                          
            else
                novelty_threshold = novelty_threshold*0.99;    %0.999
                new_vector = [];
            end
        end        
 
        %{
        n_rejectcounter = n_rejectcounter+1;
        if n_rejectcounter > nrj
            novelty_threshold = novelty_threshold*0.999;
            n_rejectcounter = n_rejectcounter/2;
        end
        %}
                
        
    end
end
    
% 1029
function dist = disKNNmin(Trial_vector,Archive,subnum,k,obj,nnstruct)
% ȡ��С��k������ľ���
    triOut = RBF_predictor(nnstruct.W,nnstruct.B,nnstruct.Centers,nnstruct.Spreads,Trial_vector.decs);
    triError = abs(Trial_vector.objs - triOut) ;
    if isempty(obj)==0  %��obj���ǵ�Ŀ������Ⱥ
        for j =1:size(Archive,2)%����Archive�еĸ���
            nearest_neighbors_distance(j)= 0;
            % error dist
            Parent_set = Archive(j);
            OldOut = RBF_predictor(nnstruct.W,nnstruct.B,nnstruct.Centers,nnstruct.Spreads,Parent_set.decs);
            OldError = abs(Parent_set.objs - OldOut) ;
            
            sum1 = (triError(obj)-OldError(obj))^2;
            nearest_neighbors_distance(j)=sqrt(sum1);
        end
    else
        for j =1:size(Archive,2)%����Archive�еĸ���
            nearest_neighbors_distance(j)= 0;
            sum2 = 0;
            % error dist
            Parent_set = Archive(j);
            OldOut = RBF_predictor(nnstruct.W,nnstruct.B,nnstruct.Centers,nnstruct.Spreads,Parent_set.decs);
            OldError = abs(Parent_set.objs - OldOut) ;
            
            for m =1:subnum-2 %����Ŀ��2/n
                sum2 = sum2 + (triError(m)-OldError(m))^2;
            end
            nearest_neighbors_distance(j)=sqrt(sum2);
        end
    end    
    
    %sorting nearest neighbors
	Rankneighbor= sort(nearest_neighbors_distance);
    
    %k����С����(ƽ����
    dist = sum(Rankneighbor(1:k))/k; %�ۼ�,����ط�������Ҫע��      
end

%1108����
function dist = disKNNMD(Trial_obj,Archive,k,obj)%���Ͼ���
% ȡ��С��k������ľ���
    if nargin > 4 %��obj���ǵ�Ŀ������Ⱥ
        data  = [Trial_obj;Archive.objs];
        dataobj  = data(:,obj);
        D1 = pdist(dataobj,'hamming');
        Z1 = squareform(D1);
        nearest_neighbors_distance = Z1(1,2:end);
        
    else%MONA����Ⱥ
        data  = [Trial_obj;Archive.objs];
        D1 = pdist(data,'hamming');
        Z1 = squareform(D1);
        nearest_neighbors_distance = Z1(1,2:end);
    end    
    
    %sorting nearest neighbors
	Rankneighbor= sort(nearest_neighbors_distance);
    
    %k����С����(ƽ����
    dist = sum(Rankneighbor(1:k))/k; %�ۼ�,����ط�������Ҫע��      
end