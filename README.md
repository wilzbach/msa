biojs-core
==========

Sandbox for a BioJS Core with AMD and CoffeeScript

###

- `development`
  * all javascript are loaded on demand
  * CoffeeScript is compiled by the Browser
  * demo views:
    * `development.html`
- `production`
  * all sources are bundled to one JS file (`build/biojs.js`)
  * CoffeeScript is compiled by R.js
  - demo views
    - `production.html` 
      * users has an AMD loader (RequireJS). BioJS is loaded as a AMD dependency.
    - `production-non-amd.html` 
      * users has no AMD loader. BioJS automatically uses almond and registers as global variable


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
