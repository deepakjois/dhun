#include "dhun.h"
// Include the Ruby headers and goodies
#include "ruby.h"

// Defining a space for information and references about the module to be stored internally
static VALUE DhunExt = Qnil;

static VALUE Spotlight = Qnil;

static VALUE Player = Qnil;

// Prototype for the initialization method - Ruby calls this, not you
void Init_dhunruby();
static VALUE method_play_file(VALUE self, VALUE fileName);
static VALUE method_query_spotlight(VALUE self, VALUE query);
// The initialization method for this module
void Init_dhunruby() {
  DhunExt = rb_define_class("DhunExt", rb_cObject);
  rb_define_singleton_method(DhunExt, "play_file", method_play_file, 1);
  rb_define_singleton_method(DhunExt, "query_spotlight", method_query_spotlight, 1);
}

static VALUE method_play_file(VALUE self, VALUE filename) {
  playFile(StringValuePtr(filename));
  return Qnil;
}

static VALUE method_query_spotlight(VALUE self, VALUE query) {
  getFilesForQuery(StringValuePtr(query));
  return Qnil;
}

