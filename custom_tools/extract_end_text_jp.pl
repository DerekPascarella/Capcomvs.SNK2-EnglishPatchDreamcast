#!/usr/bin/perl
#
# extract_end_text.pl
# End text extractor for "Capcom vs. SNK 2" on the SEGA Dreamcast.
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use utf8;
use strict;
use Spreadsheet::WriteExcel;
use Encode qw(decode encode);

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Set input file.
my $input_file = "../gdi_original_extracted/MESJ_DM.BIN";

# Set output files.
my $output_file = "MESJ_DM.BIN.xls";

# Set text start and end positions (0x13F4 and 0x48EE0, respectively).
my $text_start = 260;
my $text_end = 16892;

# Read and store entirety of win text data.
my $text_data = &read_bytes_at_offset($input_file, $text_end - $text_start, $text_start);

# Read and store entirety of input file.
my $input_data = &read_bytes($input_file);

# Store byte array for text data.
my @text_bytes = ($text_data =~ m/../g);

# Start string count at zero.
my $string_count = 0;

# Start pointer count at zero.
my $pointer_count = 0;

# Declare empty hash for storing string data.
my %strings = ();

# Status message.
print "\n\"Capcom vs. SNK 2\" end text extractor for the SEGA Dreamcast.\n";
print "Written by Derek Pascarella (ateam)\n\n";
print "Parsing data and pointers...\n\n";

# Iterate through each byte of text data to process individual strings.
for(my $i = 0; $i < scalar(@text_bytes); $i ++)
{
	# Increase string count by one.
	$string_count ++;

	# Declare empty byte string used to store current string.
	my $byte_string;

	# Calculate string location.
	my $location = $text_start + $i;

	# Find location of original pointer.
	my $pointer_search = &pointer_exists($input_data, $location);
	
	# Pointer found.
	if($pointer_search != 0)
	{
		# Store location of original pointer.
		$strings{$string_count}{'Ptr. Location'} = $pointer_search;
	
		# Increase pointer count.
		if($pointer_search =~ /,/)
		{
			my $count = () = $pointer_search =~ /,/g;
			$pointer_count += $count + 1;
		}
		else
		{
			$pointer_count ++;
		}
	}
	# Pointer not found.
	else
	{
		print "!!! No pointer found for string " . $string_count . " !!!\n";
		$strings{$string_count}{'Ptr. Location'} = "N/A";
	}

	# Store location of string.
	$strings{$string_count}{'Location'} = $text_start + $i;

	# Seek through text data until null terminator (0x00) encountered.
	while($text_bytes[$i] ne "00")
	{
		# Append current byte to byte string.
		$byte_string .= $text_bytes[$i];

		# Seek ahead one byte.
		$i ++;
	}

	# Seek ahead through the rest of null padding.
	while($text_bytes[$i] eq "00")
	{
		$i ++;
	}

	# Seek back one byte for lopp to resume at proper position in text data.
	$i --;

	# Store Shift-JIS/ASCII-encoded text.
	$strings{$string_count}{'Japanese Text'} = decode('shiftjis', pack('H*', $byte_string));
}

# Status message.
print "Writing to spreadsheet...\n";

# Write spreadsheet.
&write_spreadsheet($output_file, \%strings);

# Status message.
print "\nComplete!\n\n";
print $string_count . " strings extracted.\n\n";
print "Data written to file \"" . $output_file . "\".\n\n";

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

# Subroutine to read a specified number of bytes, starting at a specific offset (in decimal format), of
# a specified file, returning hexadecimal representation of data.
#
# 1st parameter - Full path of file to read.
# 2nd parameter - Number of bytes to read.
# 3rd parameter - Offset at which to read.
sub read_bytes_at_offset
{
	my $input_file = $_[0];
	my $byte_count = $_[1];
	my $read_offset = $_[2];

	if((stat $input_file)[7] < $read_offset + $byte_count)
	{
		die "Offset for read_bytes_at_offset is outside of valid range.\n";
	}

	open my $filehandle, '<:raw', $input_file or die $!;
	seek $filehandle, $read_offset, 0;
	read $filehandle, my $bytes, $byte_count;
	close $filehandle;
	
	return unpack 'H*', $bytes;
}

# Subroutine to determine if an offset exists as a pointer in the game executable. If found, its
# location(s) are returned. If not, the subroutine returns false.
sub pointer_exists
{
	my $data = $_[0];
	my $location = $_[1];

	my $pointer_formatted = &endian_swap(&decimal_to_hex($location, 4));
	my @four_byte_chunks = $data =~ /(.{1,8})/gs;
	my $pointer_location = 0;
	my $position = 0;

	foreach(@four_byte_chunks)
	{
		if(uc($pointer_formatted) eq uc($_))
		{
			if(!$pointer_location)
			{
				$pointer_location = $position;
			}
			else
			{
				$pointer_location .= ", " . $position;
			}
		}

		$position += 4;
	}

	return $pointer_location;
}

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

# Subroutine to write spreadsheet.
sub write_spreadsheet
{
	my $filename = $_[0];
	my %spreadsheet_data = %{$_[1]};

	my $workbook = Spreadsheet::WriteExcel->new($filename);
	my $worksheet = $workbook->add_worksheet();
	my $header_bg_color = $workbook->set_custom_color(40, 191, 191, 191);

	my $header_format = $workbook->add_format();
	$header_format->set_bold();
	$header_format->set_border();
	$header_format->set_bg_color(40);

	my $cell_format = $workbook->add_format();
	$cell_format->set_border();
	$cell_format->set_align('left');
	$cell_format->set_text_wrap();

	$worksheet->set_column('A:A', 12);
	$worksheet->set_column('B:B', 12);
	$worksheet->set_column('C:C', 12);
	$worksheet->set_column('D:D', 44);
	$worksheet->set_column('E:E', 44);
	$worksheet->set_column('F:F', 44);

	$worksheet->write(0, 0, "Number", $header_format);
	$worksheet->write(0, 1, "Location", $header_format);
	$worksheet->write(0, 2, "Ptr. Location", $header_format);
	$worksheet->write(0, 3, "Japanese Text", $header_format);
	$worksheet->write(0, 4, "English Translation", $header_format);
	$worksheet->write(0, 5, "Notes", $header_format);

	my $row_count = 1;

	foreach my $string_number (sort {$a <=> $b} keys %spreadsheet_data)
	{
		my $japanese_text = $spreadsheet_data{$string_number}{'Japanese Text'};

		$worksheet->write($row_count, 0, $string_number, $cell_format);
		$worksheet->write($row_count, 1, $spreadsheet_data{$string_number}{'Location'}, $cell_format);
		$worksheet->write($row_count, 2, $spreadsheet_data{$string_number}{'Ptr. Location'}, $cell_format);
		$worksheet->write_utf16be_string($row_count, 3, Encode::encode("utf-16", $spreadsheet_data{$string_number}{'Text'}), $cell_format);
		$worksheet->write($row_count, 4, "", $cell_format);
		$worksheet->write($row_count, 5, "", $cell_format);

		$row_count ++;
	}

	$workbook->close();
}