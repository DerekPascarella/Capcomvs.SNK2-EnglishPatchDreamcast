#!/usr/bin/perl
#
# update_file_table.pl
# File table updater for "Capcom vs. SNK 2" on the SEGA Dreamcast.
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use utf8;
use strict;

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Store paths to input/output files.
my $file_table = "FILE_TABLE.BIN";
my $file_table_new = "FILE_TABLE_NEW.BIN";
my $game_executable = "../gdi_testing/gdi_extracted/1ST_READ.BIN";
my $game_files = "../gdi_testing/gdi_extracted/";

# Store position of file table in game executable (0x182DF4).
my $table_position = 1584628;

# Store size of each entry (20 bytes).
my $entry_size = 20;

# Store number of files indexed in table.
my $file_count = 623;

# Store file table data.
my $file_table_data = uc(&read_bytes($file_table));

# Initialize file-size update count to zero.
my $update_count = 0;

# Status message.
print "\n\"Capcom vs. SNK 2\" file table updater for the SEGA Dreamcast.\n";
print "Written by Derek Pascarella (ateam)\n\n";
print "Parsing data...\n";

# Iterate through each file entry.
for(my $i = 0; $i < $file_count; $i ++)
{
	# Store file entry data.
	my $file_data = substr($file_table_data, $i * $entry_size * 2, $entry_size * 2);

	# Store file size.
	my $file_size = hex(&endian_swap(substr($file_data, 0, 8)));

	# Store file name.
	my $file_name = substr($file_data, 8, 32);
	$file_name =~ s/00+$//;
	$file_name = pack('H*', $file_name);

	# Store size of the actual file.
	my $file_size_current = -s $game_files . "/" . $file_name;

	# Store modification attributes for current file.
	my $modified_time = (stat($game_files . "/" . $file_name))[9];
	my $modified_year = (localtime($modified_time))[5] + 1900;

	# File has been modified for the patch, and also exceeds its allotted space per file table.
	if($file_size_current > $file_size && $modified_year >= 2024)
	{
		# Status message.
		print "\n" . $file_name . " - " . $file_size_current . " bytes (" . $file_size . " currently in table)\n";

		# Increase update count by one.
		$update_count ++;

		# Construct new file entry.
		my $file_data_new = $file_data;
		substr($file_data_new, 0, 8, &endian_swap(&decimal_to_hex($file_size_current, 4)));
		$file_table_data =~ s/$file_data/$file_data_new/g;
	}
}

# Write new file table data to file.
&write_bytes($file_table_new, $file_table_data);

# Patch game executable with new table data.
&patch_bytes($game_executable, $file_table_data, $table_position);

# Status message.
print "\nComplete!\n\n";
print $update_count . " file size entries updated.\n\n";
print "Data written to file \"" . $game_executable . "\".\n\n";

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

# Subroutine to write a sequence of hexadecimal values at a specified offset (in decimal format) into
# a specified file, as to patch the existing data at that offset.
#
# 1st parameter - Full path of file in which to insert patch data.
# 2nd parameter - Hexadecimal representation of data to be inserted.
# 3rd parameter - Offset at which to patch.
sub patch_bytes
{
	my $output_file = $_[0];
	(my $hex_data = $_[1]) =~ s/\s+//g;
	my @hex_data_array = split(//, $hex_data);
	my $patch_offset = $_[2];

	if((stat $output_file)[7] < $patch_offset + (scalar(@hex_data_array) / 2))
	{
		die "Offset for patch_bytes is outside of valid range.\n";
	}

	open my $filehandle, '+<:raw', $output_file or die $!;
	binmode $filehandle;
	seek $filehandle, $patch_offset, 0;

	for(my $i = 0; $i < scalar(@hex_data_array); $i += 2)
	{
		my($high, $low) = @hex_data_array[$i, $i + 1];
		print $filehandle pack "H*", $high . $low;
	}

	close $filehandle;
}