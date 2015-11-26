gulp = require 'gulp'
coffee = require 'gulp-coffee'
gutil = require 'gulp-util'
sass = require 'gulp-sass'
autoprefixer = require 'gulp-autoprefixer'
browserSync = require('browser-sync').create()
sourcemaps = require 'gulp-sourcemaps'
preprocess = require 'gulp-preprocess'


gulp.task 'default', ['serve', 'production'], ->
  console.log 'gulp default'


gulp.task 'coffee', ->
  gulp.src './app/coffee/timepicker-scroll.coffee'
  .pipe preprocess()
  .pipe sourcemaps.init()
  .pipe coffee()
    .on 'error', gutil.log
  .pipe sourcemaps.write()
  .pipe gulp.dest './public/js'


gulp.task 'coffee-watch', ['coffee', 'production'], -> browserSync.reload()


gulp.task 'sass', ->
  gulp.src './app/scss/**/*.scss'
  .pipe sass()
  .pipe autoprefixer
    browsers: ['last 3 versions']
  .pipe gulp.dest './public/css'
  .pipe browserSync.stream()


gulp.task 'html', ->
  gulp.src './app/html/**/*.html'
  .pipe gulp.dest './public'


gulp.task 'html-watch', ['html'], -> browserSync.reload()


gulp.task 'serve', ['coffee', 'sass', 'html'], ->
  browserSync.init
    open: false
    browser: "google chrome"
    reloadOnRestart: true
    server:
      baseDir: "./public"

  gulp.watch './app/coffee/**/*.coffee', ['coffee-watch']
  gulp.watch './app/scss/**/*.scss', ['sass', 'production']
  gulp.watch './app/html/**/*.html', ['html-watch']


gulp.task 'production', ->
  gulp.src './app/coffee/timepicker-scroll.coffee'
  .pipe preprocess()
  .pipe coffee()
    .on 'error', gutil.log
  .pipe gulp.dest './'

  gulp.src './app/scss/**/*.scss'
  .pipe sass()
  .pipe autoprefixer
    browsers: ['last 3 versions']
  .pipe gulp.dest './'