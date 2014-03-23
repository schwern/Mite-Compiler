package Mite::Class;

use v5.10;
use Mouse;
use Mouse::Util::TypeConstraints;
use Method::Signatures;
use Path::Tiny;
use Carp;

class_type "Path::Tiny";

has attributes =>
  is            => 'rw',
  isa           => 'HashRef[Mite::Attribute]',
  default       => sub { {} };

has extends =>
  is            => 'rw',
  isa           => 'ArrayRef',
  default       => sub { [] };

has name =>
  is            => 'rw',
  isa           => 'Str',
  required      => 1;

has file =>
  is            => 'rw',
  isa           => 'Str|Path::Tiny',
  required      => 1;

has mite_file =>
  is            => 'rw',
  isa           => 'Str|Path::Tiny',
  default       => method {
      my $file = $self->file;
      my $mite_file = $file;

      # Ensure it always has a .mite on the end no matter what
      $mite_file =~ s{\.[^\.]*$}{};
      $mite_file .= '.mite';

      croak("The mite file is the same as the file ($file)") if $file eq $mite_file;

      return $mite_file;
  };

method write_mite() {
    my $file = path $self->mite_file;
    $file->spew_utf8( $self->compile );

    return;
}

method delete_mite() {
    my $file = $self->mite_file;

    # Kill the file dead on VMS
    1 while unlink $file;
}

method add_attributes(Mite::Attribute @attributes) {
    for my $attribute (@attributes) {
        $self->attributes->{ $attribute->name } = $attribute;
    }

    return;
}
{
    no warnings 'once';
    *add_attribute = \&add_attributes;
}

method compile() {
    return join "\n", '{',
                      $self->_compile_package,
                      $self->_compile_pragmas,
                      $self->_compile_extends,
                      $self->_compile_new,
                      $self->_compile_attributes,
                      '1;',
                      '}';
}

method _compile_package {
    return "package @{[ $self->name ]};";
}

method _compile_pragmas {
    return <<'CODE';
use strict;
use warnings;
CODE
}

method _compile_extends() {
    my $parents = $self->extends;
    return '' unless @$parents;

    my $require_list = join "\n\t", map { "require $_;" } @$parents;
    my $isa_list     = join ", ", map { "q[$_]" } @$parents;

    return <<"END";
BEGIN {
    $require_list

    our \@ISA;
    push \@ISA, $isa_list;
}
END
}

method _compile_new() {
    return sprintf <<'CODE', $self->_compile_defaults;
sub new {
    my $class = shift;
    my %%args  = @_;

    my $self = bless \%%args, $class;

    %s

    return $self;
}
CODE
}

method _compile_simple_default($attribute) {
    return sprintf '$self->{%s} //= q[%s];', $attribute->name, $attribute->default;
}

method _compile_coderef_default($attribute) {
    my $var = $attribute->coderef_default_variable;

    return sprintf 'our %s; $self->{%s} //= %s->(\$self);',
      $var, $attribute->name, $var;
}

method _compile_defaults {
    my @simple_defaults = map { $self->_compile_simple_default($_) }
                              $self->_attributes_with_simple_defaults;
    my @coderef_defaults = map { $self->_compile_coderef_default($_) }
                               $self->_attributes_with_coderef_defaults;

    return join "\n", @simple_defaults, @coderef_defaults;
}

method _attributes_with_defaults() {
    return grep { $_->has_default } values %{$self->attributes};
}

method _attributes_with_simple_defaults() {
    return grep { $_->has_simple_default } values %{$self->attributes};
}

method _attributes_with_coderef_defaults() {
    return grep { $_->has_coderef_default } values %{$self->attributes};
}

method _attributes_with_dataref_defaults() {
    return grep { $_->has_dataref_default } values %{$self->attributes};
}

method _compile_attributes() {
    my $code = '';
    for my $attribute (values %{$self->attributes}) {
        $code .= $attribute->compile;
    }

    return $code;
}

1;