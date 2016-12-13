
var gulp = require('gulp');
var livereload = require('gulp-livereload');
var sourcemaps = require('gulp-sourcemaps');
var source = require('vinyl-source-stream');
var buffer = require('vinyl-buffer');
var browserify = require('browserify');
var watchify = require('watchify');
var babelify = require('babelify');
var sass = require('gulp-sass');

const paths = {
  src: "./src",
  dst: "./public"
}

gulp.task('sass', function() {
  return gulp.src(`${paths.src}/*.scss`)
    .pipe(sass({
      outputStyle : 'expanded',
      includePaths: paths.src
    }))
    .pipe(gulp.dest(paths.dst));
});

function compile(watch) {
  var js_bundler = watchify(browserify(`${paths.src}/index.js`, { debug: true })
    .transform(babelify, { presets: ['es2015', 'react'] }));

  function js_rebundle() {
      return js_bundler
          .bundle()
          .on('error', function (err) {
              console.error(err);
              this.emit('end');
          })
          .pipe(source('build.js'))
          .pipe(buffer())
          .pipe(sourcemaps.init({loadMaps: true}))
          .pipe(sourcemaps.write('./'))
          .pipe(gulp.dest(paths.dst))
          .pipe(livereload({ start: true }));
  }

  if (watch) {
      js_bundler.on('update', function () {
          console.log('-> bundling...');
          js_rebundle();
      });

      js_rebundle()
  } else {
      js_rebundle().pipe(exit());
  }
}

function watch() {
  return compile(true);
};

gulp.task('build', function() { return compile(); });
gulp.task('watch', ['sass'], function() {
  gulp.watch(`${paths.src}/*.scss`, ['sass']);
  return watch();
});
// gulp.task('watch', function() { return watch(); });

gulp.task('default', ['watch']);