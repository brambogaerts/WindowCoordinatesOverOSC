# WindowCoordinatesOverOSC

A Processing tool to send normalized MacOS window coordinates and sizes over OSC.
https://github.com/brambogaerts/WindowCoordinatesOverOSC

## What it does

It uses AppleScript to get the position and size of every window on screen, then gets the total (multiple monitor) screen size and uses this to normalize the position and size of the first four windows. It then sends these coordinates in the form X1, Y1, W1, H1, X2, Y2, W2, etc. The default port it sends to is 6448. I tested it out using Wekinator and trained a model that controls the pitch and volume of four tones in Max MSP.

## How to run

Use Processing, make sure you have OscP5 installed. Only works on MacOS. You might need to set some permissions with the security features of Catalina. It should ask for these permissions when you run the sketch for the first time.

## Known issues

Only updates every few seconds (AppleScript takes a long time to get results). Some smoothing between the values would therefore be nice.