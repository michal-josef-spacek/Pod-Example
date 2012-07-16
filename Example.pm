package Pod::Example;

# Pragmas.
use base qw(Exporter);
use strict;
use warnings;

# Modules.
use Error::Pure qw(err);
use Module::Info;
use Pod::Abstract;
use Readonly;

# Constants.
Readonly::Array our @EXPORT_OK => qw(get sections);
Readonly::Scalar my $EMPTY_STR => q{};

# Version.
our $VERSION = 0.04;

# Get content for file or module.
sub get {
	my ($file_or_module, $section, $number_of_example) = @_;

	# Get Pod::Abstract object.
	my $pod_abstract = _pod_abstract($file_or_module);

	# Get section pod.
	my ($code) = _get_content($pod_abstract, $section, $number_of_example);

	return $code;
}

# Get example sections.
sub sections {
	my ($file_or_module, $section) = @_;

	# Get Pod::Abstract object.
	my $pod_abstract = _pod_abstract($file_or_module);

	# Get first section.
	my @pod_sections = _get_sections($pod_abstract, $section);

	# Get section names.
	my @sections = map { _get_section_name($_) } @pod_sections;

	return @sections;
}

# Get content in Pod::Abstract object.
sub _get_content {
	my ($pod_abstract, $section, $number_of_example) = @_;

	# Get first section.
	my ($pod_section) = _get_sections($pod_abstract, $section,
		$number_of_example);

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

# Get section name.
# XXX Hack to structure.
sub _get_section_name {
	my $pod_abstract_node = shift;
	return $pod_abstract_node->{'params'}->{'heading'}->{'tree'}
		->{'nodes'}->[0]->{'body'};
}

# Get sections.
sub _get_sections {
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

	# Get and return sections.
	return $pod_abstract->select('/head1[@heading =~ {'.$section.'}]');
}

# Get pod abstract for module.
sub _pod_abstract {
	my $file_or_module = shift;

	# Module file.
	my $file;
	if (-r $file_or_module) {
		$file = $file_or_module;

	# Module.
	} else {
		my $mod = Module::Info->new_from_module($file_or_module);
		if (! $mod) {
			err 'Cannot open pod file or Perl module.';
		}
		$file = $mod->file;
	}

	# Get and return pod.
	return Pod::Abstract->load_file($file);
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

 use Pod::Example qw(get sections);
 my $example = get($file_or_module[, $section[, $number_of_example]]);
 my @sections = sections($file_or_module[, $section]);

=head1 SUBROUTINES

=over 8

=item C<get($file_or_module[, $section[, $number_of_example]])>

 Returns code of example.
 $file_or_module - File with pod doc or perl module.
 $section - Pod section with example. Default value is 'EXAMPLE'.
 $number_of_example - Number of example. Default value is first example.

=item C<sections($file_or_module[, $section])>

 Returns array of example sections.
 $file_or_module - File with pod doc or perl module.
 $section - Pod section with example. Default value is 'EXAMPLE'.

=back

=head1 ERRORS

 Mine:
         Cannot open pod file or Perl module.

=head1 EXAMPLE1

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Pod::Example qw(get);

 # Get and print code.
 print get('Pod::Example')."\n";

 # Output:
 # This example.

=head1 EXAMPLE2

 # Pragmas.
 use strict;
 use warnings;

 # Modules.
 use Pod::Example qw(sections);

 # Get and print code.
 print join "\n", sections('Pod::Example');
 print "\n";

 # Output:
 # EXAMPLE1
 # EXAMPLE2

=head1 DEPENDENCIES

L<Error::Pure>,
L<Exporter>,
L<Module::Info>,
L<Pod::Abstract>,
L<Readonly>.

=head1 REPOSITORY

L<https://github.com/tupinek/Pod-Example>

=head1 AUTHOR

Michal Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

BSD license.

=head1 VERSION

0.04

=cut
