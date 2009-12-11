#include "dhun.h"
#include <assert.h>
#include <pthread.h>

// Include the Ruby headers and goodies
#include "ruby.h"
#include "rubysig.h"
// Defining a space for information and references about the module to be stored internally
static VALUE DhunExt = Qnil;

static VALUE Spotlight = Qnil;

static VALUE Player = Qnil;

static pthread_t       posixThreadID;

// Prototype for the initialization method - Ruby calls this, not you
void Init_dhunruby();

static VALUE method_play_file(VALUE self, VALUE fileName);
static VALUE method_stop_play(VALUE self);
static VALUE method_query_spotlight(VALUE self, VALUE query);
static VALUE method_is_playing(VALUE self);
static VALUE method_pause_play(VALUE self);
static VALUE method_resume_play(VALUE self);

// The initialization method for this module
void Init_dhun_ext() {
  DhunExt = rb_define_class("DhunExt", rb_cObject);
  rb_define_singleton_method(DhunExt, "play_file", method_play_file, 1);
  rb_define_singleton_method(DhunExt, "query_spotlight", method_query_spotlight, 1);
  rb_define_singleton_method(DhunExt, "stop", method_stop_play, 0);
  rb_define_singleton_method(DhunExt, "is_playing?", method_is_playing, 0);

  rb_define_singleton_method(DhunExt, "pause",  method_pause_play,0);
  rb_define_singleton_method(DhunExt, "resume", method_resume_play,0);
}

static VALUE method_play_file(VALUE self, VALUE filename) {
  playFile(StringValuePtr(filename));
  struct timeval wait;
  wait.tv_sec=0;
  wait.tv_usec=100*1000;
  do {
    CHECK_INTS;
    CFRunLoopRunInMode (kCFRunLoopDefaultMode,
                        0.25,
                        false);
  } while (aqData.mIsRunning);

  CFRunLoopRunInMode(kCFRunLoopDefaultMode,
                     1,
                     false);
  free_aqData();
  return Qnil;
}

static VALUE method_pause_play(VALUE self) {
  if (aqData.mIsRunning == true)
    AudioQueuePause(aqData.mQueue);
  return Qnil;
}

static VALUE method_resume_play(VALUE self) {
  if (aqData.mIsRunning == true)
    AudioQueueStart(aqData.mQueue,NULL);
  return Qnil;
}

static VALUE method_stop_play(VALUE self) {
  aqData.mIsRunning = false;
  return Qnil;
}

static VALUE method_is_playing(VALUE self) {
  if (aqData.mIsRunning == true)
    return Qtrue;
  else
    return Qfalse;
}

static VALUE method_query_spotlight(VALUE self, VALUE query) {
  getFilesForQuery(StringValuePtr(query));
  VALUE files = rb_ary_new();
  
  if (queryResults.size > 0) { // there were some results
    
    for(int i=0; i<queryResults.size;i++) {
      rb_ary_push(files,rb_str_new2(queryResults.files[i]));
      free(queryResults.files[i]);
    }

    if (queryResults.size > 0) {
      queryResults.size = 0;
      free(queryResults.files);
    }
  }

  return files;
}

