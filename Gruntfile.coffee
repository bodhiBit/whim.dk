###
 Gruntfile.coffee
 This script does nothing so far...
###
"use strict"
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    harp:
      dist:
        source: "src/"
        dest: "build/"
    browserify:
      build:
        options:
          transform: [ "coffeeify" ]
          browserifyOptions:
            debug: true
        files:
          "build/script.js": "src/_script/main.coffee"
    watch:
      options:
        livereload: true
      files: "src/**"
      tasks: [ "default" ]
  
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-harp"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.registerTask "default", [ "harp", "browserify" ]
  