function lamda_new = mlt_lamda_update_new(X,L,A,lamda_old,alpha,belta,o)
%ѭ�����㺯���ݶ�gradient��������Ϊsigma(sigma(x_kj - sigma(lamda_i * a_ik * x_ij))^2) + alpha * |lamda_p| + belta * sigma(Y_pp *  lamda_p * lamda_p)��
%���Ҹ����ݶȵļ���ֵ���ҳ��ݶ�����lamdaֵ��lamda_p�������и��£���lamda_p_new = (sigma(sigma(a_pk^2 * x_pj^2)) + belta * Y_pp)^-1 * ��sigma(sigma(r_jk * a_pk * x_pj)) - alpha*thelta_p/2��
%n������Ҫѡȡ��feature������,XΪԭʼ���ݾ���LΪ������˹����
%new_lamda = zeros(n,1);
[N,M] = size(X);%X����������featrue�ĸ�����X����������X�����ݸ���
lamda_new = lamda_old; %lamda_new����ÿ�θ���֮���lamda����
Y = X * L * X';

%����A_i_X_i��lamda_i_A_i_X_i������������⣬��ΪA��X,lamda���ǹ̶��ģ����Է���mlt_lamda_update�����У����ѽ������mlt_gradientcalu�����У�������ÿ�ζ��ظ�������,
%����A_i_X_i����for zѭ�������棬������ÿ�ζ�Ҫ�ڸ����ݶȺ��ٴμ���һ�飬��lamda_i_A_i_X_i��ÿһ��Ԫ��Ҳֻ��Ҫ��lamda_new(i,i) * A_i_X_i{1,i}������������һ��X(i,:)'*A(i,:)
A_i_X_i = cell(1,N);%�����յ�Ԫϸ�����飬���洢N�����󣬣�X�ĵ�i�е�ת����A�ĵ�i��������õ�M*N����
for i=1:N
    A_i_X_i{1,i}= X(i,:)' * A(i,:);
end

%���ں�����¾�������ݶȵ�lamda�У�sigma(a_pk * x_pj)^2Ҳ������ǰ��������У���1*1024ά�����У�����Ԫ�طֱ��Ӧ��ÿһ��lamda_p��sigma(sigma(a_pk^2 * x_pj^2)) + belta * Y_pp
sigma_a_pk_x_pj_square = zeros(1,N);
for p=1:N
    sigma_a_pk_x_pj = belta*Y(p,p);%�˴���belta * Y_pp
    for j = 1:M
        for k = 1:N
            sigma_a_pk_x_pj = sigma_a_pk_x_pj + A_i_X_i{1,p}(j,k)^2;
        end
    end
    sigma_a_pk_x_pj_square(1,p) = sigma_a_pk_x_pj;
end

lamda_i_A_i_X_i = cell(1,N);%�����յ�Ԫϸ�����飬���洢N�����󣬣�X�ĵ�i�е�ת����A�ĵ�i��������õľ�������lamda_i���������lamda_new(i,i)���������M*N����
fprintf('Now we are calulating lamda_i_A_i_X_i\n');
for i=1:N
    lamda_i_A_i_X_i{1,i} = lamda_old(i,i) * A_i_X_i{1,i};
end

%����sigma(lamda_i * a_i_k * x_i_j)(i=1~N) (��M*N��)Ҫ�洢�������洢Ϊһ������
%��������ÿ��lamda_p���ݶ�ʱ������ֱ��ȡ��ֵ����������ĵ�k,j��Ԫ�أ���������ÿ������ڲ�ͬlamda_p���ݶ�ʱ����Ҫ������һ��ֵ
%�˴�����Ϊ��z=1ʱ��lamda�ݶȼ����������
fprintf('Now we are calulating x_kj_minus_sigma_lamda_A_ik_X_ij\n');
x_kj_minus_sigma_lamda_A_ik_X_ij = zeros(N,M); %�����洢x_ij - sigma(lamda_i * a_i_k * x_i_j)
for j = 1:M
    for k = 1:N
        r_kj = X(k,j);%r_kj��Ϊ�����е�x_kj - sigma(lamda_i * a_i_k * x_i_j),û��ȥ��lamda_p * a_pk * x_pj
        for i=1:N
            r_kj = r_kj - lamda_i_A_i_X_i{1,i}(j,k);
        end
        x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) = r_kj;
    end
end

p = 0;%��ʼ��p��ʹp������ÿһ��whileѭ���󶼱�Ĩȥ

for z = 1:100
    %����100�Σ�ÿ��ѡȡ�����ݶ�����lamda�����и���
    lamda_old = lamda_new;%�����ϴ�ѭ����lamda_new��ֵΪ��ε�lamda_old
    % lamda_i_A_i_X_i = cell(1,N);%�����յ�Ԫϸ�����飬���洢N�����󣬣�X�ĵ�i�е�ת����A�ĵ�i��������õľ�������lamda_i���������lamda_new(i,i)���������M*N����
    fprintf('Now we are calulating lamda_i_A_i_X_i\n');
    %ÿ��ѭ������������һ��lamda_p,����lamda��û�б䣬���Կ��Խ�������һ�μ������lamda_i_A_i_X_i���Ԫϸ�������lamda_i_A_i_X_i{1,p}Ԫ�ؽ��иı䣬�������ٴν����ж����¼���һ��
    % for i=1:N
        % lamda_i_A_i_X_i{1,i} = lamda_new(i,i) * A_i_X_i{1,i};
    % end
    if z ~= 1
        lamda_i_A_i_X_i{1,p} = lamda_old(p,p) * A_i_X_i{1,p}; %��������һ�μ������lamda_i_A_i_X_i���Ԫϸ�������lamda_i_A_i_X_i{1,p}Ԫ�ؽ��иı䣬�������ٴν����ж����¼���һ��
    end
    
    %����sigma(lamda_i * a_i_k * x_i_j)(i=1~N) (��M*N��)Ҫ�洢�������洢Ϊһ������
    %��������ÿ��lamda_p���ݶ�ʱ������ֱ��ȡ��ֵ����������ĵ�k,j��Ԫ�أ���������ÿ������ڲ�ͬlamda_p���ݶ�ʱ����Ҫ������һ��ֵ
    fprintf('Now we are calulating x_kj_minus_sigma_lamda_A_ik_X_ij\n');
    %��������lamda_i_A_i_X_iʱ��ͬ����ʱ����һ��lamda����һ�ε�z��ѭ���������ı䣬���Խ����ı�x_kj_minus_sigma_lamda_A_ik_X_ij��Ӧ��lamda_p��ֵ���ɣ���x_kj_minus_sigma_lamda_A_ik_X_ij����������ֵ���ñ�
    % x_kj_minus_sigma_lamda_A_ik_X_ij = zeros(N,M); %�����洢x_ij - sigma(lamda_i * a_i_k * x_i_j)
    % for j = 1:M
        % for k = 1:N
            % r_kj = X(k,j);%r_kj��Ϊ�����е�x_kj - sigma(lamda_i * a_i_k * x_i_j),û��ȥ��lamda_p * a_pk * x_pj������lamda_p * a_pk * x_ijҲ��������
            % for i=1:N
                % r_kj = r_kj - lamda_i_A_i_X_i{1,i}(j,k);
            % end
            % x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) = r_kj;
        % end
    % end
    %��Ϊÿ��ѭ������lamda���󶼻ᷢ���仯������x_kj_minus_sigma_lamda_A_ik_X_ij�����е�ÿ��ֵ�����������ټ�ȥ��lamda_p*a_ik_x_ij�����˱仯���ı䣬����x_kj_minus_sigma_lamda_A_ik_X_ij��ÿ��ֵ��Ҫ���£������м������һ��forѭ��������r_kj������ѭ�����ˣ����ǿ����ȼ��ϴε�lamda_p*a_ik_x_ij���ټ���ε�lamda_p*a_ik_x_ij��
    if z~=1
        for j = 1:M
            for k = 1:N
                r_kj = x_kj_minus_sigma_lamda_A_ik_X_ij(k,j);%r_kj��Ϊ�����е�x_kj - sigma(lamda_i * a_i_k * x_i_j),û��ȥ��lamda_p * a_pk * x_pj
                r_kj = r_kj + lamda_p_old_time * A_i_X_i{1,p}(j,k) - lamda_p_new * A_i_X_i{1,p}(j,k);
                x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) = r_kj;
            end
        end
    end
    gradient_lamda_p_max = mlt_gradientcalu_new(X,lamda_old,Y,1,A,alpha,belta,M,N,A_i_X_i,x_kj_minus_sigma_lamda_A_ik_X_ij);%������ʱ�洢���ĵ������п������е�����Ϊ��0С�ĸ�������ô��ʼ���õĵ����ͱ���Ϊ����lamda_1�ĵ�������gradient_lamda_p_max_index��ʼ��Ϊ1��
                             %��ֹ�������gradient_lamda_p_max_index���վ���k��ѭ���󲻸��£�(�����еĵ�������gradient_lamda_p_max��ʼֵС���������)?
    gradient_lamda_p_max_index = 1;%������ʱ�洢���ĵ��������,��ʼ��Ϊ1
    fprintf('Now the time of mlt_lamda_update_new is : %d ;the loop of z in 100 is : %d ; the gradient_lamda_p of p: 1 is %d\n',o,z,gradient_lamda_p_max);
    for k = 2:N %�������е����������󵼣������ҳ����ĵ���?
        gradient_lamda_p = mlt_gradientcalu_new(X,lamda_old,Y,k,A,alpha,belta,M,N,A_i_X_i,x_kj_minus_sigma_lamda_A_ik_X_ij); %gradient_lamda_p����ÿ�ζ���lamda_p�󵼵Ľ��
        fprintf('Now the time of mlt_lamda_update_new is : %d ; the loop of z in 100 is : %d ; the gradient_lamda_p of p: %d is %d\n',o,z,k,gradient_lamda_p);
        if gradient_lamda_p_max < gradient_lamda_p
            %���ҳ����ĵ���
            gradient_lamda_p_max = gradient_lamda_p;
            gradient_lamda_p_max_index = k;
        end
    end
    p = gradient_lamda_p_max_index;%����p�������������lamda�����
    if gradient_lamda_p_max > alpha
        thelta_p = -1;
    elseif gradient_lamda_p_max < -(alpha)
        thelta_p = 1;
    else
        thelta_p = 0; 
    end
    %�������ĵ�����Ӧ��gradient_lamda_p_max_index���и���
    %����ǰ���sigma(sigma(a_pk^2 * x_pj^2)) + belta * Y_pp
    sigma_a_pk_x_pj = sigma_a_pk_x_pj_square(1,p);
    
    
    %��������sigma(sigma(r_jk * a_pk * x_pj)) - alpha*thelta_p/2����Ϊÿ��ѭ������lamda���󶼻ᷢ���仯������sigma(sigma(r_jk * a_pk * x_pj))����Ҫ���¼���
    sigma_r_jk_a_pk_x_pj = -((alpha*thelta_p)/2);
    for j = 1:M
        for k = 1:N
            r_kj = x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) + lamda_old(p,p)*A_i_X_i{1,p}(j,k) ; %x_kj_minus_sigma_lamda_A_ik_X_ij(k,j)��lamda_p*a_pk*x_pjҲ�������ˣ�����Ҫ����r_kjʱ�ټӻ���
            sigma_r_jk_a_pk_x_pj = sigma_r_jk_a_pk_x_pj + r_kj*A_i_X_i{1,p}(j,k); 
        end
    end
    lamda_p_new = (sigma_a_pk_x_pj^-1) * sigma_r_jk_a_pk_x_pj;
    lamda_p_old_time = lamda_old(p,p);%�洢���θ��µ�lamda_p�ڸ���ǰ��ֵ����������һ�ε�x_kj_minus_sigma_lamda_A_ik_X_ij��ÿ��Ԫ�ص�����м���lamda_p_old_time���ټ�ȥlamda_p_new
    lamda_new = lamda_old;
    lamda_new(p,p) = lamda_p_new;
    %new_lamda(p,1) = lamda_p_new;
    for j=1:N
        if lamda_old(j,j) ~= lamda_new(j,j) && j ~= p %����lamda�е�ÿ��ֵ���бȶ�����������ı���һ��lamda(p,p)��ֵ���򱨴������������Ĵ�������lamda�ĶԽ�Ԫ��ֵȫ����ֵΪ0
        % &&����Ϊ���롱�����ǰ��Ϊ��0������ֱ�ӽ������߼����ʽ����ֵΪ��0��������������&&����İ���߼����ʽ��ֵ��
            fprintf('Now the lamda has changed value :%d , and the value has changed not for p: %d . Now the z is :%d\n',j,p,z);
        end
    end
    disp(lamda_new);
    fprintf('Now the time of mlt_lamda_update_new is : %d ; and the loop of all lamda gradient is over. the lamda_new of z: %d is in the up. \n',o,z);
    if lamda_new(p,p) == 0
        fprintf('Now the time of mlt_lamda_update_new is : %d ; and the loop of all lamda gradient is over. the lamda_new of z: %d is in the up. And the lamda_new(%d,%d) is zero\n',o,z,p,p);%�����pΪ��ֵʱ����lamda_new�г���0��
    end

end
end

function gradient_lamda_p = mlt_gradientcalu_new(X,lamda_new,Y,p,A,alpha,belta,M,N,A_i_X_i,x_kj_minus_sigma_lamda_A_ik_X_ij)
%����lamda_j�󵼵ĺ���
%X����ԭʼ���ݾ���lamda_new����Ҫ���и��µ�lamda����Y����������˹������X��X^T����ĳ˻�,j����Ҫ���µ�lamda����ţ�A����ϵ������
gradient_lamda_p = 2*belta*Y(p,p)*lamda_new(p,p);%�ȼ��Ϻ���belta * Y_pp *lamda_p^2�Ĺ���lamda_p����
[N,M] = size(X);

%�ֱ���X����ĵ�i����������ת�ú�A����ĵ�i����������ˣ���һ��M*N�ľ���
%�����е�Ԫ��Ϊ(x_i_1*a_i_1, x_i_1*a_i_2, x_i_1*a_i_3, ���� , x_i_1*a_i_n; x_i_2*a_i_1, x_i_2*a_i_2, ����, x_i_2*a_i_n; ��������; x_i_m*a_i_1,x_i_m*a_i_2,���� ,x_i_m*a_i_n)
%����ڵ�i�е�X������A�����Ԫ�س˻����Դ���N��M*N�ľ�������ȡ�ã�ֻҪ�洢����N�����󣬱���Դ���ȡ��Ԫ��������ÿ����Ҫ�˳�A(i,k)*X(i,j)
%ͬ������A����ĵ�i����������X����ĵ�i����������ת�ó˳��ľ���ǰ�����lamda_i����N�����󣬱����lamda_new(i,i)*A(i,k)*X(i,j)Ҳ����ÿ����������Ӿ�����ȡ��Ԫ�ؼ��ɡ�
%lamda_x_a����Ϊ��lamda_i*x_i_1*a_i_1,lamda_i*x_i_1*a_i_2,����,lamda_i*x_i_1*a_i_n;lamda_i*x_i_2*a_i_1,lamda_i*x_i_2*a_i_2,����,lamda_i*x_i_2*a_i_n; �������� ; lamda_i*x_i_m*a_i_1,lamda_i*x_i_m*a_i_2,����lamda_i*x_i_m*a_i_n��

%����A_i_X_i������������⣬��ΪA��X���ǹ̶��ģ����Է���mlt_lamda_update�����У����ѽ������mlt_gradientcalu�����У�������ÿ�ζ��ظ�������
% A_i_X_i = cell(1,N);%�����յ�Ԫϸ�����飬���洢N�����󣬣�X�ĵ�i�е�ת����A�ĵ�i��������õľ���
% for i=1:N
    % A_i_X_i{1,i}= X(i,:)' * A(i,:);
% end

% lamda_i_A_i_X_i = cell(1,N);%�����յ�Ԫϸ�����飬���洢N�����󣬣�X�ĵ�i�е�ת����A�ĵ�i��������õľ�������lamda_i����lamda_new(i,i)��������þ���
% for i=1:N
    % lamda_i_A_i_X_i{1,i} = lamda_new(i,i) * X(i,:)'*A(i,:);
% end

for j = 1:M
    for k = 1:N
        gradient_lamda_p = gradient_lamda_p + 2 * x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) * (-A_i_X_i{1,p}(j,k));
    end
end
end