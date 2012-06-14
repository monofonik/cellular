****************************************
CELLULAR - DEVELOPMENT README
****************************************

Configuring

- Copy BaseCellular.image and BaseCellular.changes to Cellular.image and Cellular.changes
- Run cellular_development (Mac) or cellular_development.bat (Windows)
- Follow instructions within Squeak Image to import classes from version control

During development, left-click the background and select Save to save the current state of the Squeak image. Note that the base image (BaseCellular.image / BaseCellular.changes) should not be modified, in order to prevent the need for committing large files to version control.

Exporting to version control

- From within Squeak image, select <Shift> File, export to version control. This will export all modified classes to the ./Classes directory
- Commit to GitHub as normal

Releasing

- In the Squeak class browser, select "ScratchFrameMorph - Class - All - version:"
- Uncomment the first line of text, increment the version number
- Select the first line of text, press <Ctrl> D
- Re-comment the first line of text
- Select <Shift> Edit - "Save image for end user". The Squeak image will be saved in the release state and closed.
- Run ./copyforrelease.sh
- Run installers/mac/compile.sh to create Mac disk image (From Mac only)
- Run installers/windows/installer.nsi to create Windows installer (From Windows only - requires NSI)


****************************************
RELEASE NOTES
****************************************

0.0.6 - 2012-06-14

- Duplicating a sprite type changes its name to next available (instead of duplicating name) [Issue #11]
- Fixed problem where selected cell attribute is invalid after deleting attribute or opening / creating new project [Issue #7]
- Disabled "allow sprites off stage" functionality due to unpredictable behaviour when enabled [Issue #5]
- Default cell attribute set to zero spread [Issue #3]
- Improved validation on create new cell attribute screen [Issue #2]
- Added block to sensing category for querying number of sprites / sprites of type [Issue #1]
- Fixed bug where clicking "touching __" block produced an error message


0.0.5 - 2012-06-05

- Fixed bug where renaming agent costume does not propagate to agents already instantiated
- Fixed cell refresh bug when deleting cell attributes or changing all cell values


0.0.4 - Initial release

- Create / delete environment attributes
- Paint / erase env attributes on cells
- "Neighbours" and "Cells" categories implemented
- Variable plotting
- Grid system / motion blocks to move by cell
- Added sample files
