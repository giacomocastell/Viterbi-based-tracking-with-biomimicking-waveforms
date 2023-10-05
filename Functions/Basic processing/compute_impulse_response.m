%%%%
%%%% Compute channel impulse response with Bellhop output
%%%%

function [y,t_out]=compute_impulse_response(x,t,fs,arrivals,loss_factor)
    
    drawplot = 0;
    
    % Compute signal using proper delay time scale
    if length(arrivals.delay)==1
        t_ir = arrivals.delay:1/fs:arrivals.delay+0.5*arrivals.delay-1/fs;

    % Handle case where first and last arrival are very close
    elseif abs(arrivals.delay(1) - arrivals.delay(end)) < 0.0001        
        t_ir = arrivals.delay(1):1/fs:arrivals.delay(1)+0.5*arrivals.delay(1)-1/fs;
        d = arrivals.delay(1);
        clear arrivals.delay;
        arrivals.delay = d;
        
        a = arrivals.A;
        clear arrivals.A;
        arrivals.A = a;
    
    % Most general case
    else
        t_ir = arrivals.delay(1):1/fs:arrivals.delay(end)-1/fs;
    end

    % Initialzize channel impulse response
    h = zeros(size(t_ir));
    
    % Necessary step to have compatible measurements in terms of sampling freq
    del_tmp = zeros(length(arrivals.delay),1);

    % fprintf('\nNumber of arrivals: %d\n',length(arrivals.delay));
    
    for k = 1:length(arrivals.delay)
        [~,idx] = min(abs(t_ir-arrivals.delay(k)));
        del_tmp(k) = t_ir(idx);
    end
    
    % Adjust by removing possible redundancies due to low sampling frequency
    [del_tmp_adj,idRed] = unique(del_tmp);
    % Extract redundant indexes
    d = setdiff(1:1:length(del_tmp),idRed);
    % Extract relative amplitudes
    ampl_tmp_adj = setdiff(arrivals.A,arrivals.A(d),'stable');

    % fprintf('Number of arrivals after processing: %d\n\n',length(ampl_tmp_adj));
    
    % Compute system impulse response
    j = 1;
    for i = 1:size(t_ir,2)
        if (j <= length(del_tmp_adj) && t_ir(i) == del_tmp_adj(j))
            h(:,i) = abs(ampl_tmp_adj(j));
            j = j+1;
        end
    end
    
    % Perform convolution
    y_one_way = conv(x,h);

    % Phase reversal due to reflection
    % and multiplication by a loss factor
    y_one_way = y_one_way * loss_factor;   
    
    % Find time axis
    t_one_way = t_ir(1) + t(1) + (0:length(y_one_way)-1) / fs;
    
    % Perform reverse convolution 
    y = conv(y_one_way,h);
    
    % Update time axis
    t_out = t_one_way(1) + t_ir(1) + (0:length(y)-1) / fs;

    if drawplot
        figure;
        subplot(311);
        stem(t_ir,h);%xlim([2.55 2.8]);
        xlabel('Time(s)');
        ylabel('Amplitude');
        title("Impulse response");
        subplot(312);
        plot(t_one_way,y_one_way);
        xlabel('Time(s)');
        ylabel('Amplitude');
        title("One-way signal");
        subplot(313);
        plot(t_out,y)
        xlabel('Time(s)');
        ylabel('Amplitude');
        title("Output signal");
    end
    
end