function lamda_new = mlt_lamda_update(X,L,A,lamda_old,alpha,belta)
%ѭ�����㺯���ݶ�gradient��������Ϊsigma(sigma(x_kj - sigma(lamda_i * a_ik * x_ij))^2) + alpha * |lamda_p| + belta * sigma(Y_pp *  lamda_p * lamda_p)��
%���Ҹ����ݶȵļ���ֵ���ҳ��ݶ�����lamdaֵ��lamda_p�������и��£���lamda_p_new = (sigma(sigma(a_pk^2 * x_pj^2)) + belta * Y_pp)^-1 * ��sigma(sigma(r_jk * a_pk * x_pj)) - alpha*thelta_p/2��
%n������Ҫѡȡ��feature������,XΪԭʼ���ݾ���LΪ������˹����
%new_lamda = zeros(n,1);
[N,M] = size(X);%X����������featrue�ĸ�����X����������X�����ݸ���
lamda_new = lamda_old; %lamda_new����ÿ�θ���֮���lamda����
Y = X * L * X';
for i = 1:1
    %����100�Σ�ÿ��ѡȡ�����ݶ�����lamda�����и���
    gradient_lamda_p_max = mlt_gradientcalu(X,lamda_new,Y,1,A,alpha,belta,M,N);%������ʱ�洢���ĵ������п������е�����Ϊ��0С�ĸ�������ô��ʼ���õĵ����ͱ���Ϊ����lamda_1�ĵ�������gradient_lamda_p_max_index��ʼ��Ϊ1��
                             %��ֹ�������gradient_lamda_p_max_index���վ���k��ѭ���󲻸��£�(�����еĵ�������gradient_lamda_p_max��ʼֵС���������)
    gradient_lamda_p_max_index = 1;%������ʱ�洢���ĵ��������,��ʼ��Ϊ1
    for k = 2:N %�������е����������󵼣������ҳ����ĵ���
        gradient_lamda_p = mlt_gradientcalu(X,lamda_new,Y,k,A,alpha,belta,M,N); %gradient_lamda_p����ÿ�ζ���lamda_p�󵼵Ľ��
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
    sigma_a_pk_x_pj = belta*Y(p,p);%�˴�
    for j = 1:M
        for k = 1:N
            sigma_a_pk_x_pj = sigma_a_pk_x_pj + A(p,k)^2 * X(p,j)^2;
        end
    end
    
    %��������sigma(sigma(r_jk * a_pk * x_pj)) - alpha*thelta_p/2
    sigma_r_jk_a_pk_x_pj = -((alpha*thelta_p)/2);
    for j = 1:M
        for k = 1:N
            %����r_kj
            r_kj = X(k,j);
            if p == 1
                r_kj = r_kj;
            else
                for l = 1:(p-1)
                    r_kj = r_kj - lamda_new(l,l)*A(l,k)*X(l,j);
                end
                for l = (p+1):N
                    r_kj = r_kj - lamda_new(l,l)*A(l,k)*X(l,j);
                end
            end
            sigma_r_jk_a_pk_x_pj = sigma_r_jk_a_pk_x_pj + r_kj*A(p,k)*X(p,j);
        end
    end
    lamda_p_new = (sigma_a_pk_x_pj^-1) * sigma_r_jk_a_pk_x_pj;
    lamda_new(p,p) = lamda_p_new;
    %new_lamda(p,1) = lamda_p_new;
end
end

function gradient_lamda_p = mlt_gradientcalu(X,lamda_new,Y,p,A,alpha,belta,M,N)
%����lamda_j�󵼵ĺ���
%X����ԭʼ���ݾ���lamda_new����Ҫ���и��µ�lamda����Y����������˹������X��X^T����ĳ˻�,j����Ҫ���µ�lamda����ţ�A����ϵ������
gradient_lamda_p = 2*belta*Y(p,p)*lamda_new(p,p);%�ȼ��Ϻ���belta * Y_pp *lamda_p^2�Ĺ���lamda_p����
for j = 1:M
   
    for k = 1:N
        r_kj = X(k,j);%r_kj��Ϊ�����е�r_kj^-p
        %����sigma(lamda_i *a_ik*x_ij)(i!=p)
        if p == 1
            r_kj = r_kj;
        else
            for i = 1:(p - 1)
                r_kj = r_kj - lamda_new(i,i)*A(i,k)*X(i,j);
            end
            for i = (p + 1):N
                r_kj = r_kj - lamda_new(i,i)*A(i,k)*X(i,j);
            end
        end
        gradient_lamda_p = gradient_lamda_p + 2*(r_kj - lamda_new(p,p) * A(p,k) * X(p,j)) * (-A(p,k) * X(p,j));
        fprintf('for lamda_p %d: gradient_lamda_p for j:%d,k:%d is %d\n',p,j,k,gradient_lamda_p);
    end
end
end