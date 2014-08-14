var gulp = require('gulp');
var browserify = require('gulp-browserify');
var mochaPhantomJS = require('gulp-mocha-phantomjs');
var mocha = require('gulp-mocha');
var watch = require('gulp-watch');
var run = require('gulp-run');
var rename = require('gulp-rename');
var gutil = require('gulp-util');
var uglify = require('gulp-uglify');
var coffeelint = require('gulp-coffeelint');
require('shelljs/global');

// css
var sass = require('gulp-ruby-sass'); // gulp-sass is also available (faster, feature-less)
var minifyCSS = require('gulp-minify-css');

// path stuff
var chmod = require('gulp-chmod');
var clean = require('gulp-clean');
var mkdirp = require('mkdirp');
var path = require('path');
var join = path.join;
var concat = require('gulp-concat');

var mochaSelenium = require('gulp-mocha-selenium');

// for mocha
require('coffee-script/register');

var outputFile = "biojs_vis_msa";
var buildDir = "build";
var browserFile = "browser.js";

var paths = {
  scripts: ['src/**/*.coffee'],
  testCoffee: ['./test/phantom/index.coffee']
};

var browserifyOptions =  {
  transform: ['coffeeify'],
  extensions: ['.coffee'],
};


gulp.task('default', ['clean','test','lint','build', 'codo']);

gulp.task('test', ['test-mocha','test-phantom'],function () {
  return true;
});

gulp.task('build', ['css','build-browser','build-browser-min'],function () {
  return true;
});


gulp.task('build-browser',['init'], function() {
  // browserify
  var fileName = outputFile + ".js";
  gulp.src(join(buildDir,fileName)).pipe(clean());

  dBrowserifyOptions = {};
  for( var key in browserifyOptions )
     dBrowserifyOptions[ key ] = browserifyOptions[ key ];
  dBrowserifyOptions["debug"] = true;
  return gulp.src(browserFile)
  .pipe(browserify(dBrowserifyOptions))
  .pipe(rename(fileName))
  .pipe(gulp.dest(buildDir));
});

gulp.task('build-browser-min',['init'], function() {
  // browserify
  var fileName = outputFile + ".min.js";
  gulp.src(join(buildDir,fileName)).pipe(clean());

  return gulp.src(browserFile)
  .pipe(browserify(browserifyOptions))
  .pipe(uglify())
  .pipe(rename(fileName))
  .pipe(gulp.dest(buildDir));
});

gulp.task('build-test', function() {
  // compiles all coffee tests to one file for mocha
  gulp.src('./test/all_test.js').pipe(clean());
  return gulp.src(paths.testCoffee,  { read: false })
    .pipe(browserify(browserifyOptions))
    .on('error', gutil.log)
    .on('error', gutil.beep)
    .pipe(concat('all_test.js'))
    .pipe(gulp.dest('test'));
});

gulp.task('test-phantom', ["build-test"], function () {
  return gulp
  .src('./test/index.html')
  .pipe(mochaPhantomJS());
});

gulp.task('test-mocha', function () {
    return gulp.src('./test/mocha/**/*.coffee', {read: false})
        .pipe(mocha({reporter: 'spec',
                    ui: "qunit",
                    useColors: false,
                    compilers: "coffee:coffee-script/register"}));
});

// runs the mocha test in your browser
gulp.task('test-mocha-selenium', function () {
    return gulp.src('./test/mocha/**/*.coffee', {read: false})
        .pipe(mochaSelenium({reporter: 'spec',
                    ui: "qunit",
                    compilers: "coffee:coffee-script/register"}));
});

gulp.task('lint', function () {
    gulp.src('./src/**/*.coffee')
        .pipe(coffeelint("coffeelint.json"))
        .pipe(coffeelint.reporter());
});


gulp.task('codo', ['init'],function () {
  run('codo src -o build/doc ').exec(); 
});


gulp.task('sass',['init'], function () {
    var opts = checkForSASS();
    opts.sourcemap = true;

    gulp.src('./css/msa.scss')
      .pipe(sass(opts))
      //.pipe(rename('msa.css'))
      .pipe(chmod(644))
      .pipe(gulp.dest(buildDir));
});

gulp.task('css',['sass'], function () {
    if(checkForSASS() !== undefined){
      gulp.src(join(buildDir,"msa.css"))
      .pipe(minifyCSS())
      .pipe(rename('msa.min.css'))
      .pipe(chmod(644))
      .pipe(gulp.dest(buildDir));
    }
});

gulp.task('watch', function() {
   // watch coffee files
   gulp.watch(['./src/**/*.coffee', './test/**/*.coffee'], function() {
     gulp.run('test');
   });
});

// be careful when using this task.
// will remove everything in build
gulp.task('clean', function() {
  gulp.src(buildDir).pipe(clean());
  gulp.run('init');
});

// just makes sure that the build dir exists
gulp.task('init', function() {
  mkdirp(buildDir, function (err) {
    if (err) console.error(err)
  });
});


// -----------------------------------------
// SASS part

// check whether there is a way to run SASS
function checkForSASS(){
  if (exec('sass --help 2> /dev/null',{silent:true}).code !== 0) {
    var checkBundle = checkBundleExec();
    if( checkBundle !== undefined){
      return checkBundle;
    }else{
      echo('Error: No SASS installed. Trying to fix. You will need bundler to proceed.');
      installBundle();
      return checkBundleExec();
    }
  }
  return {};
}

function checkBundleExec(){
    if (exec('bundle exec sass --help',{silent:true}).code === 0) {
      return { bundleExec: true };
    } else {
      return undefined;
    }
}

function installBundle(){
    if(exec("bundle install --path .gems").code !== 0){
      echo('Install ruby and bundle');
      return false;
    } 
    return true;
}
