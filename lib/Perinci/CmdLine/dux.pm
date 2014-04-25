package Perinci::CmdLine::dux;
use 5.010;
use Moo;
extends 'Perinci::CmdLine';

our $VERSION = '1.43'; # VERSION
our $DATE = '2014-04-25'; # DATE

# we don't have our own color theme class
sub color_theme_class_prefix { 'Perinci::CmdLine::ColorTheme' }

sub run_call {
    my $self = shift;

    binmode(STDOUT, ":utf8");

    # set `in` argument for the dux function
    my $chomp = $self->{_meta}{"x.app.dux.strip_newlines"} //
        $self->{_meta}{"x.dux.strip_newlines"} // # backward-compat, will be removed someday
            1;
    require Tie::Diamond;
    tie my(@diamond), 'Tie::Diamond', {chomp=>$chomp, utf8=>1} or die;
    $self->{_args}{in}  = \@diamond;

    # set `out` argument for the dux function
    my $streamo = $self->{_meta}{"x.app.dux.is_stream_output"} //
        $self->{_meta}{"x.dux.is_stream_output"}; # backward-compat, will be removed someday
    my $fmt = $self->format;
    if (!defined($streamo)) {
        # turn on streaming if format is simple text
        my $iactive;
        if (-t STDOUT) {
            $iactive = 1;
        } elsif ($ENV{INTERACTIVE}) {
            $iactive = 1;
        } elsif (defined($ENV{INTERACTIVE}) && !$ENV{INTERACTIVE}) {
            $iactive = 0;
        }
        $streamo = 1 if $fmt eq 'text-simple' || $fmt eq 'text' && !$iactive;
    }
    #say "fmt=$fmt, streamo=$streamo";
    if ($streamo) {
        die "Can't format stream as $fmt, please use --format text-simple\n"
            unless $self->format =~ /^text/;
        $self->{_is_stream_output} = 1;
        require Tie::Simple;
        my @out;
        tie @out, "Tie::Simple", undef,
            PUSH => sub {
                my $data = shift;
                for (@_) {
                    print $self->format_row($_);
                }
            };
        $self->{_args}{out} = \@out;
    } else {
        $self->{_args}{out} = [];
    }

    $self->{_args}{-dux_cli} = 1;

    $self->SUPER::run_call(@_);
}

sub format_result {
    my $self = shift;

    if ($self->{_is_stream_output}) {
        $self->{_fres} = "";
        return;
    }

    if ($self->{_res} && $self->{_res}[0] == 200) {
        # insert out to result, so it can be displayed
        $self->{_res}[2] = $self->{_args}{out};
    }
    $self->SUPER::format_result(@_);
}

1;
# ABSTRACT: Perinci::CmdLine subclass for dux cli

__END__

=pod

=encoding UTF-8

=head1 NAME

Perinci::CmdLine::dux - Perinci::CmdLine subclass for dux cli

=head1 VERSION

version 1.43

=head1 RELEASE DATE

2014-04-25

=head1 DESCRIPTION

This subclass sets C<in> and C<out> arguments for the dux function, and displays
the resulting <out> array.

It also add a special flag function argument C<< -dux_cli => 1 >> so the
function is aware it is being run through the dux CLI application.

=for Pod::Coverage .+

=head1 SEE ALSO

L<Perinci::CmdLine>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/App-dux>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-App-dux>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=App-dux>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
