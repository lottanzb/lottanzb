#!/usr/bin/env python
# encoding: utf-8

import os.path
import subprocess

from waflib import Context, Options, Errors, Logs
from waflib.Task import Task, update_outputs
from waflib.Configure import conf
from waflib.Build import BuildContext
from waflib.Tools import waf_unit_test

APPNAME = 'lottanzb'
PACKAGE = 'lottanzb'
DBUS_NAME = 'org.' + APPNAME
VERSION = '0.7'
WEBSITE = 'http://www.lottanzb.org/'
COPYRIGHT = 'Copyright \xc2\xa9 2007-2012 Severin Heiniger'

def options(opt):
    opt.load('compiler_c gnu_dirs glib2 vala intltool waf_unit_test')
    grp = opt.add_option_group('test options')
    grp.add_option('--gdb', action='store_true', help='run tests under gdb')
    grp.add_option('--gir', action='store_true', help='run gir tests')

    opt.add_option('--enable-gcov',
        help=('Enable code coverage analysis. '
            'WARNING: this option only has effect '
            'with the configure command.'),
        action="store_true", default=False, dest='enable_gcov')

def configure(conf):
    conf.load('compiler_c gnu_dirs glib2 vala intltool waf_unit_test')
    
    conf.check_vala(min_version=(0, 17))
    conf.check_cfg(package='glib-2.0', uselib_store='GLIB',
        atleast_version='2.28', args='--cflags --libs')
    conf.check_cfg(package='gio-2.0', uselib_store='GIO',
        atleast_version='2.28', args='--cflags --libs')
    conf.check_cfg(package='gtk+-3.0', uselib_store='GTK+',
        atleast_version='3.0', args='--cflags --libs')
    conf.check_cfg(package='gmodule-2.0', uselib_store='GMODULE',
        atleast_version='2.28', args='--cflags --libs')
    conf.check_cfg(package='json-glib-1.0', uselib_store='JSON',
        atleast_version='0.13', args='--cflags --libs')
    conf.check_cfg(package='libsoup-2.4', uselib_store='LIBSOUP',
        atleast_version='2.28', args='--cflags --libs')
    conf.check_cfg(package='libvala-0.18', uselib_store='VALA',
        atleast_version='0.18', args='--cflags --libs')
    conf.check_cfg(package='gee-1.0', uselib_store='GEE',
        atleast_version='0.6', args='--cflags --libs')
    conf.check_cfg(package='unique-3.0', uselib_store='UNIQUE',
        atleast_version='0.1', args='--cflags --libs')

    env = conf.env
    if conf.options.enable_gcov:
        env['GCOV_ENABLED'] = True
        env.append_value('CFLAGS', '-fprofile-arcs')
        env.append_value('CFLAGS', '-ftest-coverage')
        env.append_value('LINKFLAGS', '-fprofile-arcs')
        env.append_value('LINKFLAGS', '-lgcov')

    conf.find_program('xsltproc', var='XSLTPROC')
    conf.find_program('glib-compile-resources', var='GLIB_COMPILE_RESOURCES')
    
    conf.define('PACKAGE', APPNAME)
    conf.define('DBUS_NAME', DBUS_NAME);
    conf.define('VERSION', VERSION)
    conf.define('COPYRIGHT', COPYRIGHT)
    conf.define('WEBSITE', WEBSITE)
    conf.define('GETTEXT_PACKAGE', APPNAME);
    conf.env.append_value('CFLAGS', '-w')
    conf.env.append_value('VALAFLAGS', '-g')
    conf.env.append_value('VALAFLAGS', '--save-temps')
 
    conf.write_config_header ('config.h')

def build(bld):
    bld.recurse('data liblottanzb lottanzb')
    if not getattr(Options.options, 'no_tests', False):
        bld.recurse('test')
    
    bld(features='intltool_po', appname=APPNAME, podir='po',
        install_path='${LOCALEDIR}')
    bld.add_post_fun(post)
    
    bld.options.all_tests = True

def post(ctx):
    flatten_utest_results(ctx)
    show_unit_test_summary(ctx)

def flatten_utest_results(ctx):
    original_results = getattr(ctx, 'utest_results', [])
    results = []
    for original_result in original_results:
        filename, returncode, stdout, stderr = original_result
        lines = stdout.split('\n')
        for line in lines:
            if not line:
                continue
            parts = line.split(' ')
            suite_name = parts[0].rstrip(':')
            outcome = parts[1]
            if outcome == 'OK':
                result = (suite_name, 0, outcome, None)
            else:
                result = (suite_name, returncode, None, stderr.strip('\n'))
            results.append(result)

    ctx.utest_results = results

def show_unit_test_summary(bld):
    results = getattr(bld, 'utest_results', [])
    if results:
        Logs.pprint('CYAN', 'execution summary')
        total = len(results)
        total_failed = len([x for x in results if x[1]])
        total_passed = total - total_failed
        if total_passed: 
            Logs.pprint('CYAN', '  tests that pass %d/%d' % (total_passed, total))
            for (f, code, out, err) in results:
                if not code:
                    Logs.pprint('CYAN','    %s' % f)
        if total_failed:
            Logs.pprint('RED', '  tests that fail %d/%d' % (total_failed, total))
            for (f, code, out, err) in results:
                if code:
                    Logs.pprint('RED', '    %s' % f)
                    Logs.pprint('RED', '    %s' % err)
@conf
def coverage_conf(ctx):
    conf.find_program('lcov', var='LCOV')
    conf.find_program('genhtml', var='GENHTML')

def coverage(ctx):
    env = ctx.env

    if not env['GCOV_ENABLED']:
        raise Errors.WafError("project not configured for code coverage; "
            "reconfigure with --enable-gcov")

    os.chdir('build')
    try:
        # ctx.exec_command('test/lottanzb-test')
        lcov_report_dir = 'lcov-report'
        create_dir_command = "rm -rf " + lcov_report_dir
        create_dir_command += " && mkdir " + lcov_report_dir + ";"

        if subprocess.Popen(create_dir_command, shell=True).wait():
            raise SystemExit(1)

        info_file = os.path.join(lcov_report_dir, 'report.info')
        lcov_command = "lcov --capture --directory . --output-file " + info_file
        lcov_command += " --base-directory " + os.getcwd()
        if subprocess.Popen(lcov_command, shell=True).wait():
            raise SystemExit(1)

        blacklisted_patterns = ["*/build/*", "*/vapi/*", "*/test/*"]
        for pattern in blacklisted_patterns:
            lcov_extract_command = "lcov --remove " + info_file + " " + \
                pattern + " --directory . --output-file " + info_file + \
                " --base-directory " + os.getcwd()
            if subprocess.Popen(lcov_extract_command, shell=True).wait():
                raise SystemExit(1)

        genhtml_command = "genhtml --no-function-coverage --no-branch-coverage -o " + lcov_report_dir
        genhtml_command += " " + info_file
        if subprocess.Popen(genhtml_command, shell=True).wait():
            raise SystemExit(1)
    finally:
        os.chdir("..")

class coverage_context(BuildContext):
    '''generates a code coverage report for the project'''
    cmd = 'coverage'
    fun = 'coverage'
