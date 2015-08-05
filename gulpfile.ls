{create-write-stream} = require \fs
require! \gulp
require! \gulp-download
require! \gulp-livescript
require! \mkdirp

gulp.task \build, ->
    gulp.src <[index.ls ip-to-country.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './'
    gulp.src <[./stores/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './stores'

gulp.task \watch, ->
    gulp.watch <[index.ls ip-to-country.ls ./stores/*.ls]>, <[build:src:scripts]>

gulp.task \default, <[build watch]>

gulp.task \download, ->
    <- mkdirp \./data
    gulp-download \https://s3-us-west-2.amazonaws.com/mobi-one/IP-COUNTRY.BIN
        .pipe gulp.dest \./data, overwrite: true
