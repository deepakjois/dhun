// Include the Ruby headers and goodies
#include "ruby.h"

// Defining a space for information and references about the module to be stored internally
VALUE DhunRuby = Qnil;

// Prototype for the initialization method - Ruby calls this, not you
void Init_dhunruby();

// Prototype for our method 'test1' - methods are prefixed by 'method_' here
VALUE method_test1(VALUE self);

// The initialization method for this module
void Init_dhunruby() {
  DhunRuby = rb_define_module("DhunRuby");
  rb_define_method(DhunRuby, "test1", method_test1, 0);
}

// Our 'test1' method.. it simply returns a value of '10' for now.
VALUE method_test1(VALUE self) {
  printf("DhunRuby!");
  int x = 10;
  return INT2NUM(x);
}
