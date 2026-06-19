# PLAY STORE CHECKLIST — Jungle Escape: Lost Path

## Pre-Export (Godot Editor)

- [ ] Open Project → Export → Add Android preset
- [ ] Set package name: `com.yourcompany.jungleescape`  
      *(replace "yourcompany" with your actual name/studio)*
- [ ] Set version code: `1`
- [ ] Set version name: `0.1.0`
- [ ] Min SDK: 24 (Android 7.0)
- [ ] Target SDK: 34 (required by Play Store)
- [x] Set app icon: `res://assets/sprites/ui/icon.png` (1024×1024 PNG)
- [ ] Set landscape/portrait: **Portrait** (already set in project.godot)
- [ ] Configure signing: Project → Export → Android → Keystores tab
  - [ ] Generate release keystore (keep it safe — cannot re-upload without it)
  - [ ] Never commit keystore or passwords to git

## Android SDK Setup (one-time)

- [ ] Install Android Studio or standalone Android SDK
- [ ] Install JDK 17
- [ ] In Godot: Editor → Editor Settings → Export → Android
  - [ ] Set Android SDK path
  - [ ] Set JDK path
- [ ] Run `gradlew` build once to verify setup

## Build

- [ ] Click Export Project in Godot export dialog
- [ ] Choose **Android App Bundle (.aab)** for Play Store
- [ ] Choose **APK** for direct device testing
- [ ] Test the APK on at least one real Android device

## Play Console Setup

- [ ] Create Google Play Console account (one-time $25 fee)
- [ ] Create new app: "Jungle Escape: Lost Path"
- [ ] Set default language: English
- [ ] Set app category: Puzzle

## Store Listing

- [ ] App name: `Jungle Escape: Lost Path` (max 50 chars)
- [ ] Short description (max 80 chars):
      `Swipe your way through jungle puzzles. Collect, unlock, escape!`
- [ ] Full description (4000 chars max) — describe gameplay, worlds, offline support
- [ ] App icon: 512×512 PNG (no alpha)
- [ ] Feature graphic: 1024×500 PNG
- [ ] Screenshots: minimum 2 phone screenshots (16:9 or 9:16)
- [ ] Content rating: Complete IARC questionnaire (expect "Everyone")

## Privacy & Compliance

- [ ] Privacy policy URL required (even for apps with no data collection)
      — Create a simple policy page (Google Sites, GitHub Pages, etc.)
- [ ] Declare data collection honestly in Data Safety section
- [ ] If using Firebase Auth: declare account creation, email
- [ ] If showing ads later: declare advertising ID usage
- [ ] Permissions audit: remove any unused permissions from AndroidManifest
      — Game currently needs: INTERNET (optional, for future cloud), VIBRATE

## Pre-Launch Testing

- [ ] Internal testing track: upload first AAB
- [ ] Add at least 1 internal tester
- [ ] Test: first launch offline (airplane mode)
- [ ] Test: complete a level
- [ ] Test: save and relaunch (progress preserved)
- [ ] Test: level map shows correct unlock state
- [ ] Test: settings (sound off/on)
- [ ] Test: no crashes on rotation / back button
- [ ] Test: screen scales correctly on 5" and 6.5" screens

## Release

- [ ] Move from internal → closed testing → open testing → production
- [ ] Monitor crash reports in Play Console → Android Vitals
- [ ] Respond to reviews
- [ ] Plan v0.2.0 update with levels 21–50 and art assets

---
*Verify all requirements at https://play.google.com/console/about/guides/ before submitting.*
