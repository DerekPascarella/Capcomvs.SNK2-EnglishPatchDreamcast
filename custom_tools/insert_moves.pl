#!/usr/bin/perl
#
# extract_moves.pl
# Command list (special moves) rebuilder for "Capcom vs. SNK 2" on the SEGA Dreamcast.
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use utf8;
use strict;
use Encode;
use File::Copy;

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Set input files.
my $moves_file = "moves_extracted_translated.txt";
my $executable_file = "../gdi_extracted/1ST_READ.BIN";

# Set output files.
my $output_file_exec = "1ST_READ.BIN";

# Read and store entire game executable.
my $executable_data = &read_bytes($executable_file);

# Declare empty string to hold byte array of all new move data.
my $move_data = "";

# Read moves text file into array.
my @moves_file_contents = &read_file($moves_file);

# Set start address in Dreamcast's RAM for beginning of move data in 1ST_READ.BIN (0x1A5260).
my $overwrite_location = 1725024;

# Store capacity (in bytes) of new move data.
my $overwrite_location_capacity = 16384;

# Set offset at which move data should be written in 1ST_READ.BIN (0x8C1B5260).
my $start_address = 2350600800;

# Initialize current address, used for calculating each section, to start address.
my $current_address = $start_address;

# Declare empty hash to store new pointers to be updated at one or more locations.
my %pointer_locations;

# Status message.
print "\n\"Capcom vs. SNK 2\" command list inserter for the SEGA Dreamcast.\n";
print "Written by Derek Pascarella (ateam)\n\n";
print "Parsing data and pointers...\n\n";

# Iterate through and process each line of the moves text file.
for(my $i = 0; $i < scalar(@moves_file_contents); $i ++)
{
	# Declare empty string to hold byte array of current section. 
	my $section_data = "";

	# Current line starts a new section with a pointer.
	if($moves_file_contents[$i] =~ /^---POINTER/)
	{
		# Extract original pointer and its location.
		my ($pointer_original) = $moves_file_contents[$i] =~ /POINTER:\s*([0-9A-Fa-f]+)\s*LOCATIONS:/;
		my ($locations) = $moves_file_contents[$i] =~ /LOCATIONS:\s*([\d,\s]+)/;
		my @locations = split(/\s*,\s*/, $locations);

		# Status message.
		print "Line Number:\t\t" . $i . "\n";
		print "Original Pointer:\t" . $pointer_original . "\n";
		print "Location(s):\t\t" . join(", ", @locations) . "\n";

		# Skip ahead one line.
		$i ++;
		
		# Read subsequent lines until next pointer is encountered.
		while($moves_file_contents[$i] !~ /^---POINTER/ && $i < scalar(@moves_file_contents))
		{
			# Store each character in current line into element of an array.
			my @characters = split(//, $moves_file_contents[$i]);

			# Iterate through and process each character.
			for(my $j = 0; $j < scalar(@characters); $j ++)
			{
				# Control code chunk found.
				if($characters[$j] eq "{")
				{
					# Skip ahead one character.
					$j ++;

					# Seek until control code end found.
					while($characters[$j] ne "}")
					{
						# Append character as raw hex data.
						$section_data .= $characters[$j];

						# Skip ahead one character.
						$j ++;
					}
				}
				# Text character found.
				else
				{
					# Append one-byte ASCII or two-byte Shift-JIS.
					$section_data .= unpack('H*', encode('Shift-JIS', $characters[$j]));
				}
			}

			# Skip ahead one line.
			$i ++;
		}

		# Apply null padding to section for four-byte alignment.
		$section_data .= "00";

		while(length($section_data) % 8 != 0)
		{
			$section_data .= "00";
		}

		# Append section to move data.
		$move_data .= $section_data;

		# Go back one line for next loop iteration.
		$i --;

		# Calculate new pointer.
		my $pointer_new = &decimal_to_hex($current_address);
		my $pointer_new_le = &endian_swap($pointer_new);

		# Status message.
		print "New Pointer:\t\t" . $pointer_new . "\n\n";

		# Update current address after adding curent section data.
		$current_address += (length($section_data) / 2);

		# Add key to hash for new pointer at each found location.
		foreach(@locations)
		{
			$pointer_locations{$_} = $pointer_new_le;
		}
	}
}

# Write new move data itself to individual file for inspection purposes.
&write_bytes("moves_new.bin", $move_data);

# Status message.
print "Nulling out region to hold new move data...\n\n";

# Null out region where new move data will be written.
substr($executable_data, $overwrite_location * 2, $overwrite_location_capacity * 2, "00" x $overwrite_location_capacity);

# Status message.
print "Patching new move data...\n\n";

# Throw error message if new move data exceeds available space.
if(length($move_data) > $overwrite_location_capacity * 2)
{
	print "ERROR: New move data exceeds " . $overwrite_location_capacity . " bytes!\n";
	print "       Total size is " . (length($move_data) / 2) . " bytes.\n";
	<STDIN>;
	exit;
}

# Patch new move data.
substr($executable_data, $overwrite_location * 2, length($move_data), $move_data);

# Status message.
print "Updating pointers...\n\n";

# Patch game executable with updated pointers.
my $pointer_replacement_count = 0;

for my $location (sort {$a <=> $b} keys %pointer_locations)
{
	substr($executable_data, $location * 2, 8, $pointer_locations{$location});

	$pointer_replacement_count ++;
}

&write_bytes($output_file_exec, $executable_data);

# Status message.
print "Complete!\n\n";
print $pointer_replacement_count . " pointers updated.\n\n";
print "New move data is " . (length($move_data) / 2) . " bytes.\n\n";

# Subroutine to return hexadecimal representation of a decimal number.
#
# 1st parameter - Decimal number.
# 2nd parameter - Number of bytes with which to represent hexadecimal number (omit parameter for no
#                 padding).
sub decimal_to_hex
{
	if($_[1] eq "")
	{
		$_[1] = 0;
	}

	return sprintf("%0" . $_[1] * 2 . "X", $_[0]);
}

# Subroutine to swap between big/little endian by reversing order of bytes from specified hexadecimal
# data.
#
# 1st parameter - Hexadecimal representation of data.
sub endian_swap
{
	(my $hex_data = $_[0]) =~ s/\s+//g;
	my @hex_data_array = ($hex_data =~ m/../g);

	return join("", reverse(@hex_data_array));
}

# Subroutine to read a specified number of bytes (starting at the beginning) of a specified file,
# returning hexadecimal representation of data.
#
# 1st parameter - Full path of file to read.
# 2nd parameter - Number of bytes to read (omit parameter to read entire file).
sub read_bytes
{
	my $input_file = $_[0];
	my $byte_count = $_[1];

	if($byte_count eq "")
	{
		$byte_count = (stat $input_file)[7];
	}

	open my $filehandle, '<:raw', $input_file or die $!;
	read $filehandle, my $bytes, $byte_count;
	close $filehandle;
	
	return unpack 'H*', $bytes;
}

# Subroutine to write a sequence of hexadecimal values to a specified file.
#
# 1st parameter - Full path of file to write.
# 2nd parameter - Hexadecimal representation of data to be written to file.
sub write_bytes
{
	my $output_file = $_[0];
	(my $hex_data = $_[1]) =~ s/\s+//g;
	my @hex_data_array = split(//, $hex_data);

	open my $filehandle, '>:raw', $output_file or die $!;
	binmode $filehandle;

	for(my $i = 0; $i < scalar(@hex_data_array); $i += 2)
	{
		my($high, $low) = @hex_data_array[$i, $i + 1];
		print $filehandle pack "H*", $high . $low;
	}

	close $filehandle;
}

# A subroutine to read a text file into an array.
#
# 1st parameter - Full path of file to read.
sub read_file
{
	my $input_file = $_[0];
	my @lines;

	open my $filehandle, "<:encoding(UTF-8)", $input_file or die $!;
	
	while(my $line = <$filehandle>)
	{
		chomp $line;
		push(@lines, $line);
	}

	close $filehandle;

	return @lines;
}