# Pragmas.
use strict;
use warnings;

# Modules.
use inc::Module::Install;

# Definition.
abstract 'Module for getting example from POD.';
author 'Michal Špaček <skim@cpan.org>';
license 'bsd';
name 'Pod-Example';
requires 'Exporter' => 0;
requires 'Module::Info' => 0;
requires 'Pod::Abstract' => 0;
requires 'Readonly' => 0;
resources 'repository' => {
	'url' => 'git://github.com/tupinek/Pod-Example',
	'web' => 'https://github.com/tupinek/Pod-Example',
	'type' => 'git',
};
test_requires 'English' => 0;
test_requires 'File::Object' => 0.01;
test_requires 'Test::More' => 0;
test_requires 'Test::Pod' => 0;
test_requires 'Test::Pod::Coverage' => 0;
tests_recursive;
version '0.02';

# Run.
WriteAll();
