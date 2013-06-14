# Gruntfile

# the 'wrapper' function
module.exports = (grunt) ->

    # Utilities
    # ==========
    path = require 'path'
    request = require 'request'
    Q = require 'Q'
    api = (url, method, data, username, accessKey) ->
            deferred = Q.defer()
            request
                method: method
                uri: ["https://", username, ":", accessKey, "@saucelabs.com/rest", url].join("")
                headers:
                    'Content-Type': 'application/json'
                body: JSON.stringify(data)
                (err, res, body) ->
                    grunt.write.debug "body: " + body
                    grunt.write.debug "res.body: " + res.body
                    deferred.resolve res.body
            return deferred.promise

    # Package
    # ==========
    pkg = require './package.json'

    # Modules
    # ==========
    # Core modules
    core = [
        './client/js/util.js',
        './client/js/version.js',
        './client/js/features.js',
        './client/js/promise.js',
        './client/js/button.js',
        './client/js/paste.js',
        './client/js/upload-data.js',
        './client/js/uploader.basic.js',
        './client/js/dnd.js',
        './client/js/uploader.js',
        './client/js/ajax.requester.js',
        './client/js/deletefile.ajax.requester.js',
        './client/js/window.receive.message.js',
        './client/js/handler.base.js',
        './client/js/handler.form.js',
        './client/js/handler.xhr.js',
    ]

    # jQuery plugin modules
    jquery = core.concat './client/js/jquery-plugin.js',
                         './client/js/jquery-dnd.js'


    extra = [
        './client/js/iframe.xss.response.js'
        './client/loading.gif',
        './client/processing.gif',
        './README.md',
        './LICENSE'
    ]

    browsers = [
        {
            browserName: 'chrome'
            platform: 'Windows 7'
        }
        # {
        #     browserName: 'iphone'
        #     platform: 'OS X 10.8'
        #     version: '6'
        # }
        # {
        #     browserName: 'safari'
        #     platform: 'OS X 10.8'
        #     version: '6'
        # }
        # {
        #     browserName: 'firefox'
        #     platform: 'Windows 7'
        #     version: '19'
        # }
        # {
        #     browserName: 'safari'
        #     platform: 'OS X 10.6'
        #     version: '5'
        # }
        # {
        #     browserName: 'android'
        #     platform: 'Linux'
        #     version: '4.0'
        # }
        # {
        #     browserName: 'internet explorer'
        #     platform: 'Windows 8'
        #     version: '10'
        # }
        # {
        #     browserName: 'internet explorer'
        #     platform: 'Windows 7'
        #     version: '9'
        # }
        # {
        #     browserName: 'internet explorer'
        #     platform: 'Windows 7'
        #     version: '8'
        # }
        # {
        #     browserName: 'internet explorer'
        #     platform: 'Windows XP'
        #     version: '7'
        # }
    ]

    # Configuration
    # ==========
    grunt.initConfig

        # Package
        # --------
        pkg: pkg
        extra: extra

        # Modules
        # ----------
        # works
        bower:
            install:
                options:
                    targetDir: './test/vendor'
                    install: true
                    cleanTargetDir: true
                    cleanBowerDir: true
                    layout: 'byComponent'

        # Clean
        # --------
        clean:
            build:
                files:
                    src: './build'
            dist:
                files:
                    src: './dist'
            test:
                files:
                    src: ['./test/temp*', 'test/coverage']
            vendor:
                files:
                    src: './test/vendor/*'

        # Banner
        # ----------
        usebanner:
            header:
                src: ['./build/*.{js,css}']
                options:
                    position: 'top'
                    banner: '''
                            /*!
                             * <%= pkg.title %>
                             *
                             * Copyright © 2013, <%= pkg.author %> info@fineuploader.com
                             *
                             * Version: <%= pkg.version %>
                             *
                             * Homepage: http://fineuploader.com
                             *
                             * Repository: <%= pkg.repository.url %>
                             *
                             * Licensed under GNU GPL v3, see LICENSE
                             */ \n\n'''
            footer:
                src: ['./build/*.{js,css}']
                options:
                    position: 'bottom'
                    banner: '/*! <%= grunt.template.today("yyyy-mm-dd") %> */\n'

        # Complexity
        # ----------
        complexity:
                src:
                    files:
                        src: ['./client/js/*.js']
                    options:
                        errorsOnly: false # show only maintainability errors
                        cyclomatic: 5
                        halstead: 8
                        maintainability: 100
                        #jsLintXML: 'report.xml' # create XML JSLint-like report

        # Concatenate
        # --------
        concat:
            core:
                options:
                    separator: ';'
                src: core
                dest: './build/<%= pkg.name %>.js'
            jquery:
                options:
                    separator: ';'
                src: jquery
                dest: './build/jquery.<%= pkg.name %>.js'
            css:
                src: ['./client/*.css']
                dest: './build/<%= pkg.name %>.css'


        # Uglify
        # --------
        uglify:
            options:
                mangle: false
                compress: false
                report: 'min'
                preserveComments: 'some'
            core:
                src: ['<%= concat.core.dest %>']
                dest: './build/<%= pkg.name %>.min.js'
            jquery:
                src: ['<%= concat.jquery.dest %>']
                dest: './build/jquery.<%= pkg.name %>.min.js'

        # Copy
        # ----------
        # @noworks
        copy:
            dist:
                files: [
                    {
                        expand: true
                        cwd: './build/'
                        src: ['*.js', '!*.min.js', '!jquery*', '!*iframe*']
                        dest: './dist/<%= pkg.name %>-<%= pkg.version %>/'
                        ext: '-<%= pkg.version %>.js'
                    }
                    {
                        expand: true
                        cwd: './build/'
                        src: ['*.min.js', '!jquery*']
                        dest: './dist/<%= pkg.name %>-<%= pkg.version %>/'
                        ext: '-<%= pkg.version %>.min.js'
                    }
                    {
                        expand: true
                        cwd: './build/'
                        src: ['jquery*js', '!*.min.js']
                        dest: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>/'
                        ext: '.<%= pkg.name %>-<%= pkg.version %>.js'
                    },
                    {
                        expand: true
                        cwd: './build/'
                        src: ['jquery*min.js']
                        dest: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>/'
                        ext: '.<%= pkg.name %>-<%= pkg.version %>.min.js'
                    }
                    {
                        expand: true
                        cwd: './client/js/'
                        src: ['iframe.xss.response.js']
                        dest: './dist/<%= pkg.name %>-<%= pkg.version %>/'
                    }
                    {
                        expand: true
                        cwd: './client/js/'
                        src: ['iframe.xss.response.js']
                        dest: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>/'
                    }
                    {
                        expand: true
                        cwd: './client/'
                        src: ['*.gif']
                        dest: './dist/<%= pkg.name %>-<%= pkg.version %>/'
                    }
                    {
                        expand: true
                        cwd: './client/'
                        src: ['*.gif']
                        dest: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>/'
                    }
                    {
                        expand: true
                        cwd: './'
                        src: ['README.md', 'LICENSE']
                        dest: './dist/<%= pkg.name %>-<%= pkg.version %>/'
                    }
                    {
                        expand: true
                        cwd: './'
                        src: ['README.md', 'LICENSE']
                        dest: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>/'
                    }
                ]
            build:
                files: [
                    {
                        expand: true
                        cwd: './client/js/'
                        src: ['iframe.xss.response.js']
                        dest: './build/'
                    },
                    {
                        expand: true
                        cwd: './client/'
                        src: ['*.gif']
                        dest: './build/'
                    }
                ]
            test:
                expand: true
                flatten: true
                src: ['./build/*']
                dest: './test/temp'


        # Compress
        # ----------
        compress:
            core:
                options:
                    archive: './dist/<%= pkg.name %>-<%= pkg.version %>.zip'
                files: [
                    {
                        src: './dist/<%= pkg.name %>-<%= pkg.version %>/*'
                    }
                ]
            jquery:
                options:
                    archive: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>.zip'
                files: [
                    {
                        src: './dist/jquery.<%= pkg.name %>-<%= pkg.version %>/*'
                    }
                ]

        # cssmin
        # ---------
        # @works
        cssmin:
            options:
                banner: '/*! <%= pkg.name %> <%= grunt.template.today("yyyy-mm-dd") %> */\n'
                report: 'min'
            files:
                src: '<%= concat.css.dest %>'
                dest: './build/<%= pkg.name %>.min.css'

        # Lint
        # --------
        # @nowork
        jshint:
            source: ['./client/js/*.js']
            tests: ['./test/unit/*.js']
            options:
                validthis: true
                laxcomma: true
                laxbreak: true
                browser: true
                eqnull: true
                debug: true
                devel: true
                boss: true
                expr: true
                asi: true

        # Run linter on coffeescript files
        # ----------
        # @works
        coffeelint:
            options:
                indentation:
                    level: 'ignore'
                no_trailing_whitespace:
                    level: 'ignore'
                max_line_length:
                    level: 'ignore'
            grunt: './Gruntfile.coffee'


        # Server to run tests against and host static files
        # ----------
        # @works
        connect:
            root_server:
                options:
                    base: "."
                    hostname: "0.0.0.0"
                    port: 9000
                    keepalive: true
            test_server:
                options:
                    base: "test"
                    hostname: "0.0.0.0"
                    port: 9001

        # Watching for changes
        # ----------
        # @works
        watch:
            options:
                interrupt: true
                debounceDelay: 250
            js:
                files: ['./client/js/*.js']
                tasks: [
                    'build'
                    'test'
                ]
            test:
                files: ['./test/unit/*.js']
                tasks: [
                    'jshint:tests'
                    'test'
                ]
            grunt:
                files: ['./Gruntfile.coffee']
                tasks: ['coffeelint:grunt']

        # Increment version with semver
        # ----------
        version:
            options:
                pkg: pkg
            major:
                options:
                    release: 'major'
                src: ['package.json', 'fineuploader.jquery.json', 'client/js/version.js']
            minor:
                options:
                    release: 'minor'
                src: ['package.json', 'fineuploader.jquery.json', 'client/js/version.js']
            hotfix:
                options:
                    release: 'patch'
                src: ['package.json', 'fineuploader.jquery.json', 'client/js/version.js']
            build:
                options:
                    release: 'build'
                src: ['package.json', 'fineuploader.jquery.json', 'client/js/version.js']

        # Test
        # ----------
        mocha:
            all:
                options:
                    urls: ['http://localhost:9001/index.html']
                    mocha:
                        ignoreLeaks: false
                    reporter: 'Nyan'
                    run: true

        # Saucelas + Mocha
        # ---------
        'saucelabs-mocha':
            all:
                options:
                    urls: ['http://localhost:9001/index.html']
                    tunneled: true
                    concurrency: 3
                    identifier: process.env.TRAVIS_JOB_ID || Math.floor((new Date).getTime() / 1000 - 1230768000).toString()
                    tags: [ process.env.TRAVIS_BRANCH || "local :: " + process.env.SAUCE_USERNAME ]
                    testname: 'Unit Tests'
                    detailedError: true
                    browsers: browsers
                    onTestComplete: (status, page, config, browser) ->
                        done = @async()
                        browser.eval 'JSON.stringify(window.mochaResults)', (err, res) ->
                            done(err) if err

                            res = JSON.parse res
                            res.browser = config

                            grunt.log.debug('[%s] Results: %j', config.prefix, res);

                            data =
                                'custom-data':
                                    mocha: res.jsonReport
                                'passed': !res.failures

                            request
                                method: 'PUT'
                                uri: ["https://", process.env.SAUCE_USERNAME, ":", process.env.SAUCE_ACCESS_KEY, "@saucelabs.com/rest", "/v1/", process.env.SAUCE_USERNAME, "/jobs/", browser.sessionID].join('')
                                headers:
                                    'Content-Type': 'application/json'
                                body: JSON.stringify data
                            , (error, response, body) ->
                                 done null, res

    # Dependencies
    # ==========
    for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
        grunt.loadNpmTasks name

    # Tasks
    # ==========

    # Lint
    # ----------
    grunt.registerTask 'lint', 'Lint, in order, the Gruntfile, sources, and tests.', [
        'coffeelint:grunt',
        'jshint:source',
        'jshint:tests'
    ]

    # Minify
    # ----------
    grunt.registerTask 'minify', 'Minify the source javascript and css', [
        'uglify'
        'cssmin'
    ]

    # Docs
    # ----------
    # @todo
    grunt.registerTask 'docs', 'IN THE WORKS: Generate documentation', []


    # Watcher
    # ----------
    grunt.registerTask 'test-watch', 'Run headless unit-tests and re-run on file changes', [
        'rebuild'
        'watch'
    ]
    # Coverage
    # ----------
    # @todo
    grunt.registerTask 'coverage', 'IN THE WORKS: Generate a code coverage report', []

    # Travis
    # ---------
    # @todo
    grunt.registerTask 'check_for_pull_request_from_master', 'Fails if we are testing a pull request against master', ->
        if (process.env.TRAVIS_BRANCH == 'master' and process.env.TRAVIS_PULL_REQUEST != 'false')
            grunt.fail.fatal '''Woah there, buddy! Pull requests should be
            branched from develop!\n
            Details on contributing pull requests found here: \n
            https://github.com/Widen/fine-uploader/blob/master/CONTRIBUTING.md\n
            '''

    grunt.registerTask 'travis', [
        'check_for_pull_request_from_master'
        'travis-sauce'
    ]


    # Test
    # ----------
    grunt.registerTask 'test', 'Run headless unit tests', [
        'rebuild'
        'copy:test'
        'connect:test_server'
        'mocha'
    ]

    # Test on Saucelabs
    # ----------
    grunt.registerTask 'test-sauce', 'Run tests on Saucelabs', [
        'rebuild'
        'copy:test'
        'connect:test_server'
        'saucelabs-mocha'
    ]

    # Mocha-sauce tests
    # ----------
    grunt.registerTask 'mocha-sauce', 'Run mocha tests on Saucelabs (with fancy error reporting)', () ->
        grunt.config.requires('mocha-sauce')
        name = grunt.config('mocha-sauce').get('name')
        username = grunt.config('mocha-sauce').get('username') or process.env.SAUCE_USERNAME
        accessKey = grunt.config('mocha-sauce').get 'accessKey'  or process.env.SAUCE_ACCESS_KEY
        host = grunt.config('mocha-sauce').get ('name') or 'localhost'
        port = grunt.config('mocha-sauce').get ('port')  or 80
        url = grunt.config('mocha-sauce').get ('url') or ''
        browsers = grunt.config('mocha-sauce').get ('browsers')
        build = grunt.config('mocha-sauce').get('build') or Date.now
        tags = grunt.config('mocha-sauce').get('tags') or []


        sauce = new MochaSauce
            name: name
            username: username
            accessKey: accessKey
            host: host
            port: port
            url: url
            browsers: browsers
            build: build
            tags: tags

        for browser in grunt.config('mocha-sauce').get('browsers')
            sauce.browser(browser)

        sauce.record(grunt.config('mocha-sauce').get('record'))

        sauce.on 'init', (browser) ->
             console.log('  init : %s %s', browser.browserName, browser.platform)

        sauce.on 'start', (browser) ->
            console.log('  start : %s %s', browser.browserName, browser.platform)

        sauce.on 'end', (browser) ->
            console.log('  end : %s %s : %d failures', browser.browserName, browser.platform, res.failures)

        sauce.start()


    # Travis' own test
    grunt.registerTask 'travis-sauce', 'Run tests on Saucelabs', [
        'copy:test'
        'connect:test_server'
        'saucelabs-mocha'
    ]
    # Build
    # ----------
    # @verify
    grunt.registerTask 'build', 'build from latest source', [
        'concat'
        'minify'
        'usebanner'
    ]

    # Prepare
    # ----------
    # @verify
    grunt.registerTask 'prepare', 'Prepare the environment for FineUploader development', [
        'clean'
        'bower'
    ]

    # Rebuild
    # ----------
    grunt.registerTask 'rebuild', "Rebuild the environment and source", [
        'prepare',
        'build'
    ]

    # Dist
    # ---------
    # @todo
    grunt.registerTask 'dist', 'build a zipped distribution-worthy version', [
        'build'
        'copy:dist'
        'compress'
    ]

    # Default
    # ----------
    grunt.registerTask 'default', 'Default task: clean, bower, lint, build, & test', [
        'clean'
        #'lint'
        'build'
        'test'
    ]
