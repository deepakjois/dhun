#include "dhun.h"

static void HandleOutputBuffer (void                *aqData,
                                AudioQueueRef       inAQ,
                                AudioQueueBufferRef inBuffer) {
  AQPlayerState *pAqData = (AQPlayerState *) aqData;

  if (pAqData->mIsRunning == 0) return;
  UInt32 numBytesReadFromFile;
  UInt32 numPackets = pAqData->mNumPacketsToRead;

  AudioFileReadPackets (pAqData->mAudioFile,
                        false,
                        &numBytesReadFromFile,
                        pAqData->mPacketDescs,
                        pAqData->mCurrentPacket,
                        &numPackets,
                        inBuffer->mAudioData);
  if (numPackets > 0) {
    inBuffer->mAudioDataByteSize = numBytesReadFromFile;
    AudioQueueEnqueueBuffer (pAqData->mQueue,
                             inBuffer,
                             (pAqData->mPacketDescs ? numPackets : 0),
                             pAqData->mPacketDescs);
    pAqData->mCurrentPacket += numPackets;
  } else {
    AudioQueueStop (pAqData->mQueue,
                    false);
    pAqData->mIsRunning = false;
  }
}

void DeriveBufferSize (AudioStreamBasicDescription *ASBDesc,
                       UInt32                      maxPacketSize,
                       Float64                     seconds,
                       UInt32                      *outBufferSize,
                       UInt32                      *outNumPacketsToRead) {
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

void playFile(const char* filePath) {

  CFURLRef audioFileURL = CFURLCreateFromFileSystemRepresentation(NULL,
                                                                  (UInt8*) filePath,
                                                                  strlen (filePath),
                                                                  false);

  AQPlayerState aqData;

  OSStatus result = AudioFileOpenURL(audioFileURL,
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
                      CFRunLoopGetCurrent(),
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

  bool isFormatVBR = (aqData.mDataFormat.mBytesPerPacket == 0 ||
                      aqData.mDataFormat.mFramesPerPacket == 0);

  if (isFormatVBR) {
    // LOG("%s\n","VBR");
    aqData.mPacketDescs =
      (AudioStreamPacketDescription*)
      malloc (aqData.mNumPacketsToRead * sizeof (AudioStreamPacketDescription));
  } else {
    aqData.mPacketDescs = NULL;
  }

  UInt32 cookieSize = sizeof (UInt32);
  bool couldNotGetProperty =
    AudioFileGetPropertyInfo (aqData.mAudioFile,
                              kAudioFilePropertyMagicCookieData,
                              &cookieSize,
                              NULL);

  if (!couldNotGetProperty && cookieSize) {
    char* magicCookie = (char *) malloc (cookieSize);

    AudioFileGetProperty (aqData.mAudioFile,
                          kAudioFilePropertyMagicCookieData,
                          &cookieSize,
                          magicCookie);

    AudioQueueSetProperty (aqData.mQueue,
                           kAudioQueueProperty_MagicCookie,
                           magicCookie,
                           cookieSize);

    free (magicCookie);
  }

  aqData.mCurrentPacket = 0;
  aqData.mIsRunning = true;

  //LOG("%d\n", aqData.mNumPacketsToRead);
  for (int i = 0; i < kNumberBuffers; ++i) {
    AudioQueueAllocateBuffer (aqData.mQueue,
                              aqData.bufferByteSize,
                              &aqData.mBuffers[i]);

    HandleOutputBuffer (&aqData,
                        aqData.mQueue,
                        aqData.mBuffers[i]);
  }

  Float32 gain = 1.0;
  // Optionally, allow user to override gain setting here
  AudioQueueSetParameter (aqData.mQueue,
                          kAudioQueueParam_Volume,
                          gain);


  //LOG("%s\n","Starting play");


  // IMPORTANT NOTE : This value must be set
  // Before the call to HandleOutputBuffer
  //a qData.mIsRunning = true;

  AudioQueueStart (aqData.mQueue,
                   NULL);

  do {
    CFRunLoopRunInMode (kCFRunLoopDefaultMode,
                        0.25,
                        false);
  } while (aqData.mIsRunning);

  CFRunLoopRunInMode (kCFRunLoopDefaultMode,
                      1,
                      false);

  AudioQueueDispose (aqData.mQueue,
                     true);

  AudioFileClose (aqData.mAudioFile);

  free (aqData.mPacketDescs);
}
