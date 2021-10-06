#!/usr/bin/env perl

# A program to convert coordinates from old assemblies to the latest assembly.

use strict;
use warnings;

use IO::File;
use Getopt::Long;

use Bio::EnsEMBL::Registry;

my ( $filename );
my $help = '';

if ( !GetOptions( 'file|f=s'    => \$filename,
                  'help|h!'     => \$help )
     || !( defined($filename) )
     || $help )
{
  print <<END_USAGE;
Usage:
  $0 --file=filename
  $0 --help
    --help    / -h  To see this text.
Example usage:
  $0 -f slices.txt
END_USAGE

  exit(1);
}

my $registry = 'Bio::EnsEMBL::Registry';

my $host = 'ensembldb.ensembl.org';
my $port = 3306;
my $user = 'anonymous';

$registry->load_registry_from_db( '-host' => $host,
                                  '-port' => $port,
                                  '-user' => $user );

my $slice_adaptor = $registry->get_adaptor( 'human', 'Core', 'Slice' );

my $in = IO::File->new($filename);

if ( !defined($in) ) {
  die( sprintf( "Could not open file '%s' for reading", $filename ) );
}

while ( my $line = $in->getline() ) {
  chomp($line);

  # Remove comments 
  $line =~ s/\s*#.*$//;

  # Skip white space lines
  if ( $line =~ /^\s*$/ ) { next }

  #Trim lines
  $line =~ s/^\s+|\s+$//;

  # Check if location string is in correct format
  my $number_seps_regex = qr/\s+|,/;
  my $separator_regex = qr/(?:-|[.]{2}|\:|_)?/;
  my $number_regex = qr/[0-9, E]+/xms;
  my $strand_regex = qr/[+-1]|-1/xms;

  # Location string has to be chromosome:GRCh37:X:25000:30000:1
  my $regex = qr/^(\w+) $separator_regex (\w+) $separator_regex ((?:\w|\.|_|-)+) \s* :? \s* ($number_regex)? $separator_regex ($number_regex)? $separator_regex ($strand_regex)? $/xms;

  my ( $old_cs_name, $old_version, $old_sr_name, $old_start, $old_end, $old_strand );

  if ( ($old_cs_name, $old_version, $old_sr_name, $old_start, $old_end, $old_strand) = $line =~ $regex) {
  } else {
    printf( "Malformed line:\n%s\n", $line );
    next;
  }

  # Get a slice of the old region
  my $old_slice =
    $slice_adaptor->fetch_by_region(
                                $old_cs_name, $old_sr_name, $old_start,
                                $old_end,     $old_strand,  $old_version
    );

  # Complete missing info.
  $old_cs_name ||= $old_slice->coord_system_name();
  $old_sr_name ||= $old_slice->seq_region_name();
  $old_start   ||= $old_slice->start();
  $old_end     ||= $old_slice->end();
  $old_strand  ||= $old_slice->strand();
  $old_version ||= $old_slice->coord_system()->version();

  printf( "# %s\n", $old_slice->name() );

  # Project the old slice to the current assembly
  foreach my $segment ( @{ $old_slice->project('chromosome') } ) {
    printf( "%s:%s:%s:%d:%d:%d,%s\n",
            $old_cs_name,
            $old_version,
            $old_sr_name,
            $old_start + $segment->from_start() - 1,
            $old_start + $segment->from_end() - 1,
            $old_strand,
            $segment->to_Slice()->name() );
  }
  print("\n");

}