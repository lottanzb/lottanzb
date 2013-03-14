#!/usr/bin/env python
# encoding: utf-8

import os.path
import subprocess

from waflib import Context, Options
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

    opt.add_option('--lcov-report',
        help=('Generate a code coverage report'),
        action="store_true", default=False, dest='lcov_report')

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
    conf.check_cfg(package='launchpad-integration-3.0', uselib_store='LP',
        atleast_version='0.1', args='--cflags --libs')
    conf.check_cfg(package='unique-3.0', uselib_store='UNIQUE',
        atleast_version='0.1', args='--cflags --libs')
    # conf.check_cfg(package='valadate-1.0', uselib_store='VALADATE',
    #     atleast_versoin='0.1.1', args='--cflags --libs', mandatory=False)

    env = conf.env
    if conf.options.enable_gcov:
        env['GCOV_ENABLED'] = True
        env.append_value('CFLAGS', '-fprofile-arcs')
        env.append_value('CFLAGS', '-ftest-coverage')
        env.append_value('LINKFLAGS', '-fprofile-arcs')
        env.append_value('LINKFLAGS', '-lgcov')

    conf.find_program('xsltproc', var='XSLTPROC')
    conf.find_program('glib-compile-resources', var='GLIB_COMPILE_RESOURCES')
    # conf.find_program('valadate', var='VALADATE', mandatory=False)
    
    conf.define('PACKAGE', APPNAME)
    conf.define('DBUS_NAME', DBUS_NAME);
    conf.define('VERSION', VERSION)
    conf.define('COPYRIGHT', COPYRIGHT)
    conf.define('WEBSITE', WEBSITE)
    conf.define('GETTEXT_PACKAGE', APPNAME);
    conf.env.append_value('CFLAGS', '-w')
    conf.env.append_value('VALAFLAGS', '-g')
    conf.env.append_value('VALAFLAGS', '--save-temps')
    # conf.env.append_value('VALAFLAGS', '--enable-experimental-non-null')
 
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
    waf_unit_test.summary(ctx)

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
                result = (suite_name, returncode, None, outcome)
            results.append(result)

    ctx.utest_results = results
                
@conf
def test_conf(ctx):
    conf.find_program('lcov', var='LCOV')
    conf.find_program('genhtml', var='GENHTML')

def test(ctx):
    env = ctx.env

    if not env['GCOV_ENABLED']:
        raise Errors.WafError("project not configured for code coverage; "
            "reconfigure with --enable-gcov")

    os.chdir('build')
    try:
        ctx.exec_command('test/lottanzb-test')
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

        genhtml_command = "genhtml -o " + lcov_report_dir
        genhtml_command += " " + info_file
        if subprocess.Popen(genhtml_command, shell=True).wait():
            raise SystemExit(1)
    finally:
        os.chdir("..")

class test_context(BuildContext):
    cmd = 'test'
    fun = 'test'
