# Cryptor

Simple application for Linux, MacOS and Windows to store your login datas in a xml- or decrypted-file. The en-/decoder is AES 256-bit.

Please test this software with fictional accounts and report errors and suggestions of new/better functionality. In the "release" folder is an actual MacOS version (must be unpacked bevore use) and an actual MS-Windows version (download the languages.xml too, to see how to translate the gui in a different language).

Thank you and happy testing.


# ToDos

* create a settings dialog (to select language)
* test on linux machines
* test whole software


# Version History

**Version 2.3.1**
* made the window and gadgets sizeable


**Version 2.3.0**
* created a language procedure that can load languages via a xml file
* added a create password dialog
* added an about dialog with (hopely) all licenses
* created a nicier print layout
* minor bug fixes in the GUI and the password generator


**Version 2.2.0**
* added the AES 256-bit encryption for the database
* added SHA2 256-bit encryption for the password(s)
* fix minor bug in the GUI


**Version 2.1.0**
* fix many bugs in the GUI
* create a more flexible passwords creator
* save/load settings to/from a config file
* settings saved by user (no root needed)
* add a (really simple) language function for the GUI
* create a MacOS workaround to start the app from Finder (on doubleclick on passwor ddatabase)


**Version 2.0.0**
* complete rewrite
* change database for the passwords to XML format
* use AES 128-bit encryprion for database
* create a nicier GUI
* check passwords while writing
* add a print database function
* add a log function
* created new icons ;-)


**Version 1.3.0**
* modify source for a MacOS version
* add a create password function


**Version 1.2.0**
* fix bugs in the gui


**Version 1.1.0**
* added double query for the password
* use MD5 encryption for passwords
* added a GUI


**version 1.0.0**
* initial release
