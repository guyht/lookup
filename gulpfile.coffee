
fs = require 'fs'

gulp = require 'gulp'
gutil = require 'gulp-util'
coffee = require 'gulp-coffee'



# Compile coffee-script
gulp.task 'coffee', ->

    # Compile public javascript code and trigger reload if enabled
    p = gulp.src('./src/**/*.coffee')
        .pipe(coffee((bare: true)))
        .pipe(gulp.dest('./lib/'))

    # Compile public javascript code and trigger reload if enabled
    p = gulp.src('./src/public/*.coffee')
        .pipe(coffee((bare: true)))
        .pipe(gulp.dest('./public/js/'))
