package Mite::Project;

use Mouse;
use Method::Signatures;

use Mite::Class;

has classes =>
  is            => 'ro',
  isa           => 'HashRef[Mite::Class]',
  default       => sub { {} };

method class(:$class=caller(), :$file=(caller)[1]) {
    return $self->classes->{$class} ||= Mite::Class->new(
        name    => $class,
        file    => $file,
    );
}

# Get/set the default Mite project
method default($class: $new_default?) {
    return $class->projects("Default" => $new_default);
}

# Get/set the named project
method projects($class: $name, $project?) {
    state $projects = {};

    return $projects{$name} ||= $project ? $project : $class->new;
}

method inject_mite_functions(:$class, :$file) {
    my $class = $self->class(
        class           => $class,
        file            => $file,
    );

    no strict 'refs';
    *{ $class .'::has' } = func( $name, %args ) {
        my $name = shift;

        require Mite::Attribute;
        my $attribute = Mite::Attribute->new(
            name => $name,
            %args
        );

        $class->add_attribute($attribute);

        return;
    };

    *{ $class .'::extends' } = func(@classes) {
        $class->extends(\@classes);

        return;
    };

    return;
}

method compile() {
    for my $class (values $self->classes) {
        $class->write_mite;
    }

    return;
};

1;
