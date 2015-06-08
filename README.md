GameMaker' Visualizer is a program that manipulates "object information" output from YoYo Games' GameMaker (both Studio and older versions) to produce a variety of outputs.

You can check out the live version (and/or support the development) via [project's itch.io page](http://yellowafterlife.itch.io/gmvisualizer).

### Usage
Instructions vary depending on the area of the interest.
*	If using BB mode for highlighting code, no additional setup or configuration is needed - the program will output a bunch of tags which will function fine on majority of forums and wbsites with BB/UBB code support.
	
	If you want to also display DnD icons, you will need to download the provided `pkg.zip`, upload the icon directory (`img`) containing DnD icons somewhere, and set the Icon URL format string to point to that location. Depending on the particular BB code format, you may also need to change several options to match the expected format.

*	If you want to display snippets of DnD or GML on a site/blog, you'll need to upload `gminfo.png` and `gmvisualizer.css` to your site, and include the CSS file on the pages of interest. Stylesheet can be customized to fit the blog theme, obviously.

*	For converting DnD blocks to GML, no additional setup is required. Code is output in "object information" format and displayed in highlighted form in the preview box for convenience.

### Special syntax
For quick use as a highlighter for code snippets, I have included two "special cases" in the program's algorithm:

Inserting a single expression preceded with "```" will highlight it as an inline expression.

Inserting a piece of code with first line containing nothing but "```" will highlight it as a multi-line snippet (bearing similarity to "execute code" block but having no icon/indentation).

### Notes on source code
The primary purpose of this repository is to allow anyone interested (and/or familiar with [Haxe](http://haxe.org/)) to peek at the program's structure or take a shot at modifying it to do new tricks.

Program is kept largely modular - at most times you would want to create a new `Info` instance, `readString` a snippet into it, and `print` it into one of the formats supported. Currently setup is done via a static `Conf` class. `Main` class can be used as example of usage.

While the `Main` class will only compile under JS target, the rest of the source has no platform-specific references and should compile fine under the most platforms.

## License
GameMaker' Visualizer is licensed under [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International](https://creativecommons.org/licenses/by-nc-sa/4.0/) license.
