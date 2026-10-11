# ReStory: Chill Electronics Repairs - "Update firmware" fix

Fixes the bug where the **UNLOCK-TOOLKIT** app refuses to update the firmware of the **Guitar Legend** controller, leaving the order stuck.

**[Download the latest release](https://github.com/nemonox/restory-guitar-firmware-fix/releases/latest)**

## The problem

Some orders require the **UPDATE FIRMWARE** service, but the in-game UNLOCK-TOOLKIT shows:

```
CONNECTING DEVICE: NOT POSSIBLE FOR THIS DEVICE
CHECKING DEVICE: UNABLE TO CHECK
```

## Cause

This is a bug in the game. The UNLOCK-TOOLKIT content table only has data for three device categories: console, phone and laptop. The guitar is flagged as hackable, but its category (`Household`) is missing from that table, so the app rejects the device. The game log (`Player.log`) shows:

```
HackingContentTable not contains data for category Household
```

## What the patch does

It changes **23 bytes** in `Restory_Data\Managed\Restory.Assembly.dll`, inside `HackingContentTable.IsTableContainsDataForDeviceCategory`. When a device category is missing from the table, the app now uses the console content instead of rejecting the device.

- Your save file is not touched.
- A backup is created automatically (`Restory.Assembly.dll.bak`).
- No game files are distributed: the patcher modifies your own copy.
- The scripts are plain text, so you can read them before running.

Tested on game version **1.0.005r**. If a game update changes this code, the patcher reports `Incompatible game version` and leaves the file alone. Newer official updates reportedly fix this bug, so you only need the patch if you're on an older version.

## Before you start: back up your files

Close the game, then copy these folders somewhere safe:

1. `<game folder>\Restory_Data\Managed` (or the whole game folder, to be extra safe)
2. Your saves (the patch doesn't touch them, but it's good practice):
   - Windows: `%USERPROFILE%\AppData\LocalLow\Mandragora\Restory`
   - Linux / Steam Deck (Proton): `<Steam library>/steamapps/compatdata/<game id>/pfx/drive_c/users/steamuser/AppData/LocalLow/Mandragora/Restory`

## How to apply

### Windows

1. Close the game and back up your files.
2. Extract the `ReStory-FirmwareFix` folder **inside the game folder** (next to `Restory.exe`).
3. Double-click `APPLY_PATCH.bat`. You should see `Patch applied successfully`.

Alternatively, drag the game folder and drop it onto `APPLY_PATCH.bat`.

If SmartScreen shows a warning, click **More info > Run anyway**. If you get a permission error, right-click the `.bat` file and choose **Run as administrator**.

### Linux / Steam Deck

```sh
python3 restory_firmware_fix.py "/path/to/game/folder"
```

## After applying

Start the game and put the device on the work mat, fully assembled and cleaned. Then open UNLOCK-TOOLKIT on the in-game computer. It should now connect and let you update the firmware.

## How to remove

- Windows: double-click `REMOVE_PATCH.bat`
- Linux: `python3 restory_firmware_fix.py --restore "/path/to/game/folder"`
- Steam: Properties > Installed Files > Verify integrity of game files

A game update, or verifying the game files, undoes the patch, so apply it again if needed. Running the patcher twice is safe.
