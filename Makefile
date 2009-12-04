
default: 
	gcc -std=c99 -framework CoreAudio -framework AudioToolbox -framework CoreServices player.c dhun.c  -o dhun
