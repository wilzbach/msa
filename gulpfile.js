var gulp = require('gulp');
var concat = require('gulp-concat');
var browserify = require('gulp-browserify');
var mochaPhantomJS = require('gulp-mocha-phantomjs');
var mocha = require('gulp-mocha');
var watch = require('gulp-watch');
var run = require('gulp-run');

// for mocha
require('coffee-script/register');

var paths = {
  scripts: ['client/js/**/*.coffee', '!client/external/**/*.coffee'],
  testCoffee: ['./test/tests/**/*.coffee']
};

var browserifyOptions =  {
  transform: ['coffeeify'],
  extensions: ['.coffee']
};

gulp.task('build-test', function() {
  // compiles all coffee tests to one file for mocha
  return gulp.src(paths.testCoffee,  { read: false })
  .pipe(browserify(browserifyOptions))
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
                    compilers: "coffee:coffee-script/register"}));
});

gulp.task('test', ['test-mocha','test-phantom'],function () {
  return true;
});

var coffeelint = require('gulp-coffeelint');

gulp.task('lint', function () {
    gulp.src('./src/**/*.coffee')
        .pipe(coffeelint("coffeelint.json"))
        .pipe(coffeelint.reporter());
});


gulp.task('codo', function () {
  run('codo src -o build/doc').exec()  
    .pipe(gulp.dest('output'))    
});
