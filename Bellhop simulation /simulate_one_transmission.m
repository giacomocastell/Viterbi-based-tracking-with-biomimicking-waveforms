%%%%
%%%% Obtain data from Bellhop and process 
%%%%

function [dist,range_corr,corr] = simulate_one_transmission(signalTX,scenario_settings,pos_RX, emission_matrix_flag)
    
    % Scenario variables (increase readability)
    maxDepth   = scenario_settings.maxDepth;
    bathymetry = scenario_settings.bathymetry;
    pos_TX     = scenario_settings.pos_TX;
    c          = scenario_settings.c;
    
    % Signal
    x = signalTX.x;
    t = signalTX.t;
    tau = signalTX.tau;
    fs = signalTX.fs;
    f1 = signalTX.f1;
    f2 = signalTX.f2;
    
    % Flags
    drawplot = 0;
    MF_flag  = 0;
    
    % Function that actually runs Bellhop
    Arr = bellhop_simulation(pos_TX, pos_RX, maxDepth, bathymetry);
    
    % Actual distance (ground truth)
    dist = computeDistanceTXRX(pos_TX, pos_RX);

    % Simulate scenario (two-way convolution)
    [y,ty] = compute_impulse_response(x,t,fs,Arr,scenario_settings.loss_factor);
    
    % Add AWGN with desired SNR (before cross-correlation)
    y = add_noise_model(y, scenario_settings.SNRdB);
    
    % Filter and move signals to baseband
    downsampling_factor = floor(fs/f2);
    cutoff = abs(f2-f1);
    fs_downsampled = fs/downsampling_factor;
    
    [x_bb,tx_bb] = baseband(x,t,fs,(f1+f2)/2,cutoff,downsampling_factor);
    [y_bb,ty_bb] = baseband(y,ty,fs,(f1+f2)/2,cutoff,downsampling_factor);

    % Estimate delay/range using conv
    corr = conv(y_bb,conj(x_bb));

    % Set to zero all convolution results smaller than 1/2 of the peak
    % height
    corr(abs(corr) < 0.5*max(abs(corr))) = 0;

    % Group delay ???????
    if strcmp (scenario_settings.waveform_type, 'chirp') || strcmp(scenario_settings.waveform_type, 'biomimicking')
        group_delay = (length(x_bb) - 1) / (2 * fs_downsampled); 
    else
        [~, locs_peak] = max(abs(x));
        group_delay = locs_peak(1)/(2*fs_downsampled); 
    end
    
    % Compute group delay and adjust time axis
    delay_corr = ty_bb(1) + tx_bb(1) + (0:length(corr)-1) / fs_downsampled - 2*group_delay;

    % Convert times to spatial distances
    range_corr = c*delay_corr/2;
    
    % Remove eventual negative ranges
    corr = corr(range_corr > 0);
    % delay_corr = delay_corr(range_corr > 0);
    range_corr = range_corr(range_corr > 0);
    
    if ~emission_matrix_flag
        
        [start_idx, end_idx] = remNonzero(corr);
        
        % Update correlation and spatial reference
        corr = corr(start_idx:end_idx);
        range_corr = range_corr(start_idx:end_idx);
    
    end

    % Extract peaks and compute estimates of the distance
    [pks_corr, locs_corr] = findpeaks(abs(corr),range_corr);
    ranges = locs_corr(pks_corr > 0.5*max(abs(corr)));
    
    % Estimate delay/range using matched filter (currently not working)
    if MF_flag
        
        Pf = 1e-4;                      % Probability of false alarm
        TH = CalcTH((f2-f1)*tau, Pf);   % Threshold
        
        MF = NormCorrVer0(y_bb, x_bb, 1, 1);
        MF(isinf(MF))=0;
        MF(isnan(MF))=0;
        
        group_delay = (length(x_bb) - 1) / (2 * fs_downsampled);
        delay_MF = ty_bb(1) + tx_bb(1) + (0:length(MF)-1) / fs_downsampled - 2*group_delay;
        
        [pks_MF, locs_MF] = findpeaks(abs(MF),delay_MF);
        estimated_delay_MF = locs_MF(pks_MF>TH);
        range_MF = c*estimated_delay_MF/2;
    end

    % Show results
    if drawplot

        figure;
        subplot(221);
        plot(tx_bb, x_bb);
        title("Transmitted signal");
        subplot(222);
        plot(ty_bb,y_bb);
        title("Received downsampled and filtered signal");
        subplot(223);
        plot(range_corr,corr);
        xlabel("Range [m]")
        title("Cross-correlation");
        subplot(224)
        plot(delay_corr(firstNonzeroIndex:end),corr);
        xlabel("Delay [s]")
        title("Cross-correlation");
        
%         fprintf('\nReal distance = %.2f [m]\n', dist);
%         fprintf('Estimated distance (cross-corr) = %.2f [m]\n', ranges);
    
        if MF_flag
            subplot(224);
            plot(delay_MF,abs(MF));
            title("Matched Filter (method 2)");

            fprintf('Estimated distance (matched filter) = %.2f [m]\n',range_MF);
        end 
          
    end

end