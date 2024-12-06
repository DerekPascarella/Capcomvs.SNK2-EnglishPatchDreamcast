#!/bin/sh

perl insert_end_text_en.pl

perl insert_moves.pl

perl insert_win_messages.pl A

perl insert_win_messages.pl B

cp MESE_DM.BIN /mnt/z/dc/gdi/new/capcom_vs_snk_2/gdi_testing/gdi_extracted/

cp MESJ_WIN.BIN /mnt/z/dc/gdi/new/capcom_vs_snk_2/gdi_testing/gdi_extracted/

cp MESE_WIN.BIN /mnt/z/dc/gdi/new/capcom_vs_snk_2/gdi_testing/gdi_extracted/

perl update_file_table.pl

cp 1ST_READ.BIN /mnt/z/dc/gdi/new/capcom_vs_snk_2/gdi_testing/gdi_extracted/
