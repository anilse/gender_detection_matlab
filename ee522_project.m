clear all;
close all;
clc;
while(1)
    choice = menu('*****           Gender Detection           *****', ...
        '=====           From audio file           =====', ... 
        '=====           By recording              =====', ...
        '=====               Exit             =====');
    switch choice
        case 1
            soundfile();
        case 2
            recording();
        case 3
            clear choice;
            return;
        otherwise
            clear choice;
            return;
    end
end