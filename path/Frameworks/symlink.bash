#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'

set -x

XCODE_PATH=$1

if [[ -z $XCODE_PATH ]]; then
  echo "USAGE: $0 [Xcode.app path]"
  exit 1
fi

DST_DIR="$(basename "${XCODE_PATH%.*}")"
if [[ -d "$DST_DIR" ]]; then
  rm -rf "$DST_DIR"
fi
mkdir -p "$DST_DIR"

for d in $(dirname "$(find "$XCODE_PATH/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/Frameworks" -maxdepth 1 -type d -or -type l)"); do
  if [[ -d "$d/Headers" ]]; then
    command ln -fs "$d/Headers" "$DST_DIR/$(printf $(basename $d) | awk -F. '{print $1}')"
  fi

  if [[ -d "$d/ApplicationServices.framework/Versions/A/Frameworks" ]]; then
    for dd in $(find "$d/ApplicationServices.framework/Versions/A/Frameworks" -maxdepth 4 -type d -name 'Headers'); do
      if [[ ! -d "$DST_DIR/$(basename $(echo $dd | awk -F. '{print $5}'))" ]] && [[ -d "$dd" ]]; then
        command ln -fs "$dd" "$DST_DIR/$(basename $(echo $dd | awk -F. '{print $5}'))"
      fi
    done
  fi

  if [[ -d "$d/CoreServices.framework/Versions/A/Frameworks" ]]; then
    for dd in $(find "$d/CoreServices.framework/Versions/A/Frameworks" -maxdepth 4 -type d -name 'Headers'); do
      if [[ ! -d "$DST_DIR/$(basename $(echo $dd | awk -F. '{print $5}'))" ]] && [[ -d "$dd" ]]; then
        command ln -fs "$dd" "$DST_DIR/$(basename $(echo $dd | awk -F. '{print $5}'))"
      fi
    done
  fi

  if [[ -d "$d/Carbon.framework/Versions/A/Frameworks" ]]; then
    for dd in $(find "$d/ApplicationServicesCarbon.framework/Versions/A/Frameworks" -maxdepth 4 -type d -name 'Headers'); do
      if [[ ! -d "$DST_DIR/$(basename $(echo $dd | awk -F. '{print $5}'))" ]] && [[ -d "$dd" ]]; then
        command ln -fs "$dd" "$DST_DIR/$(basename $(echo $dd | awk -F. '{print $5}'))"
      fi
    done
  fi
done

for d in $(find "$XCODE_PATH/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/Library/PrivateFrameworks" -maxdepth 1 -type d -or -type l); do
  if [[ -d "$d/Headers" ]]; then
    command ln -fs "$d/Headers" "$DST_DIR/$(printf $(basename $d) | awk -F. '{print $1}')"
  fi
done
