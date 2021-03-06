function problem5(stepsize)

gradient_decent(stepsize)

end

%function sgd(points)
%
%end

function gradient_decent(stepsize)
    close all ; 
    load('data1.mat');
    kernel = rbf_kernel(TrainingX);
    tol = exp(-3);
    lambda= exp(-2);
    %prevtheta = 0.1 * (rand(size(TrainingX,1),1)-0.5);
    prevtheta = ones(size(TrainingX,1),1);
    curiter = 0;
    %start time
    time_start = tic;
    all_time(1) = time_start;
    cost(1) = get_cost(TrainingY,prevtheta,kernel,lambda);
    S_G = ggradient(TrainingY, prevtheta, lambda, kernel);
    theta = prevtheta - stepsize.*S_G;
    diff = norm(theta - prevtheta);
    while diff >= tol
        % Update theta
        prevtheta = theta;
        G = ggradient(TrainingY, prevtheta, lambda, kernel);
        theta = prevtheta - stepsize.*G;
        time_now = toc(time_start);
        diff = norm(theta -prevtheta);
        curiter = curiter + 1;
        all_time(curiter) = time_now;
        cost(curiter) = get_cost(TrainingY,prevtheta,kernel,lambda);
        accuracy(curiter) = error(prevtheta,kernel,TestY);
    end
    fprintf ('Accuracy:%0.4f, step:%0.4f, iter:%d, total time: %d  \n' , accuracy(end), stepsize, curiter, all_time(end) );
    figure(1)
    %index = find(all_time > 20,1)
    plot(all_time(:), cost(:))
    name = sprintf('gk2409_gd_%4f.eps', stepsize);
    ylabel('Cost -J(W)')
    xlabel('Time')
    print(name,'-depsc');
end

function cost = get_cost(y,theta,kernel,lambda)

    N=size(y,1);
    total = 0;
    for i=1:N
        u = y(i)*theta'*kernel(:,i);
        s =1./(1+exp(-u));
        total = total + log(s);
    end
    
    cost = -total./N + lambda*(theta'*theta);
    
end

function g = ggradient(y, theta, lambda, kernel)
    
    N = size(y,1);
    total=zeros(1,N);
    last = 2*lambda*theta';
    for i=1:N
        u = y(i)*theta'*kernel(:,i);
        s = 1./(1+exp(-u));
        ss = ((1-s)*y(i)*kernel(:,i)');
        total = total + ss;
    end
    g = -total./N + last;
    g=g';
    
end

function t_error = error(theta,kernel,Y)
    
    N = size(kernel,1);
    err = zeros(N,1);
    
    for i=1:N
        prob = 1./(1+ exp(-theta'*kernel(:,i)));
        if (prob >=0.5)
            err(i)=1;
        else
            err(i)=-1;
        end
    end
    sum(err~=Y);
    t_error = sum(err~=Y)/length(Y);
end

function K = rbf_kernel(X)
% Inputs:
%       X:      data matrix with training samples in rows and features in columns
% Output:
%       K: kernel matrix

    N = size(X,1);
    D=squareform(pdist(X,'euclidean')).^2;
    K = exp(-D./(1/(N^2))*sum(D(:)));
end