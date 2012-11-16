package HTTP::Headers::Patch::DontUseStorable;

use 5.010001;
use strict;
no warnings;
#use Log::Any '$log';

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

# VERSION

our %config;

sub _clone($) {
    my $self = shift;
    my $clone = HTTP::Headers->new;
    $self->scan(sub { $clone->push_header(@_);} );
    $clone;
}

sub patch_data {
    return {
        v => 3,
        patches => [
            {
                action => 'replace',
                mod_version => qr/^6\.0.+/,
                sub_name => 'clone',
                code => \&_clone,
            },
        ],
    };
}

1;
# ABSTRACT: Do not use Storable

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

 use HTTP::Headers::Patch::DontUseStorable;


=head1 DESCRIPTION

HTTP::Headers (6.05 as of this writing) tries to load L<Storable> (2.39 as of
this writing) and use its dclone() method. Since Storable still does not support
serializing Regexp objects, HTTP::Headers/L<HTTP::Message> croaks when fed data
with Regexp objects.

This patch avoids using Storable and clone using the alternative method.


=head1 FAQ


=head1 SEE ALSO

=cut
