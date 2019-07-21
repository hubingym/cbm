module main

import os

fn help() {
    help_text := '
cbm version 1.0.0
usage: cbm [options] cmd

Options:
  -h               show help
  -d <directory>   code directory, default .

Cmd:
  init             inital build.json
  clean            clean
  build            build
  run              run program
'
    println(help_text)
}

fn cmd_init(dir string) {
    println('--begin init---')
    write_build_json(dir)
    println('--end init---')
}

fn cmd_cean(dir string) {
    println('--begin clean---')
    folder := '${dir}/${build_dir}'
    // os.rmdir(folder)
    os.system('rm -rf ${folder}')
    println('--end clean---')
}

fn cmd_build(dir string) {
    println('--begin build---')
    build_json := read_build_json(dir) or {
        println(err)
        return
    }
    // print('build json: ')
    // println(build_json)
    mut builder := new_builder(dir)
    // 扫描文件
    builder.scan_files()
    // 编译.o文件
    builder.build_files(build_json.cflags, build_json.cxxflags)
    // ar文件
    if (build_json.buildtype == type_lib) {
        builder.ar_files(build_json.name)
    }
    // 链接文件
    if (build_json.buildtype == type_program) {
        builder.link_files(build_json.name, build_json.ldflags)
    }
    println('--end build---')
}

fn cmd_run(dir string) {
    println('--begin run---')
    // build_json := read_build_json(dir) or {
    //     println(err)
    //     return
    // }
    // if (build_json.buildtype != type_program) {
    //     println('it\'s not a program!')
    //     return
    // }
    // os.system('$dir/${build_json.name}')
    println('--end run---')
}

fn main() {
    mut dir := '.'
    mut cmd := ''
    // println(os.args)
    if (os.args.len < 2 || '-h' in os.args) {
        help()
        return
    }

    len := os.args.len
    mut skip := false
    for i, val in os.args {
        // 跳过一个
        if skip {
            skip = false
            continue
        }
        if '-d' == val {
            dir = os.args[i + 1]
            skip = true
            continue
        }

        // NOTICE:需要放置在后面
        if i == len - 1 {
            cmd = val
        }
    }

    // println('dir:${dir}, cmd:${cmd}')
    match cmd {
        'init' => cmd_init(dir)
        'clean' => cmd_cean(dir)
        'build' => cmd_build(dir)
        'run' => cmd_run(dir)
        else => println('not suported cmd: $cmd')
    }
}
