gulp = require 'gulp'
elm  = require 'gulp-elm'
plumber = require 'gulp-plumber'
uglify = require 'gulp-uglify'
watch = require 'gulp-watch'
shell = require 'gulp-shell'

swallowError = (error) ->
  console.log error.toString() ; this.emit 'end'

gulp.task 'default', ['testwatch', 'examplewatch']

gulp.task 'examplewatch', () ->
  gulp.watch('{src/**,examples/**}', ['example'])

gulp.task 'testwatch', () ->
  gulp.watch('{src/**,tests/**}', ['test'])

gulp.task 'example', ['index'], () ->
  elm.init()
  gulp.src('examples/Simple.elm')
    .pipe(plumber())
    .pipe(elm())
    .pipe(uglify())
    .on('error', swallowError)
    .pipe(gulp.dest('build/'))

gulp.task 'test', () ->
  elm.init()
  gulp.src('tests/*.elm')
    .pipe(plumber())
    .pipe(elm())
    .on('error', swallowError)
    .pipe shell ['elm-test tests/TestRunner.elm']

gulp.task 'index', () ->
  gulp.src('assets/{*.html,*.css}')
    .pipe(gulp.dest('build/'))
