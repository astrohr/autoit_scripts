# autoit_scripts

## RunMaxImDL

Launcher for MaxIm DL.

 * Deletes any saved temporary images in `TT` folder (outside `YYYY-MM-DD` folders). This avoids the `Cannot saving image`
   errors when doing non-autosave exposures (e.g. when doing focusing or position refiniement)
   
## TargetLoader
 
GUI shortcut window to save time spent clicking and copy-pasting values to MaxIm DL.

 * Reads target list file (`TT/<YYYY-MM-DD>/<YYYY-MM-DD>.txt`).
 * Displays a clickable label for every entry in that file.
 * On click, opens the "Autosave" window in MaxIm DL an fills out the values there.
 * Also opens that "Telescope" tab and fills out RA and DEC coordinates
   * currently only supports object name and coordinates: [autoit_scripts/issues/1](https://github.com/astrohr/autoit_scripts/issues/1)
