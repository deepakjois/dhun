#include "dhun.h"
// Include the Ruby headers and goodies
#include "ruby.h"

// Defining a space for information and references about the module to be stored internally
static VALUE DhunExt = Qnil;

static VALUE Spotlight = Qnil;

static VALUE Player = Qnil;

// Prototype for the initialization method - Ruby calls this, not you
void Init_dhunruby();
void method_play_file(VALUE self, VALUE fileName);

// The initialization method for this module
void Init_dhunruby() {
  DhunExt = rb_define_module("DhunExt");
  Player = rb_define_class_under(DhunExt, "Player", rb_cObject);
  rb_define_singleton_method(Player, "play_file", method_play_file, 1);
}

void method_play_file(VALUE self, VALUE filename) {
  playFile(StringValuePtr(filename));
}

