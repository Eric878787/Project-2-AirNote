<p align="center">
    
<img width="1268" alt="Screen Shot 2022-05-17 at 11 47 35 AM" src="https://user-images.githubusercontent.com/94897201/170625354-27454bb3-70a4-49bf-afda-2db20f3cbd48.png">
    
</p>   

<p align="left">
    <img src="https://img.shields.io/badge/platform-iOS-lightgray">
    <img src="https://img.shields.io/badge/release-v1.0.2-green">
</p>

# AirNote - Make it an easier way to learn, to create personal learning materials’ collections.

AirNote is an app provides user a platform to create, share and discuss notes.

<br>

<p align="left">
    <a href="https://apps.apple.com/tw/app/airnote/id1619738706"><img src="https://i.imgur.com/NKyvGNy.png"></a>
</p>

## Table of Contents
* [Features](#Features)
* [Highlights](#Highlights)
* [Techniques](#Techniques)
* [Libraries](#Libraries)
* [Requirement](#Requirement)
* [Release Notes](#Release-Notes)
* [Author](#Author)



## Features

### Browsing Notes
Easily browse and save your favorites notes with categories or keywords.
<p align="center">

 <img src="https://user-images.githubusercontent.com/94897201/170649704-d05efa75-679f-480a-b8c5-6abb8827c798.png" width="auto" height="500">

</p>

### Exploring Study Groups
Explore nearby study groups you interested in with map.
<p align="center">

<img src="https://user-images.githubusercontent.com/94897201/170646786-a3ab2db8-cd31-493e-ba45-d37ec9f1e7eb.png" width=auto height="500">

</p>

### Create Content
Create your own notes and groups with texts, images or even drawing pad.
<p align="center">

<img src="https://user-images.githubusercontent.com/94897201/170647484-d786bbc5-a5af-45ed-b5ab-72c554640eb2.png" width=auto height="500">

</p>

### Chat Room
Pick up a topic, disscuss with other members in your study group.
<p align="center">

<img src="https://user-images.githubusercontent.com/94897201/170647940-5b3d2481-ad83-47f9-9e0c-9f590b571472.png" width=auto height="500">

</p>

### Following
Follow creators with contents catch your eyes.
<p align="center">

<img src="https://user-images.githubusercontent.com/94897201/170648464-4b3de286-7d21-4465-91e8-64fe08df14a2.png" width=auto height="500">

</p>

## Techniques

* Implemented `MVC` architecture to separate responsibilities of objects.
* Applied `Firebase` Cloud Firestore as remote storage database.
* Completed `CRUD` functions with `Singleton` pattern to create a unified access point for the whole app.
* Applied `Auto Layout` programmatically as well as Interface Builder to configure self-resizing layouts in multiple screen sizes.
* Handled multi-thread management via `Dispatch Group` to optimize efficiency on uploading content to remote storage. 
* Imported `Google ML Kit Model` to recognize texts on images, dynamically tagging on each content to provide users an efficient way to search content.
* Implemented `MapKit` to build a map view and annotations to visualize contents and optimize interactivity, which provide users more smooth experience. 

<br>

## Libraries
- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [IQKeyboardManagerSwift](https://github.com/hackiftekhar/IQKeyboardManager)
- [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD)
- [SwiftLint](https://github.com/realm/SwiftLint)
- [Google ML Kit](https://github.com/googlesamples/mlkit)

## Requirement
- [x] Xcode 13.3.1
- [x] Swift 5.
- [x] iOS 14 .0 or higher.

## Version
> 1.0.1

## Release Notes
| Version | Date | Notes |
| -------- | -------- | -------- |
| 1.0.1   | 2021.11.20     | New features of following users & delete messages   |
| 1.0.0   | 2022.05.13     | Released in App Store   |

## Author
- Eric Chung | eric202302@gmail.com
