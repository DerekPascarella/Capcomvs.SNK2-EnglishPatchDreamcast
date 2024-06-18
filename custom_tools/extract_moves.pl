#!/usr/bin/perl
#
# extract_moves.pl
# Command list (special moves) extractor for "Capcom vs. SNK 2" on the SEGA Dreamcast.
#
# Written by Derek Pascarella (ateam)

# Include necessary modules.
use utf8;
use strict;
use Encode;

# Set STDOUT encoding to UTF-8.
binmode(STDOUT, "encoding(UTF-8)");

# Set input file.
my $game_executable = "../gdi_extracted/1ST_READ.BIN";

# Set output files.
my $output_file = "moves_extracted.txt";
my $output_file_translated = "moves_extracted_translated.txt";

# Set location and size of move data.
my $moves_loc = 1597992;
my $moves_length = 11354;

# Set Dreamcast RAM's base address (0x8c010000).
my $base_address = 2348875776;

# Read and store entire game executable.
my $game_executable_data = &read_bytes($game_executable);

# Read and store move data.
my $moves_data = uc(&read_bytes_at_offset($game_executable, $moves_length, $moves_loc));

# Store byte array for move data.
my @moves_bytes = ($moves_data =~ m/../g);

# Generate character map hash.
my %character_map = &generate_character_map_hash("sjis.tbl");

# Declare empty string for file output.
my $file_output = "";

# Initialize pointer counter to zero.
my $pointer_count = 0;

# Default control code start flag to false.
my $control_code_start = 0;

# Default text start flag to false.
my $text_start = 0;

# Status message.
print "\n\"Capcom vs. SNK 2\" command list extractor for the SEGA Dreamcast.\n";
print "Written by Derek Pascarella (ateam)\n\n";
print "Parsing data and pointers...\n";

# Iterate through each byte and process move data.
for(my $i = 0; $i < scalar(@moves_bytes); $i ++)
{
	# Start of section control code encountered.
	if($moves_bytes[$i] eq "FF" && !$control_code_start)
	{
		# Search for pointer at location.
		my $pointer_search = &pointer_exists($game_executable_data, $base_address + $moves_loc + $i);
		
		# Pointer found at location.
		if($pointer_search != 0)
		{
			# Construct pointer, including base address.
			my $pointer = &decimal_to_hex($base_address + $moves_loc + $i);
			
			# Append pointer data to file output.
			$file_output .= "\n---POINTER: " . $pointer . " LOCATIONS: " . $pointer_search . "---\n";
		
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

		# Append control code start marker.
		$file_output .= "{FF}";

		# Mark start of control code chunk.
		$control_code_start = 1;
	}
	# Control code started, looking for text.
	elsif($control_code_start && $moves_bytes[$i] ne "FF")
	{
		# Current and next byte are valid Shift-JIS.
		if($character_map{$moves_bytes[$i] . $moves_bytes[$i+1]} ne "")
		{
			# Append Shift-JIS character.
			$file_output .= decode('shiftjis', pack('H*', $moves_bytes[$i] . $moves_bytes[$i+1]));

			# Skip ahead one byte.
			$i ++;
		}
		# Current byte is valid ASCII.
		elsif(&is_valid_ascii($moves_bytes[$i]))
		{
			# Append ASCII character.
			$file_output .= pack('H2', $moves_bytes[$i]);
		}
		# Current byte is unknown, potentially custom character encoding.
		else
		{
			# Append custom character in brackets.
			$file_output .= "{" . $moves_bytes[$i] . "}";
		}

		# Set text start flag to true.
		$text_start = 1;
	}
	# End of section control code encountered.
	elsif($moves_bytes[$i] eq "FF" && $control_code_start)
	{
		# Append control code end marker.
		$file_output .= "{FF";

		# Capture trailing post-close control code.
		if($moves_bytes[$i+1] ne "00" && $moves_bytes[$i+2] eq "00")
		{
			# Append control code.
			$file_output .= $moves_bytes[$i+1];
			
			# Skip ahead one byte.
			$i ++;
		}

		# Finish control code end marker.
		$file_output .= "}\n";

		# Mark end of control code chunk.
		$control_code_start = 0;

		# Mark end of text chunk.
		$text_start = 0;
	}
	# Last control code and text chunk ended, capture in-between control codes.
	elsif($moves_bytes[$i] ne "FF" && !$control_code_start && !$text_start)
	{
		# Set padding flag to true.
		my $padding = 1;

		# Append until next control code encountered.
		while($moves_bytes[$i] ne "FF")
		{
			# Current byte is not null padding.
			if($moves_bytes[$i] ne "00")
			{
				# Chunk was previously padding, but now isn't.
				if($padding)
				{
					# Search for pointer at location.
					my $pointer_search = &pointer_exists($game_executable_data, $base_address + $moves_loc + $i);
					
					# Pointer found at location.
					if($pointer_search != 0)
					{
						# Construct pointer, including base address.
						my $pointer = &decimal_to_hex($base_address + $moves_loc + $i);
						
						# Append pointer data to file output.
						$file_output .= "\n---POINTER: " . $pointer . " LOCATIONS: " . $pointer_search . "---\n";
					
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
					
					# Append open bracket.
					$file_output .= "\n{";

					# Set padding flag to false.
					$padding = 0;

					# Mark end of text chunk.
					$text_start = 0;
				}

				# Append byte.
				$file_output .= $moves_bytes[$i];
			}

			# Skip ahead one byte.
			$i ++;
		}

		# Go back one byte for loop to work correctly.
		$i --;

		# Append close bracket if chunk isn't just padding.
		if(!$padding)
		{
			$file_output .= "}\n";
		}
	}
}

# Remove empty lines from content to be written to file.
$file_output =~ s/^\s*\n|\s+\z//gm;

# Write extracted data to files.
&write_file($output_file, $file_output);
&write_file($output_file_translated, $file_output);

# Status message.
print "\nComplete!\n\n";
print $pointer_count . " pointers found.\n\n";
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

# Subroutine to generate hash mapping UTF-8-encoded characters to custom hexadecimal values.
#
# 1st parameter - Full path of character map file.
sub generate_character_map_hash
{
	my $character_map_file = $_[0];
	my %character_table;

	open my $filehandle, '<:encoding(UTF-8)', $character_map_file or die $!;
	chomp(my @mapped_characters = <$filehandle>);
	close $filehandle;

	foreach(@mapped_characters)
	{
		$_ =~ s/\r//g;
		$_ =~ s/\n//g;
		
		$character_table{uc((split /=/, $_)[0])} = uc((split /=/, $_)[1]);
	}

	return %character_table;
}

# Subroutine to write UTF-8-encoded string data to a file.
#
# 1st parameter - Full path of file to write.
# 2nd parameter - File content to write.
sub write_file
{
	my $output_file = $_[0];
	my $content = $_[1];

	open(my $filehandle, '>:encoding(UTF-8)', $output_file) or die $!;
	print $filehandle $content;
	close $filehandle;
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

# Subroutine to check if a byte represents a valid ASCII character, returning true if so, and false
# if not.
sub is_valid_ascii
{
	my $byte = $_[0];

	if(hex($byte) >= 32 && hex($byte) <= 126)
	{
		return 1;
	}
	else
	{
		return 0;
	}
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