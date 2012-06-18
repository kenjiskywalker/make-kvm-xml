#!/usr/bin/env perl

use strict;
use warnings;

use File::Spec;
use File::Basename;
use lib File::Spec->catdir( dirname(__FILE__), 'local', 'lib', 'perl5' );

use Data::UUID;
use Text::Xslate;

my $tx = Text::Xslate->new( syntax => 'TTerse' );
$tx->load_file('./make-kvm-xml.tt');

my $in_file = './test.csv';

open my $ifh, '<', $in_file
  or die "Can't open file \"$in_file\": $!";

for my $line (<$ifh>) {

    next if $line =~ /^#/ || $line =~ /^$/;

    my ( $name, $cpu, $mem, $img, $vlan, $mac ) = split( /,/, $line );
    my $out_file = "$name.xml";

    chomp($mac);

    my $uuid = Data::UUID->new;
    $uuid = $uuid->create_str();
    $mem  = $mem * 1024 * 1024;

    my %data = (
        NAME  => $name,
        UUID  => $uuid,
        MEM   => $mem,
        CPU   => $cpu,
        IMAGE => $img,
        MAC   => $mac,
        VLAN  => $vlan,
    );

    if ( -e $out_file ) {

        print "allow overrite => $out_file ok? [y/n] : ";

        while ( my $ans = <> ) {
            chomp($ans);
            if ( $ans eq "y" ) {
                open my $ofh, '>', $out_file;
                print $ofh $tx->render( './make-kvm-xml.tt', \%data );
                close($ofh);
		last;
            }
            elsif ( $ans eq "n" ) {
                print "goodbye.\n";
                exit;
            }
            elsif ( $ans ne "y" && $ans ne "n" ) {
	      print "allow overrite => $out_file ok? [y/n] : ";
            }
        }
    }

    open my $ofh, '>', $out_file;
    print $ofh $tx->render( './make-kvm-xml.tt', \%data );
    close($ofh);

}

__END__

=head1 HOW TO USE

Please refer to "test.csv" file.
