### Empty/black screensaver for KDE
As KDE has no screensaver without turn off screen, then I made this script to create a black window fullscreen, and run it when idle. I set my custom screensaver like this:

Settings

- Power Management
  - Display & brightness
    - Automatically adjust after 2 minutes
    - Turn off screen: After 5 minutes
    - When locked: Turn off screen after 1 minute
  - Other Settings
    - When inactive: After 2 minutes
    - Execute: qml6 /Scripts/KDE_black_screensaver.qml
- Screen Locking
  - Lock screen automatically: Never
  - Enable: Lock on resume from suspend
