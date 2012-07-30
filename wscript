#!/usr/bin/env python
# encoding: utf-8

import os.path
import subprocess

from waflib.Task import Task, update_outputs
from waflib.Configure import conf
from waflib import Context

APPNAME = 'lottanzb'
PACKAGE = 'lottanzb'
DBUS_NAME = 'org.' + APPNAME
VERSION = '0.7'
WEBSITE = 'http://www.lottanzb.org/'
COPYRIGHT = 'Copyright \xc2\xa9 2007-2012 Severin Heiniger'

def options(opt):
    opt.load('compiler_c gnu_dirs glib2 vala intltool')
    grp = opt.add_option_group('test options')
    grp.add_option('--gdb', action='store_true', help='run tests under gdb')
    grp.add_option('--gir', action='store_true', help='run gir tests')

    opt.add_option('--enable-gcov',
        help=('Enable code coverage analysis. '
            'WARNING: this option only has effect '
            'with the configure command.'),
            action="store_true", default=False, dest='enable_gcov')

    opt.add_option('--lcov-report',
        help=('Generate a code coverage report '
            '(use this option at test time, not in configure)'),
        action="store_true", default=False, dest='lcov_report')
    

def configure(conf):
    conf.load('compiler_c gnu_dirs glib2 vala intltool')
    
    conf.check_vala(min_version=(0, 15))
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
    conf.check_cfg(package='libvala-0.16', uselib_store='VALA',
        atleast_version='0.15.2', args='--cflags --libs')
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
    conf.env.append_value('VALAFLAGS', '-g')
    conf.env.append_value('VALAFLAGS', '--save-temps')
    # conf.env.append_value('VALAFLAGS', '--enable-experimental-non-null')
 
    conf.write_config_header ('config.h')

def build(bld):
    ui_to_vala_mapping = {
        'about_dialog.ui': 'gui/AbstractAboutDialog.vala',
        'add_file_dialog.ui': 'gui/AbstractAddFileDialog.vala',
        'add_url_dialog.ui': 'gui/AbstractAddURLDialog.vala',
        'main_window.ui': 'gui/main/AbstractMainWindow.vala',
        'info_bar.ui': 'gui/main/AbstractInfoBar.vala',
        'download_list.ui': 'gui/main/AbstractDownloadList.vala',
        'download_properties_dialog.ui': 'gui/AbstractDownloadPropertiesDialog.vala',
        'prefs_window.ui': 'gui/prefs/AbstractPreferencesWindow.vala',
        'prefs_tab_general.ui': 'gui/prefs/AbstractGeneralPreferencesTab.vala',
        'server_editor_pane.ui': 'gui/servers/AbstractServerEditorPane.vala',
        'servers_dialog.ui': 'gui/servers/AbstractServersDialog.vala'
    }
    src_dir_node = bld.path.find_dir('src')
    ui_dir_node = bld.path.find_dir('data/gui')
    for ui_file_name, vala_file_path in ui_to_vala_mapping.items():
        ui_file_node = ui_dir_node.find_or_declare(ui_file_name)
        vala_file_node = src_dir_node.find_or_declare(vala_file_path)
        task = gen_vala_gtk_widget_bindings(env=bld.env)
        task.set_inputs(ui_file_node)
        task.set_outputs(vala_file_node)
        bld.add_to_group(task)
    source = src_dir_node.ant_glob('**/*.vala')
    source.append(bld.path.find_or_declare('data/lottanzb.gresource.c'))
    app = bld.program(target=APPNAME, features='glib2', source=source,
        vapi_dirs='vapi',
        cflags=['-g'] + ['-include' + bld.path.find_or_declare(header_file).abspath() \
                for header_file in ['config.h', 'data/lottanzb.gresource.h']],
        packages='glib-2.0 gio-2.0 gtk+-3.0 gmodule-2.0 json-glib-1.0 ' + \
            'libsoup-2.4 libvala-0.16 gee-1.0 launchpad-integration-3.0 unique-3.0 ' + \
            'lottanzb-config lottanzb-resource lottanzb-test-resource ' + \
            'lottanzb-gsettings-workaround',
        uselib='GLIB GIO GTK+ GMODULE LIBSOUP JSON VALA GEE LP UNIQUE',
        vala_defines=['DEBUG'])
    app.add_settings_schemas(['data/apps.lottanzb.gschema.xml',
        'data/apps.lottanzb.backend.sabnzbdplus.gschema.xml'])
    app.add_resource_bundles(['data/lottanzb.gresource.xml'])
    bld.recurse('data test')
    bld(features='intltool_po', appname=APPNAME, podir='po',
        install_path='${LOCALEDIR}')

def underscore_to_camelcase(value):
    return ''.join([element.capitalize() for element in value.split('_')])

@update_outputs
class gen_vala_gtk_widget_bindings(Task):
    XSLT_FILE_NAME = 'util/gen-vala-gtk-widget-bindings.xslt'
    ext_in=['.ui']
    ext_out=['.vala']
    
    def run(self):
        bld=self.inputs[0].__class__.ctx
        ui_file_node = self.inputs[0]
        vala_file_node = self.outputs[0]
        xslt_file_node = bld.path.make_node(self.XSLT_FILE_NAME)
        class_name = os.path.splitext(vala_file_node.name)[0]
        return self.exec_command('xsltproc -nodtdattr ' + \
            '--stringparam \'ui-file-name\' \'%s\' ' % ui_file_node.name + \
            '--stringparam \'namespace\' \'%s\' ' % APPNAME.capitalize() + \
            '--stringparam \'class-name\' \'%s\' ' % class_name + \
            '%s %s ' % (xslt_file_node.abspath(), ui_file_node.abspath()) + \
            '> %s' % vala_file_node.abspath())

from waflib import Errors
from waflib.TaskGen import taskgen_method, feature

def r_change_ext(self, ext):
    """
    Change the extension from the *last* dot in the filename. The gsettings schemas
    often have names of the form org.gsettings.test.gschema.xml
    """
    
    name = self.name
    k = name.rfind('.')
    if k >= 0:
        name = name[:k] + ext
    else:
        name = name + ext
    return self.parent.find_or_declare([name])

@taskgen_method
def add_resource_bundles(self, filename_list):
    """Add resource bundle description files to *resource_bundle_files*."""
    if not hasattr(self, 'resource_bundle_files'):
        self.resource_bundle_files = []

    if not isinstance(filename_list, list):
        filename_list = [filename_list]

    self.resource_bundle_files.extend(filename_list)

@feature('glib2')
def process_resource_bundles(self):
    resource_bundle_files = getattr(self, 'resource_bundle_files', [])
    if resource_bundle_files and not self.env['GLIB_COMPILE_RESOURCES']:
        raise Errors.WafError ('Unable to process GResource bundles - ' + \
            'glib-compile-resources was not found during configure')
    
    # process resource_bundle_files
    for bundle_file in resource_bundle_files:
        bundle_task = self.create_task ('compile_resource_bundle')
        bundle_node = self.path.find_resource(bundle_file)
        if not bundle_node:
            raise Errors.WafError('Cannot find the resource bundle file \'%s\'' % bundle_node.abspath())
        
        input_nodes = [bundle_node]
        output_nodes = [r_change_ext (bundle_node, '.c'), r_change_ext (bundle_node, '.h')]
        bundle_list_node = r_change_ext(bundle_node, '.list')
       
        source_node = bundle_node.parent
        get = self.env.get_flat
        self.bld.exec_command('%s --generate-dependencies --sourcedir=%s %s > %s' %
                (get('GLIB_COMPILE_RESOURCES'), source_node.abspath(),
                bundle_node.abspath(), bundle_list_node.abspath()))
        
        for resource_file in bundle_list_node.read().splitlines():
            relative_resource_file = resource_file[len(source_node.abspath ()):]
            resource_node = source_node.find_resource(relative_resource_file)
            input_nodes.append(resource_node)

        bundle_task.set_inputs (input_nodes)
        bundle_task.set_outputs (output_nodes)

class compile_resource_bundle(Task):
    color = 'PINK'
    ext_in = ['.gresource.xml']
    ext_out = ['.c', '.h']
    
    def run(self):
        input_node = self.inputs[0]
        bld = input_node.__class__.ctx
        get = self.env.get_flat
        source_node = input_node.parent
        for output_node in self.outputs:
            output_node.delete()
            output_file = output_node.abspath()
            input_file = input_node.abspath()
            self.exec_command('%s --generate --sourcedir=%s --target=%s %s' %
                (get('GLIB_COMPILE_RESOURCES'), source_node.abspath(),
                output_file, input_file))

"""import os
from waflib import Logs

def test(ctx):
    # get = ctx.env.get_flat
    wd = os.getcwd() + '/build'
    env = dict(os.environ)
    env['LD_LIBRARY_PATH'] = "%(DIR)s:%(DIR)s/test:%(LD_LIBRARY_PATH)s" % {
        'DIR': wd,
        'LD_LIBRARY_PATH': env.get('LD_LIBRARY_PATH', '')}
    Logs.info('LD_LIBRARY_PATH: ' + env['LD_LIBRARY_PATH'])
    cmd = []
    if ctx.options.gdb:
        cmd += 'gdb', '--args'
    cmd += ['valadate'] # get('VALADATE'),
    if ctx.options.verbose:
        cmd += '-V',
    cmd += '-L', 'test', '-d', wd
    if ctx.options.gir:
        cmd += '-f', wd+'/test/lottanzb-0.gir'
    else:
        cmd += '-f', wd+'/test/test.vapi'
    Logs.info('Executing ' + ' '.join(cmd))
    if ctx.exec_command(cmd, env=env) != 0:
        raise Errors.WafError('Tests failed')"""

from waflib.Build import BuildContext

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
        lcov_extract_command = "lcov --extract " + info_file + " " + "*/lottanzb/src/* --directory . --output-file " + info_file + " --base-directory " + os.getcwd()
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


