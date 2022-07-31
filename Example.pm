package Pod::Example;

use base qw(Exporter);
use strict;
use warnings;

use Error::Pure qw(err);
use Pod::Abstract;
use Pod::Find qw(pod_where);
use Readonly;

# Constants.
Readonly::Array our @EXPORT_OK => qw(get sections);
Readonly::Scalar my $EMPTY_STR => q{};

our $VERSION = 0.12;

# Get content for file or module.
sub get {
	my ($file_or_module, $section, $number_of_example) = @_;

	# Get Pod::Abstract object.
	my $pod_abstract = _pod_abstract($file_or_module);

	# Get section pod.
	my ($code, $example_filename) = _get_content($pod_abstract, $section, $number_of_example);

	return wantarray ? ($code, $example_filename) : $code;
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
	my $child_pod = $EMPTY_STR;
	my $example_filename;
	foreach my $child ($pod_section->children) {
		if ($child->type eq 'begin') {

			# =begin text as commented text.
			if ($child->body =~ m/^text/ms) {
				$child_pod .= join "\n",
					map { ' #'.$_ }
					split m/\n/ms,
					($child->children)[0]->pod;

			# Skip =begin html and other unsupported sections.
			} else {
				next;
			}
		} elsif ($child->type eq 'for') {
			my $body = $child->body;
			if ($body =~ m/^comment\s*filename=([\w\.]+)\s*$/ms) {
				$example_filename = $1;
			}
		} else {
			$child_pod .= $child->pod;
		}
	}

	# Remove spaces and return.
	my $ret = _remove_spaces($child_pod);

	return wantarray ? ($ret, $example_filename) : $ret;
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
		$file = pod_where({ -inc => 1 }, $file_or_module);
		if (! $file) {
			err 'Cannot open pod file or Perl module.';
		}
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
 my ($example, $filename) = get($file_or_module[, $section[, $number_of_example]]);
 my @sections = sections($file_or_module[, $section]);

=head1 SUBROUTINES

=head2 C<get>

 my $example = get($file_or_module[, $section[, $number_of_example]]);
 my ($example, $filename) = get($file_or_module[, $section[, $number_of_example]]);

Get content of example. If detect POD comment with filename=FILENAME returns
filename string. It's useful for generating of examples from documentation.

Returns code of example in scalar mode.

Returns list with code of example and filename (if possible) in array mode.

 $file_or_module    - File with pod doc or perl module.
 $section           - Pod section with example. Default value is 'EXAMPLE'.
 $number_of_example - Number of example. If exists 'EXAMPLE1' and 'EXAMPLE2'
                      sections, then this number can be '1' or '2'.
                      Default value is nothing.

=head2 C<sections>

 my @sections = sections($file_or_module[, $section]);

Returns array of example sections.

 $file_or_module - File with pod doc or perl module.
 $section - Pod section with example. Default value is 'EXAMPLE'.

=head1 ERRORS

 get():
         Cannot open pod file or Perl module.

 sections():
         Cannot open pod file or Perl module.

=head1 EXAMPLE1

 use strict;
 use warnings;

 use Pod::Example qw(get);

 # Get and print code.
 print get('Pod::Example')."\n";

 # Output:
 # This example.

=head1 EXAMPLE2

 use strict;
 use warnings;

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
L<Pod::Abstract>,
L<Pod::Find>,
L<Readonly>.

=head1 SEE ALSO

=over

=item L<pod-example>

Script to print or run of example from documentation.

=item L<App::Pod::Example>

Base class for pod-example script.

=back

=head1 REPOSITORY

L<https://github.com/michal-josef-spacek/Pod-Example>

=head1 AUTHOR

Michal Josef Špaček L<mailto:skim@cpan.org>

L<http://skim.cz>

=head1 LICENSE AND COPYRIGHT

© 2011-2022 Michal Josef Špaček

BSD 2-Clause License

=head1 VERSION

0.12

=cut
