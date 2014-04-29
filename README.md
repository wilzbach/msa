biojs-core
==========

Sandbox for a BioJS Core with AMD and CoffeeScript

### Architecture

- `development`
  * all javascript are loaded on demand
  * CoffeeScript is compiled by the Browser
  * demo views:
    * `development.html`
- `production`
  * all sources are bundled to one JS file (`build/biojs.js`)
  * CoffeeScript is compiled by R.js
  - demo views
    - [`production.html`](http://jsfiddle.net/spicytie/KTLLW/)
      * users has an AMD loader (RequireJS). BioJS is loaded as a AMD dependency.
    - [`production-non-amd.html`](http://jsfiddle.net/spicytie/xLsya/)
      * users has no AMD loader. BioJS automatically uses almond and registers as global variable

Click the links for an interactive demo for a possible production code.

### How to run

You need either Java or node to compile the project.

with node:
```
node js/libs/r.js -o build.js
```

with Java:
```
java -classpath jars/rhino.jar:jars/compiler.jar org.mozilla.javascript.tools.shell.Main js/libs/r.js -o build.js
```

### Used libraries

* [coffeescript](https://github.com/jashkenas/coffee-script)
* [require.js](https://github.com/jrburke/requirejs)
* [require-cs](https://raw.githubusercontent.com/jrburke/require-cs/latest/cs.js)
* [r.js](https://github.com/jrburke/r.js/)
* [almond](https://github.com/jrburke/almond)
