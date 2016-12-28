clear;
load('COIL20.mat');
nClass = length(unique(gnd));%��nClassΪ20


%Normalize each data vector to have L2-norm equal to 1 
%����COIL20.mat�е�feaΪһ��1440*1024�ľ�������ÿһ��Ϊһ�����ݣ�ÿһ��Ϊһ��feature�����Ե������ǵĺ����е�X��fea��Ҫ��ת��
%���ڵ�һ�Σ�����beltaΪ0��������L������L��������randһ��M*M�ģ���MΪ1440��
%�����Լ����ҵ���lamda֮�����µ�lamda��������ǰ100����ΪX��ѡȡ��feature��ȡ��Щ����Ϊ��Ҫѡȡ��X���У�����һ���µ�1440*100�ľ����γ��µ�fea,���뵽�����NormalizeFea�С�?
L = zeros(1440,1440);
alpha = 0.01;
belta = 0;%�Ȳ�����������˹����
epsilon = 0.1;%�𽥵���epsilon��ֵ
lamda_last = mlt_main_function_new(fea',L,alpha,belta,epsilon);

%�����lamda_new֮��Ҫ��lamda_new�ĶԽ���Ԫ������������Ԫ�أ���Ϊ��ѡ���feature�Ĵ���
%�Ȱ�lamda_last�еĶԽ���Ԫ�����г�������
lamda_last_row = zeros(1,1024);
for i = 1:1024
lamda_last_row(1,i) = lamda_last(i,i);
end

%Ȼ������lamda_last_row������ǰ100��Ԫ�أ��ȶ���lamda_row_last_row�������򣬲�������ԭʼ�����ind�����У�������󣨼����󣩵�100�����
[lamda_last_row_sort,ind] = sort(lamda_last_row);
%Ȼ���ҳ�ind�ĺ�100λ��ֵ��Ϊfea��Ҫѡȡ���У�����Щ��ȡ������һ���¾��󣬹����µ�fea
fea_new = zeros(1440,100);
for r=1:100
    fea_new(:,ind(end-r+1)) = fea(:,ind(end-r+1));
end
fea_new = NormalizeFea(fea_new);
fprintf('the fea_new is :');
disp(fea_new);
fprintf('the final fea_new which we have selected is like up:\n');

%Clustering in the original space
rand('twister',5489);
label = litekmeans(fea_new,nClass,'Replicates',10);
MIhat = MutualInfo(gnd,label);
disp(['kmeans use all the features. MIhat: ',num2str(MIhat)]);