# -*- coding: utf-8 -*-
import io

PATH = r"d:\NEW\CMM\chaoperty\lib\ChiangMai_Municipality\License_menu\license_attach_page\views\widgets\license_attach_table.dart"

with io.open(PATH, "rb") as f:
    raw = f.read()

# Check for \r\n vs \n
crlf_count = raw.count(b'\r\n')
lf_only = raw.count(b'\n') - crlf_count
print(f"CRLF: {crlf_count}, LF-only: {lf_only}")
# Sample bytes around line 146
idx = raw.find(b'\xe0\xb8\xa5\xe0\xb8\x82')
print(f"Found เลข at byte offset {idx}")
print(f"Bytes around: {raw[idx-20:idx+50]}")
