
default: 
	gcc -std=c99 -framework CoreAudio -framework AudioToolbox -framework CoreServices dhun.c  -o dhun
