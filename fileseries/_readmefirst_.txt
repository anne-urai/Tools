
   FileSeries: Recursive renaming, renumbering and other operations on a
   series of files
   
   F. Moisy

   version 1.50, 2 june 2010
__________________________________________________________________________

See:  www.fast.u-psud.fr/~moisy/ml

Bug report:  moisy@fast.u-psud.fr
__________________________________________________________________________

This directory contains some simple Matlab functions for recursive
operations on files (wildcards on subdirectories allowed), and automatic
renaming and renumbering for series of files. This may be useful for
handling a large number of files:

   cdw               - Change directory (like CD), allowing wildcard (*).
   lsw               - List directory (like LS), allowing wildcard (*).
   rdir              - Recursive list directory.
   rdelete           - Delete files recursively.
   rrmdir            - Delete directories recursively.
   renamefile        - Rename a series of files.
   renumberfile      - Re-number the indices of a series of files
   getfilenum        - Get the index of a series of files.

Examples:

   CDW mydir*/dir*12  works as CD, but wildcards (*) are allowed

   F = RDIR('set*/DSC*.*')  returns all the files matching DSC*.* in all
   the directories matching set*.

   RENAMEFILE('DSC*.JPG','DSC','myphoto') renames the files 'DSC00001.JPG',
   'DSC00002.JPG',... as 'myphoto00001.JPG','myphoto00002.JPG',...

   RENUMBERFILE('DSC*.JPG','DSC') renumbers the *.JPG files as
   'DSC00001.JPG'...'DSC00100.JPG'.

   N = GETFILENUM('*.JPG','DSC') returns the indices of JPG-files.

See the help for each function for more examples.
__________________________________________________________________________

History

v1.00 (2005/10/04): First release.
v1.01 (2005/10/13): New functions rdelete and rrmdir.
V1.10 (2006/09/01): bug fixed rdelete.
V1.20 (2006/09/08): code improved.
V1.30 (2008/07/28): new CDW
V1.40 (2009/09/02): new LSW. functions renamefile and renumberfile improved.
V1.50 (2010/06/02): bugs fixed in rdir and renamefile.
__________________________________________________________________________

The End.