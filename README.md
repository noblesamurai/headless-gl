# gl
[![NPM](https://nodei.co/npm/gl.png?compact=true)](https://nodei.co/npm/gl/)
[![Travis CI](https://travis-ci.org/stackgl/headless-gl.svg?branch=master)](https://travis-ci.org/stackgl/headless-gl)
[![Appveyor](https://ci.appveyor.com/api/projects/status/github/stackgl/headless-gl?svg=true)](https://ci.appveyor.com/project/mikolalysenko/headless-gl)
[![js-standard-style](https://img.shields.io/badge/code%20style-standard-brightgreen.svg)](http://standardjs.com/)

`gl` lets you create a WebGL context in node.js without making a window or loading a full browser environment.

It aspires to fully conform to the [WebGL 1.0.3 specification](https://www.khronos.org/registry/webgl/specs/1.0.3/).

## Example

```javascript
//Create context
var width   = 64
var height  = 64
var gl = require('gl')(width, height, { preserveDrawingBuffer: true })

//Clear screen to red
gl.clearColor(1, 0, 0, 1)
gl.clear(gl.COLOR_BUFFER_BIT)

//Write output as a PPM formatted image
var pixels = new Uint8Array(width * height * 4)
gl.readPixels(0, 0, width, height, gl.RGBA, gl.UNSIGNED_BYTE, pixels)
process.stdout.write(['P3\n# gl.ppm\n', width, " ", height, '\n255\n'].join(''))
for(var i=0; i<pixels.length; i+=4) {
  for(var j=0; j<3; ++j) {
    process.stdout.write(pixels[i+j] + ' ')
  }
}
```

## Install
Installing headless-gl on a supported platform is a snap using one of the prebuilt binaries.  Just type,

```
npm install gl
```

And you are good to go!  If your system is not supported, then please see the [development](#system-dependencies) section on how to configure your build environment.

## API

### Context creation

#### `var gl = require('gl')(width, height[, options])`
Creates a new `WebGLRenderingContext` with the given parameters.

* `width` is the width of the drawing buffer
* `height` is the height of the drawing buffer
* `options` is an optional object whose properties are the context attributes for the WebGLRendering context

**Returns** A new `WebGLRenderingContext` object

### Extra methods

In addition to all of the usual WebGL methods, `headless-gl` adds the following two methods to each WebGL context in order to support some functionality which would not otherwise be exposed at the WebGL level.

#### `gl.resize(width, height)`
Resizes the drawing buffer of a WebGL rendering context

* `width` is the new width of the drawing buffer for the context
* `height` is the new height of the drawing buffer for the context

**Note** In the DOM, this method would implemented by resizing the canvas, which is done by modifying the `width/height` properties.

#### `gl.destroy()`
Destroys the WebGL context immediately, reclaiming all resources

**Note** For long running jobs, garbage collection of contexts is often not fast enough.  To prevent the system from becoming overloaded with unused contexts, you can force the system to reclaim a WebGL context immediately by calling `.destroy()`.

## System dependencies
For general information on building native modules, see the [`node-gyp`](https://github.com/nodejs/node-gyp) documentation.

#### Mac OS X

* [Python 2.7](https://www.python.org/)
* [XCode](https://developer.apple.com/xcode/)

#### Ubuntu/Debian

* [Python 2.7](https://www.python.org/)
* A GNU C++ environment (available via the `build-essential` package on `apt`)
* [libxi-dev](http://www.x.org/wiki/)
* Working and up to date OpenGL drivers
* [GLEW](http://glew.sourceforge.net/)

```
$ sudo apt-get install -y build-essential libxi-dev libglu1-mesa-dev libglew-dev
```

#### Windows

* [Python 2.7](https://www.python.org/)
* [Microsoft Visual Studio](https://www.microsoft.com/en-us/download/details.aspx?id=5555)
* d3dcompiler_47.dll should be in c:\windows\system32, but if isn't then you can find another copy in the deps/ folder
* (optional) A modern nodejs supporting es6 to run some examples https://iojs.org/en/es6.html

## FAQ

### Why use this thing instead of `node-webgl`?

Despite the name [node-webgl](https://github.com/mikeseven/node-webgl) doesn't actually implement WebGL - rather it gives you WebGL-flavored bindings to whatever OpenGL driver is configured on your system.  If you are starting from an existing WebGL application or library, this means you'll have to do a bunch of work rewriting your WebGL code and shaders to deal with all the idiosyncrasies and bugs present on whatever platforms you try to run on.  The upside though is that `node-webgl` exposes a lot of non-WebGL stuff that might be useful for games like window creation, mouse and keyboard input, requestAnimationFrame emulation, and some native OpenGL features.

`headless-gl` on the other hand just implements WebGL.  It is built on top of [ANGLE](https://bugs.chromium.org/p/angleproject/issues/list) and passes the full Khronos ARB conformance suite, which means it works exactly the same on all supported systems.  This makes it a great choice for running on a server or in a command line tool.  You can use it to run tests, generate images or perform GPGPU computations using shaders.

### Why use this thing instead of [electron](http://electron.atom.io/)?

Electron is fantastic if you are writing a desktop application or if you need a full DOM implementation.  On the other hand, because it is a larger dependency electron is more difficult to set up and configure in a server-side/CI environment. `headless-gl` is also more modular in the sense that it just implements WebGL and nothing else.  As a result creating a `headless-gl` context takes just a few milliseconds on most systems, while spawning a full electron instance can take upwards of 15 seconds. If you are using WebGL in a command line interface or need to execute WebGL on your server, `headless-gl` might be a better choice.

### Does headless-gl work in a browser?

Yes, with [browserify](http://browserify.org/).

### How are `<image>` and `<video>` elements implemented?

They aren't for now.  If you want to upload data to a texture, you will need to unpack the pixels into a `Uint8Array` and feed it into `texImage2D`.

### What extensions are supported?

See https://github.com/stackgl/headless-gl/issues/5 for current status.

### How can I use headless-gl with a continuous integration service?

`headless-gl` should work out of the box on most CI systems.  Some notes on specific CI systems:

* [CircleCI](https://circleci.com/): `headless-gl` should just work in the default node environment.
* [AppVeyor](http://www.appveyor.com/): Again it should just work
* [TravisCI](https://travis-ci.org/): Works out of the box on the OS X image.  For Linux VMs, you need to install mesa and xvfb.  To do this, create a file in the root of your main repo called `.travis.yml` and paste the following into it:

```
language: node_js
os: linux
sudo: required
dist: trusty
addons:
  apt:
    packages:
    - mesa-utils
    - xvfb
    - libgl1-mesa-dri
    - libglapi-mesa
    - libosmesa6
node_js:
  - '6'
before_script:
  - export DISPLAY=:99.0; sh -e /etc/init.d/xvfb start
```

### How can `headless-gl` be used on a headless Linux machine?

If you are running your own minimal Linux server, such as the one one would want to use on Amazon AWS or equivalent will likely not provide an X11 nor an OpenGL environment. To setup such an environment you can use those two packages:

1. [Xvfb](https://en.wikipedia.org/wiki/Xvfb) is a lightweight X11 server which provides a back buffer for displaying X11 application offscreen and reading back the pixels which were drawn offscreen. It is typically used in Continuous Integration systems. It can be installed on CentOS with `yum install -y Xvfb`, and comes preinstalled on Ubuntu.
2. [Mesa](http://www.mesa3d.org/intro.html) is the reference open source software implementation of OpenGL. It can be installed on CentOS with `yum install -y mesa-dri-drivers`, or `apt-get install libgl1-mesa-dev`. Since a cloud Linux instance will typically run on a machine that does not have a GPU, a software implementation of OpenGL will be required.

Interacting with `Xvfb` requires to start it on the background and to execute your `node` program with the DISPLAY environment variable set to whatever was configured when running Xvfb (the default being :99). If you want to do that reliably you'll have to start Xvfb from an init.d script at boot time, which is extra configuration burden. Fortunately there is a wrapper script shipped with Xvfb known as `xvfb-run` which can start Xvfb on the fly, execute your node program and finally shut Xvfb down. Here's how to run it:

    xvfb-run -s "-ac -screen 0 1280x1024x24” <node program>

### How should I set up a development environment for headless-gl?
After you have your [system dependencies installed](#system-dependencies), do the following:

1. Clone this repo: `git clone git@github.com:stackgl/headless-gl.git`
1. Switch to the headless gl directory: `cd headless-gl`
1. Initialize the angle submodule: `git submodule init`
1. Update the angle submodule: `git submodule update`
1. Install npm dependencies: `npm install`
1. Run node-gyp to generate build scripts: `npm run build`

Once this is done, you should be good to go!  A few more things

* To run the test cases, use the command `npm test`, or execute specific by just running it using node.
* On a Unix-like platform, you can do incremental rebuilds by going into the `build/` directory and running `make`.  This is **way faster** running `npm build` each time you make a change.

## License

See LICENSES
