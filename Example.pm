package Pod::Example;

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Module::Info;
use Pod::Abstract;
use Readonly;

# Constants.
Readonly::Array our @EXPORT_OK => qw(get);
Readonly::Scalar my $EMPTY_STR => q{};

# Version.
our $VERSION = 0.01;

# Get content for file or module.
sub get {
	my ($file_or_module, $section, $number_of_example) = @_;

	# Module file.
	my $file;
	if (-r $file_or_module) {
		$file = $file_or_module;

	# Module.
	} else {
		$file = Module::Info->new_from_module($file_or_module)->file;
	}

	# Get pod.
	my $pod_abstract = Pod::Abstract->load_file($file);

	# Get section pod.
	my ($code) = _get_content($pod_abstract, $section, $number_of_example);

	return $code;
}

# Get content in Pod::Abstract object.
sub _get_content {
	my ($pod_abstract, $section, $number_of_example) = @_;

	# Default section.
	if (! $section) {
		$section = 'EXAMPLE';
	}

	# Concerete number of example.
	if ($number_of_example) {
		$section .= $number_of_example;

	# Number of example as potential number.
	} else {
		$section .= '\d*';
	}

	# Get first section.
	my ($pod_section) = $pod_abstract->select('/head1[@heading =~ {'.
		$section.'}]');

	# No section.
	if (! defined $pod_section) {
		return;
	}

	# Remove #cut.
	my @cut = $pod_section->select("//#cut");
	foreach my $cut (@cut) {
		$cut->detach;
	}

	# Get pod.
	my @child = $pod_section->children;
	my $child_pod = join '', map { $_->pod } @child;

	# Remove spaces and return.
	return _remove_spaces($child_pod);
}

# Remove spaces from example.
sub _remove_spaces {
	my $string = shift;
	my @lines = split /\n/, $string;

	# Get number of spaces in begin.
	my $max = 0;
	foreach my $line (@lines) {
		if (! length $line) {
			next;
		}
		$line =~ m/^(\ +)/ms;
		my $spaces = $EMPTY_STR;
		if ($1) {
			$spaces = $1;
		}
		if ($max == 0 || length $spaces < $max) {
			$max = length $spaces;
		}
	}

	# Remove spaces.
	if ($max > 0) {
		foreach my $line (@lines) {
			if (! length $line) {
				next;
			}
			$line = substr $line, $max;
		}
	}

	# Return string.
	return join "\n", @lines;
}

1;


__END__

=pod

=encoding utf8

=head1 NAME

Pod::Example - Module for getting example from POD.

=head1 SYNOPSIS

 use Pod::Example;
 my $obj = Pod::Example->new(%parameters);
 my $example = $obj->get($file_or_module[, $section[, $number_of_example]]);

=head1 SUBROUTINEs

=over 8

=item C<get($file_or_module[, $section[, $number_of_example]])>

 Returns code of example.
 $file_or_module - File with pod doc or perl module.
 $section - Pod section with example. Default value is 'EXAMPLE'.
 $number_of_example - Number of example. Default value is first example.

=back

=head1 ERRORS

 None.

=head1 EXAMPLE

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Pod::Example qw(get);

 # Get and print code.
 print get('Pod::Example')."\n";

 # Output:
 # This example.

=head1 DEPENDENCIES

L<Module::Info(3pm)>,
L<Pod::Abstract(3pm)>,
L<Readonly(3pm)>.

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.01

=cut
