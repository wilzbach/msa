var gulp = require('gulp');
var mochaPhantomJS = require('gulp-mocha-phantomjs');
var mocha = require('gulp-mocha');
var watch = require('gulp-watch');
var run = require('gulp-run');
var rename = require('gulp-rename');
var gutil = require('gulp-util');
var uglify = require('gulp-uglify');
var coffeelint = require('gulp-coffeelint');
require('shelljs/global');

var docco = require("gulp-docco");

// browserify 
var browserify = require('browserify');
var coffeify = require("coffeeify");
var watchify = require('watchify')
var source = require('vinyl-source-stream'); // converts node streams into vinyl streams
var streamify = require('gulp-streamify'); // converts streams into buffers (legacy support for old plugins)

// css
var minifyCSS = require('gulp-minify-css');

// path stuff
var chmod = require('gulp-chmod');
var del = require('del');
var mkdirp = require('mkdirp');
var path = require('path');
var join = path.join;
var concat = require('gulp-concat');
var gzip = require('gulp-gzip');

// watchify
var watchify = require("watchify");
var deepcopy = require("deepcopy");

var mochaSelenium = require('gulp-mocha-selenium');
var phantomRunner = require('./test/perf/run');

// for mocha
require('coffee-script/register');

var outputFile = "msa";
var buildDir = "build";
var browserFile = "./browser";

var paths = {
  scripts: ['src/**/*.coffee'],
  testCoffee: ['./test/phantom/index.coffee']
};

var browserifyOptions =  {
  extensions: ['.coffee'],
  hasExports: true
};

var packageConfig = require('./package.json');

gulp.task('default', ['clean','test','lint','build']);

gulp.task('test-fast', ['test-mocha','test-phantom'],function () {
  return true;
});

gulp.task('test', ['test-fast','test-perf'],function () {
  return true;
});

gulp.task('build', ['min-css','build-browser','build-browser-min', 'build-gzip'],function () {
  return true;
});


// browserify debug
gulp.task('build-browser',['init', 'css'], function() {
  //gulp.src(outputFilePath).pipe(clean());

  var dBrowserifyOptions = deepcopy(browserifyOptions);
  dBrowserifyOptions["debug"] = true;

  var b = browserify(dBrowserifyOptions);
  makeBundle(b);
  return b.bundle()
    .pipe(source(outputFile + ".js"))
    .pipe(chmod(644))
    .pipe(gulp.dest(buildDir));
});

// browserify min
gulp.task('build-browser-min',['init', 'css'], function() {
  var b = browserify(browserifyOptions);
  makeBundle(b);
  return b.bundle()
    .pipe(source(outputFile + ".min.js"))
    .pipe(streamify(uglify()))
    .pipe(chmod(644))
    .pipe(gulp.dest(buildDir));
});

/*
gulp.task('build-browser-closure',['init', 'css'], function() {
  var b = browserify(browserifyOptions);
  makeBundle(b);
  var closureCompiler = require('gulp-closure-compiler');
  return b.bundle()
    .pipe(source(outputFile + ".min.js"))
    .pipe(streamify(uglify()))
    .pipe(closureCompiler({
      compilerPath: './node_modules/closurecompiler/compiler/compiler.jar',
      fileName: 'build.js'
    }))
    .pipe(chmod(644))
    .pipe(gulp.dest(buildDir));
});
*/
 
gulp.task('build-gzip-js', ['build-browser','build-browser-min'], function() {
   return gulp.src(join(buildDir, outputFile + ".min.js"))
     .pipe(gzip({append: false, gzipOptions: { level: 9 }}))
     .pipe(rename(outputFile + ".min.gz.js"))
     .pipe(gulp.dest(buildDir));
});
gulp.task('build-gzip-css', ['min-css'], function() {
  return gulp.src(join(buildDir, "msa.min.css"))
    .pipe(gzip({append: false, gzipOptions: { level: 9 }}))
    .pipe(rename("msa.min.gz.css"))
    .pipe(gulp.dest(buildDir));
});

gulp.task('build-gzip', ['build-gzip-js', 'build-gzip-css']);

gulp.task('build-test', function() {
  return buildTest('./test/phantom/index.coffee', './test/all_test.js');
});

gulp.task('build-perf', function() {
  return buildTest('./test/perf/index.coffee', './test/perf/all.js');
});

gulp.task('test-phantom', ["build-test"], function () {
  return gulp
  .src('./test/index.html')
  .pipe(mochaPhantomJS());
});

gulp.task('test-perf', ["build-perf"], function () {
  return gulp
  .src('./test/perf/index.html')
  .pipe(phantomRunner());
});

gulp.task('test-mocha', function () {
    return gulp.src('./test/mocha/**/*.coffee', {read: false})
        .pipe(mocha({reporter: 'spec',
                    ui: "qunit",
                    useColors: false,
                    compilers: "coffee:coffee-script/register"}));
});

gulp.task('watch-mocha', function() {
   // watch coffee files
  gulp.run('test-mocha');
   gulp.watch(['./src/**/*.coffee', './test/**/*.coffee'], function() {
     gulp.run('test-mocha');
   });
});

// runs the mocha test in your browser
gulp.task('test-mocha-selenium', function () {
    return gulp.src('./test/mocha/**/*.coffee', {read: false})
        .pipe(mochaSelenium({reporter: 'spec',
                    ui: "qunit",
                    compilers: "coffee:coffee-script/register"}));
});

gulp.task('doc', ["init"], function () {
  return gulp.src("./src/**/*.coffee")
    .pipe(docco())
    .pipe(gulp.dest(join(buildDir, 'doc')));
});

gulp.task('lint', function () {
    return gulp.src('./src/**/*.coffee')
        .pipe(coffeelint("coffeelint.json"))
        .pipe(coffeelint.reporter());
});

gulp.task('css',['init'], function () {
    return gulp.src('./css/*.css')
      .pipe(concat('msa.css'))
      .pipe(chmod(644))
      .pipe(gulp.dest(buildDir));
});

gulp.task('min-css',['css'], function () {
   return gulp.src(join(buildDir,"msa.css"))
   .pipe(minifyCSS())
   .pipe(rename('msa.min.css'))
   .pipe(chmod(644))
   .pipe(gulp.dest(buildDir));
});

gulp.task('watch', function() {
  var util = require('gulp-util');

  var opts = deepcopy(browserifyOptions);
  opts.debug = true;
  opts.cache = {};
  opts.packageCache = {};

  var b = browserify(opts);
  makeBundle(b);

  function rebundle(){
    b.bundle()
    .on("error", function(error) {
      util.log(util.colors.red("Error: "), error);
     })
    .pipe(source(outputFile + ".js"))
    .pipe(chmod(644))
    .pipe(gulp.dest(buildDir));
  }

  var watcher = watchify(b);
  watcher.on("update", rebundle)
   .on("log", function(message) {
      util.log("Refreshed:", message);
  });
  return rebundle();
});

function makeBundle(b){
  b.transform(coffeify);
  b.transform('cssify');
  b.add(browserFile, {expose: packageConfig.name});
  packageConfig.browserify.exclude.forEach(function(e){
    b.exclude(e);
  });
  if(packageConfig.sniper !== undefined && packageConfig.sniper.exposed !== undefined){
    for(var i=0; i<packageConfig.sniper.exposed.length; i++){
      b.require(packageConfig.sniper.exposed[i]);
    }
  }
  return b;
}

gulp.task('watch-test', function() {
   // watch coffee files
   gulp.watch(['./src/**/*.coffee', './test/**/*.coffee'], function() {
     gulp.run('test');
   });
});

// be careful when using this task.
// will remove everything in build
gulp.task('clean', function() {
  del.sync(buildDir);
  gulp.run('init');
});

// just makes sure that the build dir exists
gulp.task('init', function() {
  mkdirp(buildDir, function (err) {
    if (err) console.error(err)
  });
});


function buildTest(name, dest){
  // compiles all coffee tests to one file for mocha
  del.sync(dest);

  var destDir = path.dirname(dest);
  var destBase = path.basename(dest);

  var dBrowserifyOptions = deepcopy(browserifyOptions);
  dBrowserifyOptions["debug"] = true;

  var b = browserify(dBrowserifyOptions);
  b.transform(coffeify);
  b.add(name, {expose: packageConfig.name});
  return b.bundle()
    .on('error', gutil.log)
    .on('error', gutil.beep)
    .pipe(source(destBase))
    .pipe(gulp.dest(destDir));
}
