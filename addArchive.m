function [new_vector,novelty_threshold] = addArchive(Archive,Trial_vector,novelty_threshold,k,obj)
    na = 40; %����=1��code = 4 �о����������Ϊ�˳���
    %����obj���ǵ�Ŀ������Ⱥ
    if isempty(obj)==0 
    %ǰ�漸�����ٵ�
        if size(Archive,2)<k
            new_vector = Trial_vector;        
        elseif novelty_threshold <0.0001
            novelty_threshold = disKNNmin(Trial_vector.obj,Archive,k,obj);
            new_vector = Trial_vector;                       
        else %��Archive�и���϶���
            trial_threshold = disKNNmin(Trial_vector.obj,Archive,k,obj);
            if novelty_threshold < trial_threshold
                if size(Archive,2) > na
                    novelty_threshold = novelty_threshold*1.1;%1.1��������dist��ʱ��1.01ʹ���ܼ�
                end
                new_vector = Trial_vector;                
            else
                novelty_threshold = novelty_threshold*0.999;  %0.999
                new_vector = [];  
            end
        end
    %��obj=[]����MONA����Ⱥ    
    else 
        if size(Archive,2)< k
            new_vector = Trial_vector;          
        elseif novelty_threshold <0.0001
            novelty_threshold = disKNNmin(Trial_vector.obj,Archive,k,obj);
            new_vector = Trial_vector;   
        else %��Archive�и���϶���
            trial_threshold = disKNNmin(Trial_vector.obj,Archive,k,obj);
            if novelty_threshold < trial_threshold
                if size(Archive,2) > na
                    novelty_threshold = novelty_threshold*1.1;
                end
                new_vector = Trial_vector;                        
            else
                novelty_threshold = novelty_threshold*0.999;     %0.999
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
function dist = disKNNmin(Trial_obj,Archive,k,obj)
% ȡ��С��k������ľ���
    if isempty(obj)==0 %��obj���ǵ�Ŀ������Ⱥ
        Archiveobjs = Archive.objs;
        sum1 = (Trial_obj(obj)-Archiveobjs(:,obj)).^2;
        nearest_neighbors_distance = sqrt(sum1);
    else
        Archiveobjs = Archive.objs;
        sum2 = sum((Trial_obj-Archiveobjs).^2,2);
        nearest_neighbors_distance = sqrt(sum2);
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