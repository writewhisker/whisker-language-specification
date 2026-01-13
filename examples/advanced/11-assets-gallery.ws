// WLS Assets Example
// Converted from v2-with-assets.whisker (JSON Format 2.0)
// Demonstrates asset management with images, audio, and video

@title: Assets Example
@author: Whisker Team
@version: 1.0.0
@ifid: 34567890-3456-4456-8456-345678901abc
@start: Gallery

@vars
  volume: 0.8
  currentMusic: ""

// Asset declarations (referenced throughout the story)
// Images: painting_01, sculpture_01, digital_art_01, digital_art_02,
//         digital_art_03, outdoor_installation, gallery_logo
// Audio: guide_narration, hall_echo, electronic_ambient, nature_sounds
// Video: artist_interview

:: Gallery
@tags: start, gallery
@onEnter: currentMusic = "ambient"

Welcome to the interactive gallery!

![Ancient Painting](asset://painting_01)

This ancient painting dates back centuries. The brushwork is exquisite.

+ [View sculpture exhibit] -> Sculpture
+ [Visit multimedia room] -> Multimedia
+ [Explore outdoor installation] -> Outdoor

:: Sculpture
The sculpture hall features modern metalwork.

![Modern Sculpture](asset://sculpture_01)

This piece represents the intersection of tradition and innovation.

+ [Listen to audio guide] -> AudioGuide
+ [Return to gallery] -> Gallery

:: AudioGuide
You activate the audio guide.

Playing narration...

[Audio: Gallery Narration](asset://guide_narration)

The narrator explains the history and meaning behind each sculpture in detail.

+ [Continue] -> Sculpture

:: Multimedia
@onEnter: currentMusic = "electronic"

Step into an immersive multimedia experience.

![Digital Art Display](asset://digital_art_01)

Watch the artist's statement:

[Video: Artist Interview](asset://artist_interview)

The room pulses with synchronized light and sound.

+ [View another digital piece] -> DigitalGallery
+ [Return to entrance] -> Gallery

:: DigitalGallery
The walls shimmer with ever-changing digital canvases.

![Abstract Digital Art](asset://digital_art_02)

![Generative Art](asset://digital_art_03)

Each piece responds to viewer presence and movement.

+ [Back] -> Multimedia

:: Outdoor
You step outside into the sculpture garden.

![Garden Installation](asset://outdoor_installation)

Natural sounds fill the air

[Audio: Birds and Wind](asset://nature_sounds)

The installation harmonizes with the natural environment.

+ [Photograph the installation] -> PhotoMode
+ [Return inside] -> Gallery

:: PhotoMode
You capture a beautiful photograph!

![Your Photo](asset://outdoor_installation)

Your photo has been saved to the gallery.

+ [Continue exploring] -> Outdoor
+ [Exit gallery] -> Exit

:: Exit
@tags: ending

Thank you for visiting our gallery!

![Gallery Logo](asset://gallery_logo)

We hope you enjoyed the experience. Visit again soon!

+ [Visit again] -> Gallery
