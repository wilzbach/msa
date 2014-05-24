({
  baseUrl: 'js',

out: 'build/biojs.js',
//optimize: 'uglify2',
optimize: "none",

name: 'libs/almond',
include: ['main'],
insertRequire: ['main'],

exclude: ['coffee-script'],
stubModules: ['cs', 'text'],

// enables compatibility with non-AMD projects
//wrap: true,
wrap: {
  startFile: 'config/start.frag',
  endFile: 'config/end.frag',
},

paths: {
  backbone: 'libs/backbone-amd',
jquery: 'libs/jquery',
cs: 'libs/cs',
'coffee-script': 'libs/coffee-script',
text: 'libs/text'
}
})
