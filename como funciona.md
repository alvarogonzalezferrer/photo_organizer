photo mover

*** info hoy 11/02/2022

comando >

// TAG DateTimeOriginal no funciona en videos
// TAG CreateDate  deberia funcionar en video tambien

exiftool -T -FilePath -DateTimeOriginal -d %Y\%m -@ LISTA_DE_ARCHIVOS.TXT

escribe el path del archivo, un tab , y la fecha en el formato para crear la carpeta 

en -d poner el FORMATO que quiero para las carpetas

	%Y\%m // año y mes 

	%Y\%m\%d // con dia 

	%Y // año solo 

	%m // mes solo 

** leer archivo determinado con tabs

https://delphi.cjcsoft.net/viewthread.php?tid=45623

*** info mas vieja
usar exiftool para obtener la data de la multimedia -- https://exiftool.org/ } asi hace el photomover pedorro

como llamarlo desde lazarus 
*** atencion tomar lista de archivos **

usar  -@ lista_de_archivos 

exiftool ARGS -@ out.txt

***

https://exiftool.org/gui/articles/delphi01.html

y usar lazarus para mover

ir carpeta por carpeta levantando los datos, y copiando / moviendo 

** libreria 

fpexif 

https://sourceforge.net/p/lazarus-ccr/svn/7194/tree/components/fpexif/

https://forum.lazarus.freepascal.org/index.php?topic=44015.0


** como mover archivos **

https://www.askingbox.com/tip/lazarus-rename-or-move-file

https://www.freepascal.org/docs-html/rtl/sysutils/renamefile.html

** como copiar archivos **

https://wiki.freepascal.org/CopyFile

https://lazarus-ccr.sourceforge.io/docs/lazutils/fileutil/copyfile.html

** como ir carpeta por carpeta **


https://docwiki.embarcadero.com/CodeExamples/Sydney/en/FindFirst_(Delphi)

With the usual TSearchRec and FindFirst functions (also found in Delphi) one can retrieve all files in a directory and subdirectories.

To my pleasant surprise, Lazarus has a great little function in the "fileutil" unit called FindAllFiles() which does all this for you and shoves the result nicely in a TStringList ... 

** ATENTO ** NO HACER ARCHIVO POR ARCHIVO, SINO CARPETA POR CARPETA, LO PERMITE

https://exiftool.org/forum/index.php?topic=7886.0

exiftool -T -FileName -DateTimeOriginal FILESorDIR

this will output the name of the file, a tab, and the date&time the image was taken at.


Improving Performance

There is a significant overhead in loading ExifTool, so performance may be greatly improved by taking advantage of ExifTool's batch processing capabilities (the ability to process multiple files or entire directories with a single command) to reduce the number of executed commands when performing complex operations or processing multiple files.† [One exiftool user documented a 60x speed increase by processing a large number of files with a single command instead of running exiftool separately on each file.] Also, the -execute option may be used to perform multiple independent operations with a single invocation of exiftool, and together with the -stay_open option provides a method for calling applications to avoid this startup overhead.

It has also been observed that the loading time of ExifTool for Windows increases significantly when Windows Defender is active. Disabling Windows Defender may speed things up significantly.

The processing speed of ExifTool can be improved when extracting information by reducing the amount of work that it must do. Decrease the number of extracted tags by specifying them individually (-TAG) or by group (-GROUP:all), and disable the composite tags (-e) and the print conversions (-n) if these features aren't required. Note that the exclude options (-x or --TAG) are not very efficient, and may have a negative impact on performance if a large number of tags are excluded individually. The exception is XMP groups, which are bypassed in processing so they are never even extracted -- specifying --XMP-crs:all and -XMP-crd:all may speed processing significantly by avoiding processing of bulky Adobe image-editing information.

The -fast option can significantly increase speed when extracting information from JPEG images which are piped across a slow network connection. However, with this option any information in a JPEG trailer is not extracted. For more substantial speed benefits, -fast2 may be used to also avoid extracting MakerNote information if this is not required, or -fast4 if only pseudo System tags are required.

When writing, avoid copying tags (with -tagsFromFile) or using the -if or -fileOrder option because these will add the extra step of extracting tags from the file. Without these the write operation is accomplished with a single pass of each file.

    † However, note that when the -csv option is used, information from all files is buffered in memory before the CSV output is written. This may be very memory intensive and result in poor performance when reading a large number of files in a single command.