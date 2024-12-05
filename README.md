<h1>Capcom vs. SNK 2: Millionaire Fighting 2001</h1>
<img width="165" height="165" align="right" src="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/blob/main/images/cover.png?raw=true"><!--Download the English translation patch (more information in the <a href="#patching-instructions">Patching Instructions</a> section). Note that there are several patch options.-->
Note that there are several options, explained below, for applying this English translation patch. All produce the same patched version of the game, but each caters to users in different ways.
<br><br>
For details on how to apply an individual patch, see the <a href="#patching-instructions">Patching Instructions</a> section.
<br><br>
Both GDI options produce the same patched disc image, however one requires <a href="https://github.com/DerekPascarella/UniversalDreamcastPatcher">Universal Dreamcast Patcher</a> v1.3 or newer, whereas the other allows the use of common patch utilities that support XDelta format (like <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a>).
<br><br>
In the majority of cases, those burning to CD-R can use either of the CDI patches. However, many NTSC-J VA0 Dreamcast consoles suffer from incompatibility with Data/Data mode discs. Conversely, there are later model VA2 Dreamcast consoles that don't support Audio/Data mode discs, making Data/Data mode ideal. Unless a player is using an NTSC-J VA0 console, it's advised they start with the Data/Data mode patch. Should issues arise when attempting to boot the disc, they should move on to the Audio/Data mode version.
<br><br>
<ul>
  <li><b>GDI Format (Users of ODEs or Emulators)</b><br>
    <ul>
      <li>
        <b>Option 1</b>
        <br>
        Download <a href="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/releases/download/1.0/xxxx.dcp">Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0).dcp</a> for use with <a href="https://github.com/DerekPascarella/UniversalDreamcastPatcher">Universal Dreamcast Patcher</a> v1.3 or newer.
      </li>
      <li>
        <b>Option 2</b>
        <br>
        Download <a href="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/releases/download/1.0/xxxx.xdelta">Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0) [GDI].xdelta</a> for use with <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a> (or equivalent tools).
      </li>
    </ul>
  </li>
  <br>
  <li><b>CDI Format (Users Burning to CD-R)</b><br>
    <ul>
      <li>
        <b>Option 1</b>
        <br>
        Download <a href="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/releases/download/1.0/xxxxx.xdelta">Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0) [CDI - Audio-Data Mode].xdelta</a> for use with <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a> (or equivalent tools).
      </li>
      <li>
        <b>Option 2</b>
        <br>Download <a href="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/releases/download/1.0/xxxxx.xdelta">Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0) [CDI - Data-Data Mode].xdelta</a> for use with <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a> (or equivalent tools).
      </li>
    </ul>
  </li>
</ul>


<h2>Table of Contents</h2>

1. [Patching Instructions](#patching-instructions)
2. [Credits](#credits)
3. [Release Changelog](#release-changelog)
4. [Known Issues](#known-issues)
5. [Reporting Bugs and Typos](#reporting-bugs-and-typos)
6. [What's Changed](#whats-changed)
7. [About the Game](#about-the-game)
8. [Bonus Content](#bonus-content)

<h2>Patching Instructions</h2>
<ul>
 <li>
   <b>GDI Format (Users of ODEs or Emulators) - DCP Patch</b>
   <br>
   <img align="right" width="250" src="https://github.com/DerekPascarella/UniversalDreamcastPatcher/blob/main/screenshots/screenshot.png?raw=true">The DCP patch file shipped with this release is designed for use with <a href="https://github.com/DerekPascarella/UniversalDreamcastPatcher">Universal Dreamcast Patcher</a> v1.3 or newer.  Note that Universal Dreamcast Patcher supports both TOSEC-style GDI and Redump-style CUE disc images as source input.
   <br><br>
   <ol type="1">
     <li>Click "Select GDI or CUE" to open the source disc image.</li>
     <li>Click "Select Patch" to open the DCP patch file.</li>
     <li>Click "Apply Patch" to generate the patched GDI, which will be saved in the folder from which the application is launched.</li>
     <li>Click "Quit" to exit the application.</li>
   </ol>
 </li>
 <br>
  <li>
   <b>GDI Format (Users of ODEs or Emulators) - XDelta Patch</b>
   <br>
   <img align="right" width="250" src="https://i.imgur.com/r4b04e7.png">The XDelta patch file shipped with this release can be used with any number of Delta utilities, such as <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a>. It targets <tt>track03.bin</tt> of the original TOSEC GDI. Ensure the source <tt>track03.bin</tt> file has an MD5 checksum of <tt>FF8E199324FC11D4F638E5C99315CDBB</tt>.
   <br><br>
   <ol type="1"><li>Click the settings icon (appears as a gear), enable "Checksum validation", and disable "Backup original file".</li>
     <li>Click the "Original file" browse icon and select the original <tt>track03.bin</tt> file.</li>
     <li>Click the "XDelta patch" browse icon and select the <tt>Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0) [GDI].xdelta</tt> XDelta patch.</li>
     <li>Click "Apply patch" to overwrite the original <tt>track03.bin</tt> file with the patched version.</li>
     <li>Verify that the patched <tt>track03.bin</tt> file has an MD5 checksum of <tt>xxx</tt>.
   </ol>
 </li>
 <br>
 <li>
   <b>CDI Format (Users Burning to CD-R)</b>
   <br>
   <img align="right" width="250" src="https://i.imgur.com/r4b04e7.png">The XDelta patch files shipped with this release can be used with any number of Delta utilities, such as <a href="https://www.romhacking.net/utilities/704/">Delta Patcher</a>. Ensure the source CDI has an MD5 checksum of <tt>75CC93F861E95C8CDCAF6863B1EB3976</tt>.
   <br><br>
   <ol type="1">
     <li>Click the settings icon (appears as a gear) and enable "Backup original file" and "Checksum validation".</li>
     <li>Click the "Original file" browse icon and select the unmodified CDI.</li>
     <li>Click the "XDelta patch" browse icon and select either the <tt>Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0) [CDI - Audio-Data Mode].xdelta</tt> or <tt>Capcom vs. SNK 2 - Millionaire Fighting 2001 (English v1.0) [CDI - Data-Data Mode].xdelta</tt> XDelta patch.</li>
     <li>Click "Apply patch" to generate the patched CDI in the same folder containing the original CDI.</li>
     <li>Verify that the patched CDI has an MD5 checksum of <tt>xxx</tt> if using the Data/Data mode patch, or <tt>xxx</tt> if using the Audio/Data mode patch.
   </ol>
 </li>
</ul>

<h2>Credits</h2>
<ul>
 <li><b>Programming</b></li>
  <ul>
   <li>Derek Pascarella (ateam)</li>
  </ul>
  <br>
  <li><b>Translation</b></li>
  <ul>
   <li>Duralumin</li>
   <li>Jesuszilla</li>
   <li>Tortita</li>
   <li>Justin Gibbins</li>
  </ul>
  <br>
  <li><b>Graphics</b></li>
  <ul>
   <li>rob2d</li>
  </ul>
  <br>
  <li><b>Playtesting</b></li>
  <ul>
   <li>Jesuszilla</li>
   <li>Tortita</li>
   <li>Silentscope</li>
  </ul>
  <br>
  <li><b>Special Thanks</b></li>
  <ul>
   <li>Justin Gibbins</li>
  </ul>
</ul>

<h2>Release Changelog</h2>
<ul>
 <li><b>Version 1.0 (202X-XX-XX)</b></li>
 <ul>
  <li>Initial release.</li>
 </ul>
</ul>

<h2>Known Issues</h2>
While the patch development team has worked diligently to eliminate bugs and other imperfections, there presently exists one area of the game where there's room for improvement. Players may notice that various status messages that appear throughout their play (e.g., "Now saving...") are off-center. This is due to a quirk in the game's automatic-text-centering code and its behavior when using its own built-in narrower Latin font. Measures were taken to mitigate this minor issue, but it was not addressed in all cases.
<br><br>
It's asked that players please keep this in mind befopre submitting a bug report.

<h2>Reporting Bugs and Typos</h2>
Even after extensive testing on both real hardware and on emulators, the presence of bugs or typos may be possible. Should a player encounter any such issue, it's kindly requested that they <a href="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/issues/new">submit a new issue</a> to this project page, including as much detailed information as possible.

<h2>What's Changed</h2>
<img align="right" width="267" height="200" src="https://github.com/DerekPascarella/Capcom-vs.-SNK-2-English-Patch-Dreamcast/blob/main/images/screenshot1.png?raw=true">Below is a high-level list of changes implemented for this English translation patch.
<br><br>
<ul>
 <li>Character names have been changed to a combination of Japanese and Western variants.</li>
  <ul>
    <li>"God Rugal" is used instead of "Ultimate Rugal".</li>
    <li>"Vega" is used instead of "Balrog", "M. Bison" is used instead of "Vega", and "Balrog" is used instead of "M. Bison" (conforming to established Western character names).</li>
  </ul>
 <li>English naming conventions used for "Parrying" (instead of "Blocking") and "Custom Combo Finish" (instead of "Original Combo Finish").</li>
 <li>Japanese "Millionaire Fighting 2001" used instead of "Mark of the Millenium 2001".</li>
 <li>All text translated translated to English in menus, status messages, and unlock messages.</li>
 <li>Special move "Command List" translated to English based on PlayStation 2 version, but with several fixes and clean-ups.</li>
 <li>End-of-game cutscenes translated to English based on PlayStation 2 version, but with several fixes and clean-ups.</li>
 <li>All win-quote dialogue translated to English (around 51000 instances) that were previously unique to the Japanese version. This dialogue is customized based on who is speaking, who their opponent is, and who their companion fighter is.</li>
  <ul>
    <li>To see character-specific win quotes in "Single Match" mode, hold the Start Button plus either the L or R triggers after a KO, just before the screen transition occurs. Otherwise, the generic win quotes will be displayed the vast majority of the time.</li>
    <li>In "Ratio Match" mode, the two-way character-specific dialogue is displayed by default.</li>
    <li>In "3 on 3 Match" mode, the character-specific win quotes are displayed the vast majority of the time, with generic win quotes sometimes used. To force the character-specific win quotes, hold the Start Button plus either the L or R triggers after a KO, just before the screen transition occurs.</li>
  </ul>
 <li>The now-defunct "Network Mode" has been replaced with "Bonus Mode", delivering special bonus content to players (see <a href="#bonus-content">Bonus Content</a> section).</li>
  <ul>
   <li>Previously this portion of the game was inaccessible to those who've never configured ISP settings on their Dreamcast, but this requirement has been removed.</li>
  </ul>
</ul>
