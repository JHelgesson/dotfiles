#!/usr/bin/env bash
set -euo pipefail

domain="com.pilotmoon.scroll-reverser"

# Scroll Reverser works on top of macOS's global "natural scrolling" setting.
# These shared defaults assume natural scrolling stays enabled in macOS, then
# reverse only mouse scrolling while leaving the trackpad natural.
defaults write "$domain" InvertScrollingOn -bool true
defaults write "$domain" ReverseTrackpad -bool false
defaults write "$domain" ReverseMouse -bool true
defaults write "$domain" ReverseY -bool true
defaults write "$domain" ReverseX -bool false
