###
 Gruntfile.coffee
 This script does nothing so far...
###
"use strict"
module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    harp:
      build:
        source: "src/"
        dest: "build/"
    browserify:
      debug:
        options:
          transform: [ "coffeeify" ]
          browserifyOptions:
            debug: true
        files:
          "build/script.js": "src/_script/main.coffee"
      build:
        options:
          transform: [ "coffeeify" ]
          browserifyOptions:
            debug: false
        files:
          "build/script.js": "src/_script/main.coffee"
    uglify:
      build:
        files:
          "build/script.js": "build/script.js"
    watch:
      options:
        livereload: true
      files: "src/**"
      tasks: [ "harp", "browserify:debug" ]
  
  grunt.loadNpmTasks "grunt-browserify"
  grunt.loadNpmTasks "grunt-harp"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.registerTask "default", [ "harp", "browserify:build", "uglify" ]
  