package HTTP::Headers::Patch::DontUseStorable;

# AUTHORITY
# DATE
# DIST
# VERSION

use 5.010001;
use strict;
no warnings;

use Module::Patch ();
use base qw(Module::Patch);

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
                mod_version => qr/^6\.[01].+/,
                sub_name => 'clone',
                code => \&_clone,
            },
        ],
    };
}

1;
# ABSTRACT: (DEPRECATED) Do not use Storable

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

 use HTTP::Headers::Patch::DontUseStorable;


=head1 DESCRIPTION

B<UPDATE 2020-02-03:> As of Storable 3.08, freeze/thaw/dclone support Regexp
objects. I'm deprecating this module.

L<HTTP::Headers> (6.11 as of this writing) tries to load L<Storable> (2.56 as of
this writing) and use its dclone() method. Since Storable still does not support
serializing Regexp objects, HTTP::Headers/L<HTTP::Message> croaks when fed data
with Regexp objects.

This patch avoids using Storable and clone using the alternative method.


=head1 FAQ

=head2 Is this a bug with HTTP::Headers? Why don't you submit a bug to HTTP-Message?

I tend not to think this is a bug with HTTP::Headers; after all, Storable's
dclone() is a pretty standard way to clone data in Perl. This patch is more of a
workaround for current Storable's deficiencies.

=head2 Shouldn't you add STORABLE_{freeze,thaw} methods to Regexp instead?

This no longer works with newer Perls (5.12 and later).

=head2 Why would an HTTP::Headers object contain a Regexp object in the first place? Shouldn't it only contain strings (and arrays/hashes of strings)?

True. This might be a bug with the client code (e.g. in my module which uses
this patch, L<Finance::Bank::ID::Mandiri>). I haven't investigated further
though and this is the stop-gap solution.


=head1 SEE ALSO

=cut
