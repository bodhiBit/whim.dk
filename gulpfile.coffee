"use strict"
fs          = require "fs"

gulp        = require "gulp"
gutil       = require "gulp-util"
del         = require "del"
data        = require "gulp-data"
jade        = require "gulp-jade"
stylus      = require "gulp-stylus"
rename      = require "gulp-rename"
livereload  = require "gulp-livereload"
indent      = require "gulp-indent"
concat      = require "gulp-concat-util"
toc         = require "gulp-toc"
uglify      = require "gulp-uglify"
coffeeify   = require "gulp-coffeeify"
ftp         = require "vinyl-ftp"
exec        = require "gulp-exec"

###
 gulpfile.coffee
 For building static web apps in a harp-like manner.
 
 @date  03-06-2015
###
cleaned = false
jade_opts =
  pretty: false
toc_opts =
  tocMin: 2
  tocMax: 6
  anchorMin: 7
  anchorMax: 6
stylus_opts =
  "compress": true
  "include css": true
browserify_opts =
  {}
composer_opts =
  bin: "composer"
globals =
  {}

getData = (file, cb) ->
  filename = (file.path.substr 0, file.path.lastIndexOf ".") + ".json"
  fs.readFile filename, { encoding: "utf8" }, (err, json) ->
    if err
      cb null, globals
    else
      locals = JSON.parse json
      locals[key] ?= value for key, value of globals
      cb null, locals

gulp.task "clean", (cb) ->
  if not cleaned
    cleaned = true
    del ["./build/*", "!./build/**/_*", "!./build/**/_*/*" ], cb
  else
    do cb if cb

gulp.task "build:html", [ "clean" ], ->
  try
    json = fs.readFileSync "./src/globals.json", { encoding: "utf8" }
    globals = JSON.parse json
    globals.pkg = require "./package.json"
    for mod, ver of globals.pkg.dependencies
      globals[mod] ?= require mod
    
  
  gulp.src [ "./src/**/*.jade", "!./src/**/_*", "!./src/**/_*/*" ]
    .pipe data getData
    .pipe jade jade_opts
    .pipe rename (path) ->
      if (path.basename.indexOf ".") > 0
        path.extname = ""
    .pipe gulp.dest "./build/"
    .pipe do livereload
  
  gulp.src [ "./src/**/*.md", "!./src/**/_*", "!./src/**/_*/*" ]
    .pipe indent
      amount: 4
    .pipe concat.header "include ./_layout.jade\n  :markdown\n"
    .pipe data getData
    .pipe jade jade_opts
    .pipe toc toc_opts
    .pipe gulp.dest "./build/"
    .pipe do livereload

gulp.task "build:css", [ "clean" ], ->
  gulp.src [ "./src/**/*.styl", "!./src/**/_*", "!./src/**/_*/*" ]
    .pipe stylus stylus_opts
    .pipe gulp.dest "./build/"
    .pipe do livereload

gulp.task "build:js", [ "clean" ], ->
  gulp.src [ "./src/**/*.coffee", "!./src/**/_*", "!./src/**/_*/*" ]
    .pipe coffeeify browserify_opts
    .pipe do uglify
    .pipe gulp.dest "./build/"
    .pipe do livereload

gulp.task "build:static", [ "clean" ], ->
  gulp.src [ "./src/**/*", "./src/**/.*", "!**/*.jade", "!**/*.md", "!**/*.styl", "!**/*.coffee", "!./src/**/_*", "!./src/**/_*/*"]
    .pipe gulp.dest "./build/"

gulp.task "composer", [ "build:static" ], (cb) ->
  gulp.src [ "./build/composer.json" ]
    .pipe exec "<%= options.bin %> install -d ./build", composer_opts
    .pipe do exec.reporter

gulp.task "build", [ "build:html", "build:css", "build:js", "build:static", "composer" ]
  
gulp.task "watch", ->
  cleaned = true
  jade_opts.pretty = true
  stylus_opts.compress = false
  browserify_opts.debug = true
  uglify = indent
  
  gulp.watch [ "./src/**/*.jade", "./src/**/*.md", "./src/**/*.json" ], [ "build:html" ]
  gulp.watch [ "./src/**/*.styl" ], [ "build:css" ]
  gulp.watch [ "./src/**/*.coffee" ], [ "build:js" ]
  gulp.watch [ "./src/composer.json" ], [ "composer" ]
  gulp.watch [ "./src/**/*", "./src/**/.*" ], [ "build:static" ]
  do livereload.listen

gulp.task "deploy", ["build"], ->
  ftp_opts = require "./.deploy.json"
  ftp_opts.log = gutil.log
  conn = ftp.create ftp_opts
  gulp.src [ "./build/**/*", "./build/**/.*", "!./build/**/_*", "!./build/**/_*/*" ]
    .pipe conn.newerOrDifferentSize ftp_opts.remotePath
    .pipe conn.dest ftp_opts.remotePath

gulp.task "default", [ "build" ]
