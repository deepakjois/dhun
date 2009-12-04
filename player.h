#include <CoreAudio/CoreAudioTypes.h>
#include <AudioToolbox/AudioToolbox.h>
#include <CoreServices/CoreServices.h>

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


void playFile(const char* filePath);
