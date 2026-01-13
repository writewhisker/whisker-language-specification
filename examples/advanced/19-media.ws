@title: Media Embedding Demo
@author: WLS
@version: 1.0.0

-- WLS Gap 5: Media Embedding Demo
-- This story demonstrates image, audio, and video embedding

:: Start

# Media in Interactive Fiction

WLS supports rich media embedding to enhance your stories.

## Images

Here's a simple image:
![Forest scene](assets/images/forest.png)

And an image with attributes:
![Character portrait](assets/images/hero.png){width:150px align:right}

+ [See audio examples] -> Audio
+ [See video examples] -> Video
+ [End] -> END

:: Audio

## Audio

Background music:
[audio](assets/audio/ambient.mp3){loop autoplay volume:0.5}

Sound effect with controls:
[audio](assets/audio/click.wav){controls volume:0.8}

+ [Back to start] -> Start
+ [See video examples] -> Video

:: Video

## Video

Cutscene video:
[video](assets/video/intro.mp4){controls autoplay muted}

Video with poster image:
[video](assets/video/tutorial.webm){width:640px height:360px poster:assets/images/poster.png}

## Embedded Content

Interactive map widget:
[embed](widgets/map.html){width:100% height:400px}

+ [Back to start] -> Start
+ [End] -> END
