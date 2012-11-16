package HTTP::Headers::Patch::DontUseStorable;

use 5.010001;
use strict;
no warnings;
#use Log::Any '$log';

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

# VERSION

our %config;

# the version not using Storable's dclone
my $p_clone = sub {
    my $self = shift;
    my $clone = HTTP::Headers->new;
    $self->scan(sub { $clone->push_header(@_);} );
    $clone;
};

sub patch_data {
    return {
        v => 3,
        patches => [
            {
                action => 'replace',
                mod_version => qr/^6\.0.+/,
                sub_name => 'clone',
                code => $p_clone,
            },
        ],
    };
}

1;
# ABSTRACT: Do not use Storable

=head1 SYNOPSIS

 use HTTP::Headers::Patch::DontUseStorable;


=head1 DESCRIPTION

HTTP::Headers (6.06) tries to load L<Storable> (2.39) and use its dclone()
method. As of this writing, Storable still does not support serializing Regexp
objects, so HTTP::Headers/L<HTTP::Message> croaks when fed data with Regexp
objects.

This patch avoids using Storable and clone using the alternative method.


=head1 FAQ


=head1 SEE ALSO

=cut
