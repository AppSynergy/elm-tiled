var gulp = require('gulp');
var elm  = require('gulp-elm');
var plumber = require('gulp-plumber');
var uglify = require('gulp-uglify');
var watch = require('gulp-watch')

swallowError = function(error) {
  console.log(error.toString());
  this.emit('end');
}

gulp.task('default', ['elm', 'index']);


gulp.task('watch', function() {
  gulp.watch('{src/**,assets/**}', ['elm','index']);
});


gulp.task('elm', function() {
  elm.init();
  return gulp.src('src/Tiled.elm')
    .pipe(plumber())
    .pipe(elm())
    .pipe(uglify())
    .on('error', swallowError)
    .pipe(gulp.dest('build/'));
});


gulp.task('index', function() {
  return gulp.src('assets/{*.html,*.css}')
    .pipe(gulp.dest('build/'));
});
