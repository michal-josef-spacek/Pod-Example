# Pragmas.
use strict;
use warnings;

# Modules.
use Pod::Example qw(get);
use English qw(-no_match_vars);
use File::Object;
use Test::More 'tests' => 4;

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
is($ret, $right_ret, 'Example with simple print().');

# Test.
$ret = get($modules_dir->file('Ex2.pm')->s);
is($ret, $right_ret, 'Example as EXAMPLE1.');

# Test.
$ret = get($modules_dir->file('Ex2.pm')->s, 1);
is($ret, $right_ret, 'Example as EXAMPLE1 with explicit example number.');

# Test.
$ret = get($modules_dir->file('Ex2.pm')->s, 2);
$right_ret = <<'END';
# Pragmas.
use strict;
use warnings;

# Print.
print "Bar.\n";
END
chomp $right_ret;
is($ret, $right_ret, 'Example as EXAMPLE2 with explicit example number.');
