import numpy as np
import os
from scipy.io import wavfile
from scipy.fft import fft,fftfreq
from matplotlib import pyplot as plt
import math as mt

path='C:/Users/Giacomo/Desktop/Ultrasounds communications/Biomimicking_dataset/Recordings/Humpback_Whale/'
original_path='C:/Users/Giacomo/Desktop/Ultrasounds communications/Biomimicking_dataset/Original/'

data=[]

for filename in os.listdir(path):
    fl = os.path.join(path, filename)
    fs, d = wavfile.read(fl)
    data.append(d)

length = data[0].shape[0] / fs
time = np.linspace(0., length, data[0].shape[0]) #time axis

N=data[0].shape[0]
freq=fftfreq(N, 1/fs)                         #freq axis
# plt.figure()
# plt.plot(time,data[0])
# plt.show()

f=[]
fsum=np.zeros(len(fft(data[0],N)))

for i,d in enumerate(data):
    f.append(fft(d,N))
    fsum=fsum+f[i]

favg=fsum/len(f)

fsorig, original = wavfile.read(original_path+'Humpback_Whale.wav')

Norig=original.shape[0]
freqorig=fftfreq(N, 1/fsorig)

forig=fft(original,Norig)

# Chirp values

f0=20e3
B=5e3
T=1/B

chirp=np.exp(2*mt.pi*(f0*time + (B/(2*T))*(time**2))*1j)
fchirp=fft(chirp,N)

plt.figure()
plt.plot(freq[0:int(N/2)],np.log(abs(favg[0:int(N/2)])/max(abs(favg[0:int(N/2)]))))
# plt.plot(freqorig[0:int(Norig/2)],np.log(abs(forig[0:int(Norig/2)])/max(abs(forig[0:int(Norig/2)]))))
plt.plot(freq[0:int(N/2)],np.log(abs(fchirp[0:int(N/2)])/max(abs(fchirp[0:int(N/2)]))))
plt.show()
