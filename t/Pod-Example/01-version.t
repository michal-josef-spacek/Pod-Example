# Pragmas.
use strict;
use warnings;

# Modules.
use Pod::Example;
use Test::More 'tests' => 1;

# Test.
is($Pod::Example::VERSION, 0.02, 'Version.');
