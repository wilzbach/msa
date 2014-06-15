/*global module:false*/
module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
  	pkg: grunt.file.readJSON('package.json'),
  	qunit: {
  		options: { '--web-security': 'no' },
      all: ['tests/**/*.html'],
  },
  watch: {
    scripts: {
      files: ['tests/**/*.js', 'tests/**/*.html',"tests/**/*.coffee", 
            'js/**/*.js', "js/**/*.coffee"],
      tasks: ['qunit'],
      options: {
        spawn: false,
        event: ['all'],
        livereload: true,
      },
    },
  },
   jshint: {
    files: {
        src: ['js/msa/*.js'],
    },
    options: {
      curly: true,
      eqeqeq: true,
      immed: true,
      latedef: true,
      newcap: true,
      noarg: true,
      sub: true,
      undef: true,
      boss: true,
      eqnull: true,
      browser: true,
      globals: {
        QUnit: true,
        define: true
      }
    }
  },
  coffeelint: {
      app: ['js/**/*.coffee', 'tests/**/*.coffee'],
      options: {
        configFile: "config/coffeelint.json",
      },
    },
  codo: {
      options: {
        title: "BioJS MSA",
        name: "BioJS documentation",
        output: 'build/doc',
        inputs: ["js"]
      }
    },
});

	// load tasks
  grunt.loadNpmTasks('grunt-contrib-qunit');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jshint');
  grunt.loadNpmTasks('grunt-coffeelint');
  grunt.loadNpmTasks('grunt-codo');



  // Define tasks
  grunt.registerTask('default', ['qunit']);
  grunt.registerTask('build', ['qunit', 'coffeelint', 'codo']);

  grunt.event.on('qunit.error.onError', function (message, stackTrace) {
    grunt.log.ok("Error: " + message);
    grunt.log.ok(stackTrace);
  });


};
