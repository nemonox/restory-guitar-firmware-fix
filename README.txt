=====================================================================
 ReStory: Chill Electronics Repairs - "Update firmware" fix
=====================================================================

PROBLEM
-------
Some orders (e.g. "Guitar Legend") require the UPDATE FIRMWARE service,
but the UNLOCK-TOOLKIT app on the in-game computer shows:

    CONNECTING DEVICE: NOT POSSIBLE FOR THIS DEVICE
    CHECKING DEVICE: UNABLE TO CHECK

and the order gets stuck.

CAUSE
-----
This is a bug in the game. The UNLOCK-TOOLKIT content table only has data
for three device categories: console, phone and laptop. The guitar is
flagged as hackable, but its category ("Household") is missing from that
table, so the app rejects the device. The game log (Player.log) shows:

    HackingContentTable not contains data for category Household

WHAT THE PATCH DOES
-------------------
It changes 23 bytes in Restory_Data\Managed\Restory.Assembly.dll. When a
device category is missing from the table, the app now uses the console
content instead of rejecting the device. Nothing else is changed, and your
save file is not touched. A backup is created automatically
(Restory.Assembly.dll.bak).

Tested on game version 1.0.005r (Unity 6000.3.10f1). If a game update
changes this code, the patcher reports "Incompatible game version" and
leaves the file alone.

---------------------------------------------------------------------
 BEFORE YOU START: BACK UP YOUR FILES
---------------------------------------------------------------------
The patcher makes its own backup of the file it changes, but please make
your own backup before applying it. Close the game first, then copy
these two folders somewhere safe (for example, your Desktop):

  1. The game's "Managed" folder (or, to be extra safe, the whole game
     folder):
       <game folder>\Restory_Data\Managed

  2. Your save files (the patch doesn't touch them, but it's good
     practice before modding any game):
       Windows: %USERPROFILE%\AppData\LocalLow\Mandragora\Restory
                (paste this into the File Explorer address bar)
       Linux / Steam Deck (Proton):
         <Steam library>/steamapps/compatdata/<game id>/pfx/drive_c/
         users/steamuser/AppData/LocalLow/Mandragora/Restory

To restore manually, close the game and copy the folders back,
overwriting the files.

---------------------------------------------------------------------
 HOW TO APPLY - WINDOWS
---------------------------------------------------------------------
1. CLOSE THE GAME.
2. Find the game folder (the one that contains Restory.exe).
   On Steam: right-click the game > Manage > Browse local files.
   Back up your files as described above.
3. Extract this folder (ReStory-FirmwareFix) INSIDE the game folder.
   It should look like this:
       ...\ReStory\Restory.exe
       ...\ReStory\ReStory-FirmwareFix\APPLY_PATCH.bat
4. Double-click APPLY_PATCH.bat.
   You should see: "Patch applied successfully".

   Alternative to step 3: drag the game folder and drop it onto
   APPLY_PATCH.bat.

   If Windows SmartScreen shows a warning, click "More info" >
   "Run anyway". If you get a permission error (for example, the game
   is installed under C:\Program Files), right-click the .bat >
   "Run as administrator".

---------------------------------------------------------------------
 HOW TO APPLY - LINUX / STEAM DECK (Proton)
---------------------------------------------------------------------
1. Close the game and back up your files as described above.
2. In a terminal (on the Deck: Desktop Mode > Konsole), run:

     python3 restory_firmware_fix.py "/path/to/game/folder"

   Steam example:
     python3 restory_firmware_fix.py ~/.local/share/Steam/steamapps/common/ReStory*

---------------------------------------------------------------------
 AFTER APPLYING
---------------------------------------------------------------------
Start the game and load your save. Put the device on the work mat,
fully assembled and cleaned (ideal quality), then open UNLOCK-TOOLKIT on
the computer. It should now connect normally and let you update the
firmware.

---------------------------------------------------------------------
 HOW TO REMOVE
---------------------------------------------------------------------
Windows: double-click REMOVE_PATCH.bat.
Linux:   python3 restory_firmware_fix.py --restore "/path/to/game/folder"
Or, on Steam: Properties > Installed Files > Verify integrity of game files.

NOTES
- A game update, or verifying the game files on Steam, undoes the patch.
  Just apply it again.
- Remove the patch once the developers fix the bug officially.
- Running the patcher twice is safe: it detects that the patch is
  already applied.
