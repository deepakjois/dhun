# Loads mkmf which is used to make makefiles for Ruby extensions
require 'mkmf'

# Give it a name
extension_name = 'dhunruby'

# The destination
dir_config(extension_name)

$LDFLAGS << "-framework AudioToolbox -framework CoreServices"
$CFLAGS << "-std=c99"
# Do the work
create_makefile(extension_name)
