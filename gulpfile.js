var path = require('path');
var mkdirp = require('mkdirp-then');
var gulp = require('gulp');
var mocha = require('gulp-mocha');
var concat = require('gulp-concat');
var chmod = require('gulp-chmod');
var rename = require('gulp-rename');
var minifyCSS = require('gulp-minify-css');
var gzip = require('gulp-gzip');

var buildDir = "dist";

gulp.task('default', ['build']);
gulp.task('build', ['min-css', 'build-gzip']);

// test are currently not run
//gulp.task('test', ['test-mocha']);
//gulp.task('test-mocha', function () {
//    return gulp.src('./test/mocha/**/*.js', {read: false})
//        .pipe(mocha({reporter: 'spec',
//                    ui: "qunit",
//                    useColors: false
//                    }));
//});
//
//gulp.task('watch-mocha', ['test-mocha'], function() {
//   gulp.watch(['./src/**/*.js', './test/**/*.js'], ['test-mocha']);
//});

gulp.task('css',['init'], function () {
    return gulp.src('./css/*.css')
      .pipe(concat('msa.css'))
      .pipe(chmod(644))
      .pipe(gulp.dest(buildDir));
});

gulp.task('build-gzip', ['build-gzip-js', 'build-gzip-css']);
gulp.task('build-gzip-js', function() {
   return gulp.src(path.join(buildDir, "msa.js"))
     .pipe(gzip({append: false, gzipOptions: { level: 9 }}))
     .pipe(rename("msa.min.gz.js"))
     .pipe(gulp.dest(buildDir));
});
gulp.task('build-gzip-css', ['min-css'], function() {
  return gulp.src(path.join(buildDir, "msa.min.css"))
    .pipe(gzip({append: false, gzipOptions: { level: 9 }}))
    .pipe(rename("msa.min.gz.css"))
    .pipe(gulp.dest(buildDir));
});

gulp.task('min-css',['css'], function () {
   return gulp.src(path.join(buildDir,"msa.css"))
   .pipe(minifyCSS())
   .pipe(rename('msa.min.css'))
   .pipe(chmod(644))
   .pipe(gulp.dest(buildDir));
});

gulp.task('init', function() {
  return mkdirp(buildDir)
});
