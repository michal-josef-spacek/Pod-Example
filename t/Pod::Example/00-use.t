# Pragmas.
use strict;
use warnings;

# Modules.
use Test::More 'tests' => 2;

BEGIN {

	# Test.
	use_ok('Pod::Example');
}

# Test.
require_ok('Pod::Example');
