global BHOP_exec

BHOP_exec = which('bellhop.exe');

if isempty(BHOP_exec)

        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/bin');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Bellhop');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Krakel');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Kraken');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Misc');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Pekeris');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Plot');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/ReadWrite');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Scooter');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/Sparc');
        addpath('/home/giacomocastell/Desktop/TESI/bellhop_package/Matlab/waveforms');


end

BHOP_exec = which('bellhop.exe');
