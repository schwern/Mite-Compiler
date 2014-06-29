package Mite;

use version; our $VERSION = qv("v0.0.1");

=head1 NAME

Mite - Moose-like OO with no dependencies

=head1 SYNOPSIS

    $ mite init Foo

    $ cat lib/Foo.pm
    package Foo;

    # Load the Mite shim
    use Foo::Mite;

    # Subclass of Bar
    extends "Bar";

    # A read/write string attribute
    has attribute =>
        is      => 'rw';

    # A read-only attribute with a default
    has another_attribute =>
        is      => 'ro',
        default => 1;

    $ mite compile

=head1 DESCRIPTION

L<Moose> and L<Mouse> are great... unless you can't have any
dependencies or compile-time is critical.

Mite provides Moose-like functionality, but it does all the work at
build time.  New source code is written which contains your accessors
and roles.

Mite provides a subset of Moose features.

Mite is for a very narrow set of use cases.  Unless you specifically
need ultra-fast startup time or no dependencies, use L<Moose> or
L<Mouse>.

=head2 How To Use It

=head3 1. Install Mite

Only developers must have Mite installed.  Install it normally from
CPAN.

Do not declare Mite as a dependency.  It is not needed to install your
release.

=head3 2. mite init <Your::Project>

Initialize your project.  Tell it your project name.

This will create a F<.mite> directory and a shim file in F<lib>.

=head3 3. Write your code using your mite shim.

Instead of C<use Mite>, you should C<use Your::Project::Mite>.  The
name of this file will depend on the name of your project.

L<Mite> is a subset of L<Moose>.

=head3 4. C<mite compile> after each change

Mite is "compiled" in that the code must be processed after editing
before you run it.  This is done by running C<mite compile>.  It will
create F<.mite.pm> files for each F<.pm> file in F<lib>.

To make development smoother, we provide utility modules to link Mite
with the normal build process.  See L<Mite::MakeMaker> and
L<Mite::ModuleBuild> for MakeMaker/F<Makefile.PL> and
Module::Build/F<Build.PL> development respectively.

=head3 5. Make sure the F<.mite> directory is not in your MANIFEST.

The F<.mite> directory should not be shipped with your distribution.
Add C<^\.mite$> to your F<MANIFEST.SKIP> file.

=head3 6. Make sure the mite files are in your MANIFEST.

The compiled F<.mite.pm> files must ship with your code, so make sure
they get picked up in your F<MANIFEST> file.  This should happen when
you build the F<MANIFEST> normally.

=head3 7. Ship normally

Build and ship your distribution normally.  It contains everything it
needs.


=head1 FEATURES

L<Mite> is a subset of L<Moose>.  These docs will only describe what
Moose features are implemented or where they differ.  For everything
else, please read L<Moose> and L<Moose::Manual>.

=head2 C<has>

Supports C<is> and C<default>.

As an extension, C<default> supports data references.  There is no
need to wrap them in a code reference.

    has some_list =>
        is      => 'rw',
        default => [];

=head2 C<extends>

Works as in L<Moose>.  Options are not implemented.

=head2 C<strict>

Mite will turn strict on for you.

=head2 C<warnings>

Mite will turn warnings on for you.

=head1 WHY IS THIS

This module exists for a very "special" set of use cases.  Authors of
toolchain modules (Test::More, ExtUtils::MakeMaker, File::Spec,
etc...) who cannot easily depend on other CPAN modules.  It would
cause a circular dependency and add instability to CPAN.  These
authors are frustrated at not being able to use most of the advances
in Perl present on CPAN, such as Moose.

To add to their burden, by being used by almost everyone, toolchain
modules limit how fast modules can load.  So they have to compile very
fast.  They do not have the luxury of creating attributes and
including roles at compile time.  It must be baked in.

Finally, Moose and Mouse both require role users and subclassers to
also be Moose or Mouse classes.  This is a dangerous encapsulation
breach of an implementation detail.  It means the class, and its
subclasses, are stuck using Moose or Mouse forever.


=head1 SEE ALSO

L<Mouse> is a forward-compatible version of Moose with no dependencies.

L<Moose> is the complete Perl 5 OO module which this is all based on.

=cut

1;
