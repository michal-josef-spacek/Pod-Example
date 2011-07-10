# Pragmas.
use strict;
use warnings;

# Modules.
use File::Object;
use Pod::Example qw(get);
use Test::More 'tests' => 6;

# Modules dir.
my $modules_dir = File::Object->new->up->dir('modules');

# Test.
my $ret = get($modules_dir->file('Ex1.pm')->s);
my $right_ret = <<'END';
# Pragmas.
use strict;
use warnings;

# Print.
print "Foo.\n";
END
chomp $right_ret;
is($ret, $right_ret, 'Example.');

# Test.
$ret = get($modules_dir->file('Ex1.pm')->s, 'EXAMPLE');
is($ret, $right_ret, 'Example with explicit section.');

# Test.
$ret = get($modules_dir->file('Ex3.pm')->s);
is($ret, $right_ret, 'Example as EXAMPLE1.');

# Test.
$ret = get($modules_dir->file('Ex3.pm')->s, 'EXAMPLE');
is($ret, $right_ret, 'Example as EXAMPLE1 with explicit section.');

# Test.
$ret = get($modules_dir->file('Ex3.pm')->s, 'EXAMPLE', 1);
is($ret, $right_ret, 'Example as EXAMPLE1 with explicit example section '.
	'and number.');

# Test.
$ret = get($modules_dir->file('Ex3.pm')->s, 'EXAMPLE', 2);
$right_ret = <<'END';
# Pragmas.
use strict;
use warnings;

# Print.
print "Bar.\n";
END
chomp $right_ret;
is($ret, $right_ret, 'Example as EXAMPLE2 with explicit example section '.
	'and number.');
