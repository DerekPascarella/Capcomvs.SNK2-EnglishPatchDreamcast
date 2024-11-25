#!/usr/bin/perl
#
# insert_win_messages.pl
# Win message rebuilder for "Capcom vs. SNK 2" on the SEGA Dreamcast.
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use utf8;
use strict;
use Encode;
use HTML::Entities;
use Spreadsheet::ParseXLSX;
use Spreadsheet::Read qw(ReadData);

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Store arguments.
my $mode = $ARGV[0];

# Set input file.
my $input_file = "MESJ_WIN_NEW.BIN.xlsx";
my $message_file = "../gdi_original_extracted/MESJ_WIN.BIN";

# Set output file name base based on mode.
my $output_file;

if($mode eq "A")
{
	$output_file = "MESJ_WIN.BIN";
}
elsif($mode eq "B")
{
	$output_file = "MESE_WIN.BIN";
}

# Store pre-text/pointer section of message data.
my $pre_text_data = &read_bytes_at_offset($message_file, 5100, 8);

# Store pointer table from message data.
my $pointer_table = &read_bytes_at_offset($message_file, 59168, 298720);
my @pointer_table_entries = $pointer_table =~ /(.{1,8})/gs;

# Store offset of text's starting position in message data (0x13F4).
my $text_position = 5108;

# Store length (in bytes) of original text portion (0x47AEC).
my $original_text_size = 293612;

# Store value of the two pointers in original header for purposes of recalcuation.
my $header_pointer_1 = 357504;
my $header_pointer_2 = 357696;

# Set maximum output file size to 358400 bytes.
my $maximum_file_size = 358400;

# Declare empty hash for storing string data.
my %strings = ();

# Status message.
print "\n\"Capcom vs. SNK 2\" win message rebuilder for the SEGA Dreamcast.\n";
print "Written by Derek Pascarella (ateam)\n\n";
print "Reading spreadsheet...\n\n";

# Read and store spreadsheet.
my $spreadsheet = ReadData($input_file);
my @spreadsheet_rows = Spreadsheet::Read::rows($spreadsheet->[1]);

# Status message.
print "Extracting text and rebuilding data...\n\n";

# Declare empty variable to hold entirety of newly generated text data.
my $text_data = "";

# Iterate through each row of spreadsheet, skipping header columns.
for(my $i = 1; $i < scalar(@spreadsheet_rows); $i ++)
{
	# Store string number, location, and pointer location for current spreadsheet row.
	my $number = $spreadsheet_rows[$i][0];
	my $location = $spreadsheet_rows[$i][1];
	my $pointer_location = $spreadsheet_rows[$i][2];

	# Ensure string number and location values are sane.
	foreach my $number_check ($number, $location)
	{
		unless($number_check =~ /^-?\d+(\.\d+)?$/)
		{
			print "ERROR: Row " . ($i + 1) . " has a missing or corrupt string number or location value!\n";
			<STDIN>;
		}
	}

	# Ensure pointer location value is sane.
	unless($pointer_location =~ /^(-?\d+(\.\d+)?)(,\s*-?\d+(\.\d+)?)*$/)
	{
		print "ERROR: Row " . ($i + 1) . " has a missing or corrupt pointer location value!\n";
		<STDIN>;
	}

	# After sanity check, cast each to integer.
	$number = int($number);
	$location = int($location);
	$pointer_location = int($pointer_location);

	# Generate pointer based on string location.
	my $pointer = &endian_swap(&decimal_to_hex($location, 4));

	# Declare empty variables to hold translation and its hex representation.
	my $translation;
	my $translation_hex;

	# Initialize incomplete translation counter to zero.
	my $incomplete_translations = 0;

	# Only process text if it's in range for either mode A or B.
	if(($mode eq "A" && $number <= 4543) || ($mode eq "B" && $number >= 4544))
	{
		# Store English text.
		$translation = decode_entities($spreadsheet_rows[$i][5]);

		# Increase count of incomplete translations by one if placeholder number is present.
		if($translation =~ /^(-?\d+(\.\d+)?)(,\s*-?\d+(\.\d+)?)*$/)
		{
			$incomplete_translations ++;
		}

		# Clean translated text.
		$translation =~ s/^\s+|\s+$//g;
		$translation =~ s/ +/ /;
		$translation =~ s/\s+/ /g;
		$translation =~ s/’/'/g;
		$translation =~ s/”/"/g;
		$translation =~ s/“/"/g;
		$translation =~ s/\.{4,}/\.\.\./g;
		$translation =~ s/…/\.\.\./g;
		$translation =~ s/‥/\.\./g;
		$translation =~ s/^\.\.\.\s+/\.\.\./g;
		$translation =~ s/\P{IsPrint}//g;
		
		#### NO LONGER REMOVING NON-ASCII CHARACTERS ####
		#$translation =~ s/[^[:ascii:]]+//g;
		#################################################

		# Fix "W-what" and all similar occurrences to "W-What".
		$translation =~ s/([A-Z])-([a-z])/$1 . '-' . uc($2)/ge;

		# Text should be dummied with a single empty space.
		if($translation eq "NULL")
		{
			$translation_hex = "20";
		}
		# Treat text as special asterisk sequence.
		elsif($number == 138)
		{
			$translation_hex = "81968196819681968196819681968196819681968196819681968196819681968196819681968196";
		}
		# Otherwise, text should be processed.
		else
		{
			#### USING SHIFT-JIS NOW IN ORDER TO USE SOME NON-ASCII CHARACTERS ####
			# Store ASCII-encoded hex representation of the string.
			#$translation_hex = unpack('H*', encode('ASCII', $translation));
			#######################################################################

			# Store Shift-JIS-encoded hex representation of the string.
			$translation_hex = unpack('H*', encode('Shift-JIS', $translation));
		}

		# Remove erroneous leading 0x3F character from hex representation of translated text.
		$translation_hex =~ s/^3f//g;
	}
	# Otherwise, use dummy "X" placeholder.
	else
	{
		$translation = "X";

		# Treat text as special asterisk sequence.
		if($number == 138)
		{
			$translation_hex = "81968196819681968196819681968196819681968196819681968196819681968196819681968196";
		}
		else
		{
			$translation_hex = "58";
		}
	}

	#### NEW ####
	# Append null padding.
	$translation_hex .= "00";

	# Append current string's data.
	$text_data .= $translation_hex;

	# Append enough padding for four-byte alignment to final string before pointer table starts.
	if($i == scalar(@spreadsheet_rows) - 1)
	{
		while((length($text_data) / 2) % 4 != 0)
		{
			$translation_hex .= "00";
			$text_data .= "00";
		}
	}
	#### NEW ####

	#### TURNS OUT 4-BYTE ALIGNMENT ISN'T NECESSARY ####
	######### CODE ABOVE NOW BEING USED INSTEAD ########
	# # Append null padding for four-byte alignment.
	# $translation_hex .= "00";

	# while((length($translation_hex) / 2) % 4 != 0)
	# {
	# 	$translation_hex .= "00";
	# }
	####################################################

	# Calculate new pointer based on current position.
	my $pointer_new = &endian_swap(&decimal_to_hex($text_position, 4));

	# Store data for current string in hash key.
	$strings{$pointer}{'Hex'} = $translation_hex;
	$strings{$pointer}{'Number'} = $number;
	$strings{$pointer}{'New Pointer'} = $pointer_new;

	# Increase position of current string for pointer calculation purposes.
	$text_position += (length($translation_hex) / 2);

	#### PART OF OLD 4-BYTE ALIGNMENT CODE ####
	# # Append current string's data.
	# $text_data .= $translation_hex;
	###########################################
}

# Store size difference between original and new text portion for purposes of pointer calculation.
my $size_difference = (length($text_data) / 2) - $original_text_size;

# Recalculate the two pointers that begin the file's header.
my $new_header_pointer_1 = $header_pointer_1 + $size_difference;
my $new_header_pointer_2 = $header_pointer_2 + $size_difference;
$new_header_pointer_1 = &endian_swap(&decimal_to_hex($new_header_pointer_1, 4));
$new_header_pointer_2 = &endian_swap(&decimal_to_hex($new_header_pointer_2, 4));

# Prepend both pointers to header.
$pre_text_data = $new_header_pointer_1 . $new_header_pointer_2 . $pre_text_data;

# Declare empty variable to store new pointer table able recalcutations.
my $pointer_table_new = "";

# Initialize pointer-change counters to zero.
my $pointer_count_string = 0;
my $pointer_count_other = 0;

# Iterate through original pointer table entries for find/replace.
for(my $i = 0; $i < scalar(@pointer_table_entries); $i ++)
{
	# Store current pointer as flat string.
	my $current_pointer = uc(join("", $pointer_table_entries[$i]));

	# Declare empty variable to store new pointer.
	my $pointer_new = "";

	# Current pointer exists in hash.
	if(exists $strings{$current_pointer})
	{
		# Store new pointer.
		$pointer_new = $strings{$current_pointer}{'New Pointer'};

		# Increase count.
		$pointer_count_string ++;
	}
	# Otherwise, perform generic relative adjustment calculation.
	else
	{
		# Store current pointer in decimal format.
		my $current_pointer_decimal = hex(&endian_swap($current_pointer));

		# Current pointer is not pointing to any pre-text data (which should not be changed).
		if($current_pointer_decimal >= 5108)
		{
			# Calculate new pointer.
			$pointer_new = $current_pointer_decimal + $size_difference;
			$pointer_new = &endian_swap(&decimal_to_hex($pointer_new, 4));

			# Increase count.
			$pointer_count_other ++;
		}
		# Otherwise, use original pointer.
		else
		{
			$pointer_new = $current_pointer;
		}
	}

	# Append new pointer as entry to table.
	$pointer_table_new .= $pointer_new;
}

# Construct entirety of new message file.
my $output_data = $pre_text_data . $text_data . $pointer_table_new;

# Status message.
print "Writing data...\n";

# Write data to file.
&write_bytes($output_file, $output_data);

# Status message.
print "\nComplete!\n\n";
print $incomplete_translations . " incomplete translations detected.\n\n";
print $pointer_count_string . " string pointers updated.\n\n";
print $pointer_count_other . " other pointers updated.\n\n";
print "Data written to file \"" . $output_file . "\" (" . (length($output_data) / 2) . " bytes).\n\n";

# Output file exceeds maximum size.
if(length($output_data) / 2 > $maximum_file_size)
{
	# Status message.
	print "WARNING: Output file exceeds " . $maximum_file_size . " bytes (" . (length($output_data) / 2) . ")\n\n";
}

# Subroutine to return hexadecimal representation of a decimal number.
#
# 1st parameter - Decimal number.
# 2nd parameter - Number of bytes with which to represent hexadecimal number (omit parameter for no
#				 padding).
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