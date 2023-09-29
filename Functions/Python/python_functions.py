import numpy as np
from matplotlib import pyplot as plt
import os
import datetime
from scipy import io

def getData(mainpath, emission_matrix_path, index_1, index_2, waveform, distance):
    
    # Sub-path of the simulation results
    today_date = datetime.date.today()
    date = today_date.strftime("%Y-%m-%d")
    subpath = date + '_' + waveform + '_' + distance + 'meters'

    # Final path of the simulation results
    path = os.path.join(mainpath,subpath)

    # Sub-path of the emission matrix (if not given)
    if emission_matrix_path == '':
        filename = date + '_' + waveform + '_' + distance + 'meters.mat'
        emission_matrix_path = os.path.join(mainpath, 'Emission matrix',filename)
    
    # Import range axis
    mat = io.loadmat(os.path.join(path, 'ranges.mat'))
    rng = mat['range_axis']

    # Import values of the TD matrix
    mat = io.loadmat(os.path.join(path, 'values.mat'))
    val = mat['value']

    # Import empirical emission matrix
    mat = io.loadmat(emission_matrix_path)
    emission_matrix = mat['emission_matrix']
    
    if emission_matrix.shape[1] != abs(index_1 - index_2):
        print('\nSecond index is too large, maximum dimension of the emission matrix is being selected\n')
        index_2 = len(emission_matrix) - 1
        
    M = np.abs(val[:, index_1:index_2])
    mr = np.abs(rng[:, index_1:index_2])
    B = (np.abs(emission_matrix[index_1:index_2, index_1:index_2])).T

    return path, M, mr, B

def prepareViterbi(M, mr):
    # States are the columns, i.e., mr
    st = np.arange(1 , mr.shape[1])

    # Observations are the rows
    # Find maximum of each row (observation)

    observations = np.argmax(M, axis=1)

    # Transition matrix
    vmax = 1
    dt = 0.5
    
    k = mr[0, :]
    j = mr[0, :]

    A = np.abs(k - j[:, np.newaxis]) <= vmax * dt
    A = A * vmax * dt
    A = {index+1 : row.tolist() for index, row in enumerate(A)}


    # Prior probabilities (uniform)
    priors = np.full(mr.shape[1],1/mr.shape[1])

    # Convert to required format
    observations = tuple(observations)
    states = tuple(st)
    priors = dict(enumerate(priors.flatten(), 1))

    return observations, A, states, priors

def viterbi(obs, states, start_p, trans_p, emit_p, bias=0):
    V = [{}]
    
    # First observation
    for st in states:
        V[0] [st] = {"prob": start_p[st] * emit_p[st] [obs[0]], "prev": None}

    # Run Viterbi when t > 0
    for t in range(1, len(obs)):
        print(f"Running Viterbi iteration {t}/{len(obs)}", end='\r')
        V.append({})
        for st in states:
            max_tr_prob = V[t - 1] [states[0]] ["prob"] * trans_p[states[0]] [st] * emit_p[st] [obs[t]]
            prev_st_selected = states[0]
            for prev_st in states[1:]:
                tr_prob = V[t - 1] [prev_st] ["prob"] * trans_p[prev_st] [st] * emit_p[st] [obs[t]]
                if tr_prob > max_tr_prob:
                    max_tr_prob = tr_prob
                    prev_st_selected = prev_st
            
            max_prob = max_tr_prob
            V[t] [st] = {"prob": max_prob, "prev": prev_st_selected}

    opt = []
    max_prob = 0.0
    best_st = None
    # Get most probable state and its backtrack
    
    for st, data in V[-1].items():
        if data["prob"] > max_prob:
            max_prob = data["prob"]
            best_st = st
    opt.append(best_st)
    previous = best_st
    
    # Follow the backtrack till the first observation
    
    for t in range(len(V) - 2, -1, -1):
        opt.insert(0, V[t + 1] [previous] ["prev"])
        previous = V[t + 1] [previous] ["prev"]
    
    print ("The steps of states are " + " ".join(str(o + bias) for o in opt) + " with highest probability of %s" % str(max_prob))

    return opt

def plotresults(matrix, ranges, V):
    timeaxis = np.arange(1, matrix.shape[0] + 1)

    N = np.zeros_like(matrix)
    for t in range(len(timeaxis)):
        N[t,V[t]] = 1

    plt.figure()
    plt.subplot(211)
    plt.imshow(matrix, extent=(ranges.min(), ranges.max(), timeaxis.min(), timeaxis.max()),
            aspect='auto', cmap='viridis', origin='lower')
    plt.colorbar(label='Magnitude')
    plt.xlabel('Range [m]]')
    plt.ylabel('Time [s]')
    plt.title('Magnitude')

    plt.subplot(212)
    plt.imshow(N, extent=(ranges.min(), ranges.max(), timeaxis.min(), timeaxis.max()),
            aspect='auto', cmap='viridis', origin='lower')
    plt.colorbar(label='Estimated path')
    plt.xlabel('Range [m]')
    plt.ylabel('Time [s]')
    plt.title('Estimated path')
    plt.show()