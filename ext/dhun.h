#include <stdio.h>
#include <string.h>

#include <CoreServices/CoreServices.h>
#include <CoreAudio/CoreAudioTypes.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreServices/CoreServices.h>

#define LOG(f,s) fprintf(stderr,f,s);fflush(stderr);
#define QUERY_TEMPLATE "kMDItemContentTypeTree == 'public.audio' && (kMDItemAlbum == '*%s*'wc || kMDItemTitle == '*%s*'wc || kMDItemDisplayName == '*%s*'wc)"

#define  kNumberBuffers 3
typedef struct {
  AudioStreamBasicDescription   mDataFormat;
  AudioQueueRef                 mQueue;
  AudioQueueBufferRef           mBuffers[kNumberBuffers];
  AudioFileID                   mAudioFile;
  UInt32                        bufferByteSize;
  SInt64                        mCurrentPacket;
  UInt32                        mNumPacketsToRead;
  AudioStreamPacketDescription  *mPacketDescs;
  bool                          mIsRunning;
} AQPlayerState;

extern AQPlayerState aqData; 

typedef struct {
  int size;
  char** files;
} SearchResults;

extern SearchResults queryResults;


void playFile(const char* filePath);
void free_aqData();
int getFilesForQuery(const char* queryStr);
