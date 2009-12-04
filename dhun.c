#include "dhun.h"

void print_usage(int exit_code) {
  printf("Usage: dhun /path/to/file\n");
  exit(exit_code);
}

static void HandleOutputBuffer (
                                void                *aqData,
                                AudioQueueRef       inAQ,
                                AudioQueueBufferRef inBuffer
                                ) {
  AQPlayerState *pAqData = (AQPlayerState *) aqData;

  if (pAqData->mIsRunning == 0) return;
  UInt32 numBytesReadFromFile;
  UInt32 numPackets = pAqData->mNumPacketsToRead;

  AudioFileReadPackets (
                        pAqData->mAudioFile,
                        false,
                        &numBytesReadFromFile,
                        pAqData->mPacketDescs,
                        pAqData->mCurrentPacket,
                        &numPackets,
                        inBuffer->mAudioData
                        );
  if (numPackets > 0) {
    inBuffer->mAudioDataByteSize = numBytesReadFromFile;
    AudioQueueEnqueueBuffer (
                             pAqData->mQueue,
                             inBuffer,
                             (pAqData->mPacketDescs ? numPackets : 0),
                             pAqData->mPacketDescs
                             );
    pAqData->mCurrentPacket += numPackets;
  } else {
    AudioQueueStop (
                    pAqData->mQueue,
                    false
                    );
    pAqData->mIsRunning = false;
  }
}

void DeriveBufferSize (
                       AudioStreamBasicDescription *ASBDesc,
                       UInt32                      maxPacketSize,
                       Float64                     seconds,
                       UInt32                      *outBufferSize,
                       UInt32                      *outNumPacketsToRead
                       ) {
  static const int maxBufferSize = 0x50000;
  static const int minBufferSize = 0x4000;

  if (ASBDesc->mFramesPerPacket != 0) {
    Float64 numPacketsForTime =
      ASBDesc->mSampleRate / ASBDesc->mFramesPerPacket * seconds;

    *outBufferSize = numPacketsForTime * maxPacketSize;
  } else {
    *outBufferSize =
      maxBufferSize > maxPacketSize ?
      maxBufferSize : maxPacketSize;
  }

  if (
      *outBufferSize > maxBufferSize &&
      *outBufferSize > maxPacketSize
      )
    *outBufferSize = maxBufferSize;
  else {
    if (*outBufferSize < minBufferSize)
      *outBufferSize = minBufferSize;
  }

  *outNumPacketsToRead = *outBufferSize / maxPacketSize;
}

int main(int argc, char *argv[])
{
  if (argc < 2) print_usage(1);


  const char* filePath = argv[1];

  CFURLRef audioFileURL =
    CFURLCreateFromFileSystemRepresentation(NULL,
                                            (UInt8*) filePath,
                                            strlen (filePath),
                                            false
                                            );

  AQPlayerState aqData;

  OSStatus result =
    AudioFileOpenURL(audioFileURL,
                     fsRdPerm,
                     0,
                     &aqData.mAudioFile);

  CFRelease (audioFileURL);

  UInt32 dataFormatSize = sizeof (aqData.mDataFormat);

  AudioFileGetProperty(aqData.mAudioFile,
                       kAudioFilePropertyDataFormat,
                       &dataFormatSize,
                       &aqData.mDataFormat);

  AudioQueueNewOutput(&aqData.mDataFormat,
                      HandleOutputBuffer,
                      &aqData,
                      CFRunLoopGetCurrent (),
                      kCFRunLoopCommonModes,
                      0,
                      &aqData.mQueue);

  UInt32 maxPacketSize;
  UInt32 propertySize = sizeof (maxPacketSize);
  AudioFileGetProperty(aqData.mAudioFile,
                       kAudioFilePropertyPacketSizeUpperBound,
                       &propertySize,
                       &maxPacketSize);

 
  DeriveBufferSize(&aqData.mDataFormat,
                   maxPacketSize,
                   0.5,
                   &aqData.bufferByteSize,
                   &aqData.mNumPacketsToRead);

   bool isFormatVBR = (                                       // 1
                      aqData.mDataFormat.mBytesPerPacket == 0 ||
                      aqData.mDataFormat.mFramesPerPacket == 0
                                                             );

  if (isFormatVBR) {                                         // 2
    // LOG("%s\n","VBR");
    aqData.mPacketDescs =
      (AudioStreamPacketDescription*) malloc (
                                              aqData.mNumPacketsToRead * sizeof (AudioStreamPacketDescription)
                                              );
  } else {                                                   // 3
    aqData.mPacketDescs = NULL;
  }

  UInt32 cookieSize = sizeof (UInt32);                   // 1
  bool couldNotGetProperty =                             // 2
    AudioFileGetPropertyInfo (                         // 3
                              aqData.mAudioFile,                             // 4
                              kAudioFilePropertyMagicCookieData,             // 5
                              &cookieSize,                                   // 6
                              NULL                                           // 7
                                                       );

  if (!couldNotGetProperty && cookieSize) {              // 8
    char* magicCookie =
      (char *) malloc (cookieSize);

    AudioFileGetProperty (                             // 9
                          aqData.mAudioFile,                             // 10
                          kAudioFilePropertyMagicCookieData,             // 11
                          &cookieSize,                                   // 12
                          magicCookie                                    // 13
                                                       );

    AudioQueueSetProperty (                            // 14
                           aqData.mQueue,                                 // 15
                           kAudioQueueProperty_MagicCookie,               // 16
                           magicCookie,                                   // 17
                           cookieSize                                     // 18
                                                       );

    free (magicCookie);                                // 19
  }
  aqData.mCurrentPacket = 0;                                // 1
  aqData.mIsRunning = true;                          // 1 (from below)
  //LOG("%d\n", aqData.mNumPacketsToRead);
  for (int i = 0; i < kNumberBuffers; ++i) {                // 2
    AudioQueueAllocateBuffer (                            // 3
                              aqData.mQueue,                                    // 4
                              aqData.bufferByteSize,                            // 5
                              &aqData.mBuffers[i]                               // 6
                                                          );

    HandleOutputBuffer (                                  // 7
                        &aqData,                                          // 8
                        aqData.mQueue,                                    // 9
                        aqData.mBuffers[i]                                // 10
                                                          );
  }

  Float32 gain = 1.0;                                       // 1
  // Optionally, allow user to override gain setting here
  AudioQueueSetParameter (                                  // 2
                          aqData.mQueue,                                        // 3
                          kAudioQueueParam_Volume,                              // 4
                          gain                                                  // 5
                                                            );


  //LOG("%s\n","Starting play");


 // IMPORTANT NOTE : This value must be set
 // Before the call to HandleOutputBuffer  
 //aqData.mIsRunning = true;                          // 1

  AudioQueueStart (                                  // 2
                   aqData.mQueue,                                 // 3
                   NULL                                           // 4
                                                     );

  do {                                               // 5
    CFRunLoopRunInMode (                           // 6
                        kCFRunLoopDefaultMode,                     // 7
                        0.25,                                      // 8
                        false                                      // 9
                                                   );
  } while (aqData.mIsRunning);

  CFRunLoopRunInMode (                               // 10
                      kCFRunLoopDefaultMode,
                      1,
                      false
                                                     );

  AudioQueueDispose (                            // 1
                     aqData.mQueue,                             // 2
                     true                                       // 3
                                                 );

  AudioFileClose (aqData.mAudioFile);            // 4

  free (aqData.mPacketDescs);                    // 5
  return 0;
}
