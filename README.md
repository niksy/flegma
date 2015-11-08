# Flegma

Simple network bandwidth throttler. **Doesn’t work on OS X 10.10+.**

## Installation

Download binary and place it in the folder in your `$PATH`.

### Using [Homebrew](http://brew.sh)?

```bash
brew tap niksy/pljoska
brew install flegma
```

## Usage

```bash
flegma [-hv] [-t [edge|3g|NUMBER]] [OPTION|NUMBER]

Options:
  test       Run Speed Test to check current speed.
  stop       Stop throttling.
  edge       Use EDGE preset (speed throttled to 90 KB/s)
  3g         Use 3G preset (speed throttled to 380 KB/s)
  -t         Trap current shell and stop throttling on exit.
  -v         Display version.
  -h         Display this help and exit
```

## Acknowledgements

* [Macworld article on bandwidth throttling](http://hints.macworld.com/article.php?story=20080119112509736)
* [Throttle Bandwidth on Mac OS X](http://benlakey.com/2012/10/14/throttle-bandwidth-on-mac-os-x/)
* [PierceCommunications/osx-bandwidth-throttle](https://github.com/PierceCommunications/osx-bandwidth-throttle)
