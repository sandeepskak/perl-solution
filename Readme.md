Problem:

	Using the Perl API on the latest human data for Ensembl release 104, convert coordinates on chromosome 10, from 25.000 to 30.000 to the same region in GRCh37.

Solution:
	Use the CoordinateConverter.pl script 

Alternatives:
	1. Use the converter available here: http://www.ensembl.org/Homo_sapiens/Tools/AssemblyConverter
	2. Use the instructions described in the following REST API: https://grch37.rest.ensembl.org/documentation/info/assembly_map

Prerequisites:

Make sure to check which pre-installed version of Perl exists on you target machine.
Most Unix/Linux flavours come with it in-built.

You can check if it exists by running:
	`perl --version`

In order to run the script, the version of Perl must be between 5.14 through to 5.26.

If there is a mismatch, use the following link to install: https://help.dreamhost.com/hc/en-us/articles/360028572351-Installing-a-custom-version-of-Perl-locally


Follow the instructions as described in this link: http://asia.ensembl.org/info/docs/api/api_installation.html to setup the PERL API.
	This will setup the API along with Perl that is needed in order to execute the script

Steps to execute:

CoordinateConverter.pl --file=filename

    --file / -f     Name of file containing a list of slices to map to
                    the most recent assembly.  The format should be as follows:

                      coord_system:version:seq_region_name:start:end:strand

                    For example:

                      chromosome:GRCh37:10:25000:30000:1

    --help    / -h  To see this text.


Additional dependencies that had to be installed:
	`apt install mysql-server
	apt-get install -y perlbrew
	perl -MCPAN -e 'install Devel::Trace' - For tracing
	apt-get install libdbi-perl
	apt-get install libdbd-mysql-perl`

