function lamda_new = mlt_lamda_update_new(X,L,A,lamda_old,alpha,belta,o)

[N,M] = size(X);
lamda_new = lamda_old; 
Y = X * L * X';


A_i_X_i = cell(1,N);
for i=1:N
    A_i_X_i{1,i}= X(i,:)' * A(i,:);
end


sigma_a_pk_x_pj_square = zeros(1,N);
for p=1:N
    sigma_a_pk_x_pj = belta*Y(p,p);
    for j = 1:M
        for k = 1:N
            sigma_a_pk_x_pj = sigma_a_pk_x_pj + A_i_X_i{1,p}(j,k)^2;
        end
    end
    sigma_a_pk_x_pj_square(1,p) = sigma_a_pk_x_pj;
end

lamda_i_A_i_X_i = cell(1,N);
fprintf('Now we are calulating lamda_i_A_i_X_i\n');
for i=1:N
    lamda_i_A_i_X_i{1,i} = lamda_old(i,i) * A_i_X_i{1,i};
end


fprintf('Now we are calulating x_kj_minus_sigma_lamda_A_ik_X_ij\n');
x_kj_minus_sigma_lamda_A_ik_X_ij = zeros(N,M); 
for j = 1:M
    for k = 1:N
        r_kj = X(k,j);
        for i=1:N
            r_kj = r_kj - lamda_i_A_i_X_i{1,i}(j,k);
        end
        x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) = r_kj;
    end
end

p = 0;

for z = 1:100
    
    lamda_old = lamda_new;
    % lamda_i_A_i_X_i = cell(1,N);
    fprintf('Now we are calulating lamda_i_A_i_X_i\n');
    
    % for i=1:N
        % lamda_i_A_i_X_i{1,i} = lamda_new(i,i) * A_i_X_i{1,i};
    % end
    if z ~= 1
        lamda_i_A_i_X_i{1,p} = lamda_old(p,p) * A_i_X_i{1,p}; 
    end
    
    
    fprintf('Now we are calulating x_kj_minus_sigma_lamda_A_ik_X_ij\n');
    
    % x_kj_minus_sigma_lamda_A_ik_X_ij = zeros(N,M); 
    % for j = 1:M
        % for k = 1:N
            % r_kj = X(k,j);
            % for i=1:N
                % r_kj = r_kj - lamda_i_A_i_X_i{1,i}(j,k);
            % end
            % x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) = r_kj;
        % end
    % end
    
    if z~=1
        for j = 1:M
            for k = 1:N
                r_kj = x_kj_minus_sigma_lamda_A_ik_X_ij(k,j);
                r_kj = r_kj + lamda_p_old_time * A_i_X_i{1,p}(j,k) - lamda_p_new * A_i_X_i{1,p}(j,k);
                x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) = r_kj;
            end
        end
    end
    gradient_lamda_p_max = mlt_gradientcalu_new(X,lamda_old,Y,1,A,alpha,belta,M,N,A_i_X_i,x_kj_minus_sigma_lamda_A_ik_X_ij);
    gradient_lamda_p_max_index = 1;
    fprintf('Now the time of mlt_lamda_update_new is : %d ;the loop of z in 100 is : %d ; the gradient_lamda_p of p: 1 is %d\n',o,z,gradient_lamda_p_max);
    for k = 2:N 
        gradient_lamda_p = mlt_gradientcalu_new(X,lamda_old,Y,k,A,alpha,belta,M,N,A_i_X_i,x_kj_minus_sigma_lamda_A_ik_X_ij); 
        fprintf('Now the time of mlt_lamda_update_new is : %d ; the loop of z in 100 is : %d ; the gradient_lamda_p of p: %d is %d\n',o,z,k,gradient_lamda_p);
        if gradient_lamda_p_max < gradient_lamda_p
            
            gradient_lamda_p_max = gradient_lamda_p;
            gradient_lamda_p_max_index = k;
        end
    end
    p = gradient_lamda_p_max_index;
    if gradient_lamda_p_max > alpha
        thelta_p = -1;
    elseif gradient_lamda_p_max < -(alpha)
        thelta_p = 1;
    else
        thelta_p = 0; 
    end
    
    sigma_a_pk_x_pj = sigma_a_pk_x_pj_square(1,p);
    
    
    
    sigma_r_jk_a_pk_x_pj = -((alpha*thelta_p)/2);
    for j = 1:M
        for k = 1:N
            r_kj = x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) + lamda_old(p,p)*A_i_X_i{1,p}(j,k) ; 
            sigma_r_jk_a_pk_x_pj = sigma_r_jk_a_pk_x_pj + r_kj*A_i_X_i{1,p}(j,k); 
        end
    end
    lamda_p_new = (sigma_a_pk_x_pj^-1) * sigma_r_jk_a_pk_x_pj;
    lamda_p_old_time = lamda_old(p,p);
    lamda_new = lamda_old;
    lamda_new(p,p) = lamda_p_new;
    %new_lamda(p,1) = lamda_p_new;
    for j=1:N
        if lamda_old(j,j) ~= lamda_new(j,j) && j ~= p 
        
            fprintf('Now the lamda has changed value :%d , and the value has changed not for p: %d . Now the z is :%d\n',j,p,z);
        end
    end
    disp(lamda_new);
    fprintf('Now the time of mlt_lamda_update_new is : %d ; and the loop of all lamda gradient is over. the lamda_new of z: %d is in the up. \n',o,z);
    if lamda_new(p,p) == 0
        fprintf('Now the time of mlt_lamda_update_new is : %d ; and the loop of all lamda gradient is over. the lamda_new of z: %d is in the up. And the lamda_new(%d,%d) is zero\n',o,z,p,p);%检测是p为何值时，让lamda_new中出现0的
    end

end
end

function gradient_lamda_p = mlt_gradientcalu_new(X,lamda_new,Y,p,A,alpha,belta,M,N,A_i_X_i,x_kj_minus_sigma_lamda_A_ik_X_ij)

gradient_lamda_p = 2*belta*Y(p,p)*lamda_new(p,p);
[N,M] = size(X);




% A_i_X_i = cell(1,N);
% for i=1:N
    % A_i_X_i{1,i}= X(i,:)' * A(i,:);
% end

% lamda_i_A_i_X_i = cell(1,N);
% for i=1:N
    % lamda_i_A_i_X_i{1,i} = lamda_new(i,i) * X(i,:)'*A(i,:);
% end

for j = 1:M
    for k = 1:N
        gradient_lamda_p = gradient_lamda_p + 2 * x_kj_minus_sigma_lamda_A_ik_X_ij(k,j) * (-A_i_X_i{1,p}(j,k));
    end
end
end
