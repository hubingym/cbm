module main

import os
import flag

const (
    cbm_version = '0.4.0'
)

fn cmd_help() {
    help_text := '
cbm version $cbm_version
usage: cbm [options] cmd

Options:
  -h               show help
  -v               show version
  -d <directory>   code directory, default .

Cmd:
  init             inital build.json
  init --lib       inital build.json, static library
  clean            clean
  build            build
  run              run program
  install          install program
'
    println(help_text)
}

fn cmd_version() {
    println('cbm version: $cbm_version')
}

fn cmd_init(dir string, is_lib bool) {
    write_build_json(dir, is_lib)
    println('init ok')
}

fn cmd_clean(dir string) {
    folder := '${dir}/${build_dir}'
    // os.rmdir(folder)
    os.system('rm -rf ${folder}')
    println('clean ok')
}

fn cmd_build(dir string) {
    // println('--begin build---')
    build_json := read_build_json(dir) or {
        println(err)
        return
    }
    // print('build json: ')
    // println(build_json)
    mut builder := new_builder(dir, build_json.subdirs)
    // 扫描文件
    builder.scan_files()
    // 编译.o文件
    builder.build_files(build_json.name, build_json.cflags, build_json.cxxflags, build_json.buildtype)
    // ar文件
    if (build_json.buildtype == type_lib) {
        builder.ar_files(build_json.name)
    }
    // 链接文件
    if (build_json.buildtype == type_program) {
        mut ldflags := build_json.ldflags
        if is_windows() && build_json.win32ldflags != '' {
            ldflags = build_json.win32ldflags
        }
        builder.link_files(build_json.name, ldflags)
    }
    // println('--end build---')
}

fn cmd_run(dir string, is_install bool) {
    build_json := read_build_json(dir) or {
        println(err)
        return
    }
    if (build_json.buildtype != type_program) {
        println('it\'s not a program!')
        return
    }
    mut b := new_builder(dir, build_json.subdirs)
    binary_file := b.get_binary_path(build_json.name)
    mut install_dir := build_json.install_dir
    if is_windows() {
        install_dir = build_json.win32install_dir
    }
    if is_install {
        os.system('cp ${binary_file} ${install_dir}')
    } else {
        os.system('$dir/${binary_file} ${build_json.run_args}')
    }
}

fn main() {
    // println(os.args)
    if (os.args.len < 2 || '-h' in os.args) {
        cmd_help()
        return
    }

    if (os.args.len < 2 || '-v' in os.args) {
        cmd_version()
        return
    }

    mut fp := flag.new_flag_parser(os.args)
    fp.skip_executable()
    mut dir := fp.string_('dir', `d`, getwd_(), '')
    is_lib := fp.bool('lib', false, '')
    args := fp.finalize() or {
        panic(err)
    }
    if args.len < 1 {
        cmd_help()
        return
    }
    cmd := args[0]

    // println('dir:${dir}, cmd:${cmd}')
    os.chdir(dir)
    dir = '.'
    match cmd {
        'init' { cmd_init(dir, is_lib) }
        'clean' { cmd_clean(dir) }
        'build' { cmd_build(dir) }
        'run' { cmd_run(dir, false) }
        'install' { cmd_run(dir, true) }
        else { println('not suported cmd: $cmd') }
    }
}
