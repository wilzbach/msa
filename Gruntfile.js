/*global module:false*/
module.exports = function(grunt) {

	//"use:strict";
  
  // load tasks
  grunt.loadNpmTasks('grunt-contrib-qunit');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-contrib-jshint');

  // Project configuration.
  grunt.initConfig({
  	pkg: grunt.file.readJSON('package.json'),
  	qunit: {
  		options: { '--web-security': 'no' },
      all: ['tests/**/*.html'],
  },
  watch: {
    scripts: {
      files: ['tests/**/*.js', 'tests/**/*.html', 'js/**/*.js'],
      tasks: ['qunit'],
      options: {
        spawn: false,
        event: ['all'],
        livereload: true,
      },
    },
  },
  "qunit_amd": {
  	unit: {
  		include: [
  		'../libs/require.js',
  		],
  		tests: [
  		"test_fasta.js"
  		],
  		require: {
  			baseUrl: '../js',
  			paths: {
          "jquery": "../libs/jquery2",
          cs: 'libs/cs',
         'coffee-script': 'libs/coffee-script',
  			}
  		}
  	}
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
});


  // Default task.
  grunt.registerTask('default', ['qunit']);

  grunt.event.on('qunit.error.onError', function (message, stackTrace) {
    grunt.log.ok("Error: " + message);
    grunt.log.ok(stackTrace);
  });


};
