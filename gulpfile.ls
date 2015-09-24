{create-write-stream} = require \fs
require! \gulp
require! \gulp-download
require! \gulp-livescript
require! \mkdirp

gulp.task \build, ->
    gulp.src <[index.ls download-ip-country-db.ls ip-to-country.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './'
    gulp.src <[./stores/*.ls]>
    .pipe gulp-livescript!
    .pipe gulp.dest './stores'

gulp.task \watch, ->
    gulp.watch <[index.ls download-ip-country-db.ls ip-to-country.ls ./stores/*.ls]>, <[build]>

gulp.task \default, <[build watch]>