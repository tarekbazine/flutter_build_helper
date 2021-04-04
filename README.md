# flutter_build_helper

A command-line tool which helps you to build and tag artifacts with ease.

## Guide

1. Installation

In `pubspec.yaml`, add:

```yml
dev_dependencies:
  flutter_build_helper: "^0.9.0"
```

2. Usage

```shell
flutter pub get
flutter pub run flutter_build_helper:main <OPTIONS>
```

with `<OPTIONS>` as :

- `--version=VERSION_NB` (mandatory)
- `--out-path=PATH` (optional) by default the output would be in `Documents` folder of the current user.
- `--apk` (optional flag) means build an apk also
- `--no-aab` (optional flag) means do not generate an aab

Examples :

```shell
flutter pub run flutter_build_helper:main --v=1.3.0+5 --apk
```

```shell
flutter pub run flutter_build_helper:main --v=4.0.9 --apk --no-aab --out-path="..."
```

---

## Road map

- [ ] --help option
- [ ] publish to Pub ( into in reddit )
- [ ] Ios build artifact
- [ ] A customizable step to edit stuff before build
- [ ] A customizable step to check stuff
- [ ] migrate to https://github.com/fluttercommunity

---

Feel free to star the repo if you like it. :)

