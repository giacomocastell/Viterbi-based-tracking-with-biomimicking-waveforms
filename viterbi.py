import numpy as np
from matplotlib import pyplot as plt
from Functions.Python import python_functions as fn
import sys
import os

# Read inputs from Matlab script
if len(sys.argv) > 3:
    # Access command-line arguments
    index_1 = int(sys.argv[1])
    index_2 = int(sys.argv[2])
    waveform = sys.argv[3]
else:
    index_1 = 1000
    index_2 = 2000
    waveform = 'biomimicked'

# Main path to .mat files
mainpath = 'Output/'

# If emission matrix is to be taken from somewhere else, pass it to the function
emission_matrix_path = ''

# Read data
[path, data, range, emission_matrix] = fn.getData(mainpath, emission_matrix_path, index_1, index_2, waveform)

# Prepare for Viterbi
[observations, transition_matrix, states, priors] = fn.prepareViterbi(data, range)

# Run Viterbi
viterbi_path = fn.viterbi(observations, states, priors, transition_matrix, emission_matrix, index_1)

# Save results into txt file
np.savetxt( os.path.join(path, 'viterbi_results.txt'), (np.array(viterbi_path) + index_1))

# Plot results
fn.plotresults(data, range, viterbi_path)