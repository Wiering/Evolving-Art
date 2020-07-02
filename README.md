# Evolving-Art

This program generates a grid of images that randomly mutate over time. 
Every time the user clicks one of the images, that image is copied to all the others and they all start mutating from that point.

Each image is represented by a string of numbers. Each mutation is a change to one of those numbers. 

The images are meant to be size-independent, so if you maximize the window, you should get higher resolution versions of the same images (but generating larger images is slow).

The idea is that you could use such images or textures in a game and not have to store them as images, but have the generator create them when needed from the string of numbers (for that to work, you'd need to be able to save that string, which wasn't implemented here).

Written in 2004 using Delphi 5.

## Usage

Just run the program and keep clicking on the most interesting image (left mouse button).
After choosing an image, if you don't like any of the variations, press the right mouse button to start again from the last position you selected. You can also use the middle mouse button to go back to the position before that.

![screenshot1](https://github.com/Wiering/Evolving-Art/blob/master/screenshots/ea1.jpg?raw=true)

![screenshot1](https://github.com/Wiering/Evolving-Art/blob/master/screenshots/ea2.jpg?raw=true)

![screenshot1](https://github.com/Wiering/Evolving-Art/blob/master/screenshots/ea3.jpg?raw=true)

## Haxe version

This program has been rewritten in Haxe: https://github.com/Wiering/Random-Art-Evolver
