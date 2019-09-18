module main

import os

const (
    build_dir = 'build'
    cc = 'gcc'
    cxx = 'g++'
)

struct CBuilder {
    dir string
    subdirs []string
    outdir string
    outobjsdir string
mut:
    ld string
    cfiles []string
    cxxfiles []string
    ofiles []string
    modified bool
}

fn new_builder(dir string, subdirs []string) CBuilder {
    return CBuilder {
        ld: cc
        dir: dir
        subdirs: subdirs
        outdir: '${build_dir}'
        outobjsdir: '${build_dir}/objs'
    }
}

// 扫描文件
fn (b mut CBuilder) scan_files() {
    println('--scan_files--')
    mut cfiles := []string
    mut cxxfiles := []string
    mut folder_contents := []string
    for dir in b.subdirs {
        for file_path in os.ls(dir) {
            folder_contents << '$dir/$file_path'
        }
    }
    folder_contents << os.ls(b.dir)
    println(folder_contents)
    for file in folder_contents {
        if file.ends_with('.c') {
            cfiles << file
        } else if file.ends_with('.cc') {
            cxxfiles << file
        }  else if file.ends_with('.cpp') {
            cxxfiles << file
        }
    }
    print('cfiles: ')
    println(cfiles)
    print('cxxfiles: ')
    println(cxxfiles)
    b.cfiles = cfiles
    b.cxxfiles = cxxfiles
}

// 编译.o文件
fn (b mut CBuilder) build_files(name string, cflags string, cxxflags string, buildtype string) {
    if !os.file_exists(b.outobjsdir) {
        os.mkdir(b.outdir)
        os.mkdir(b.outobjsdir)
        for dir in b.subdirs {
            println('mkdir -p ${b.outobjsdir}/$dir')
            os.system('mkdir -p ${b.outobjsdir}/$dir')
        }
    }
    println('--build_files--')
    mut ofiles := []string
    mut infile := ''
    mut outfile := ''
    mut cmd := ''
    mut has_cxx := false
    mut ret := 0
    for file in b.cfiles {
        infile = '${file}'
        outfile = file.replace('.c', '.o')
        outfile = '${b.outobjsdir}/${outfile}'
        ofiles << outfile
        if !os.file_exists(outfile) || os.file_last_mod_unix(infile) > os.file_last_mod_unix(outfile) {
            b.modified = true
            cmd = '$cc $cflags -c -o $outfile $infile'
            println(cmd)
            ret = os.system(cmd)
            if ret != 0 {
                exit(1)
            }
        }
    }
    for file in b.cxxfiles {
        infile = '${file}'
        if file.ends_with('.cc') {
            outfile = file.replace('.cc', '.o')
        } else {
            outfile = file.replace('.cpp', '.o')
        }
        
        outfile = '${b.outobjsdir}/${outfile}'
        ofiles << outfile
        has_cxx = true
        if !os.file_exists(outfile) || os.file_last_mod_unix(infile) > os.file_last_mod_unix(outfile) {
            b.modified = true
            cmd = '$cxx $cxxflags -c -o $outfile $infile'
            println(cmd)
            ret = os.system(cmd)
            if ret != 0 {
                exit(1)
            }
        }
    }

    if !b.modified {
        println('no files modified, no need to compile')
    }

    if buildtype == type_program && !os.file_exists(b.get_binary_path(name)) {
        b.modified = true
    }

    if buildtype == type_lib && !os.file_exists(b.get_lib_path(name)) {
        b.modified = true
    }

    if b.modified {
        b.ofiles = ofiles
    }

    if has_cxx {
        b.ld = cxx
    }
}

// 链接为可执行文件
fn (b mut CBuilder) link_files(name string, ldflags string) {
    println('--link_files--')
    if b.modified {
        outfile := '${b.outdir}/${name}'
        ofiles := b.ofiles.join(' ')
        cmd := '${b.ld} -o $outfile ${ofiles} $ldflags'
        println(cmd)
        ret := os.system(cmd)
        if ret != 0 {
            exit(1)
        }
    } else {
        println('no files modified, no need to link')
    }
}

// 打包静态库
fn (b mut CBuilder) ar_files(name string) {
    println('--ar_files--')
    if b.modified {
        outfile := b.get_lib_path(name)
        ofiles := b.ofiles.join(' ')
        cmd := 'ar rcs $outfile ${ofiles}'
        println(cmd)
        ret := os.system(cmd)
        if ret != 0 {
            exit(1)
        }
    } else {
        println('no files modified, no neeed to ar')
    }
}

fn (b &CBuilder) get_binary_path(name string) string {
    mut binary_file := '${b.outdir}/${name}'
    if is_windows() {
        binary_file = binary_file + '.exe'
    }
    return binary_file
}

fn (b &CBuilder) get_lib_path(name string) string {
    return '${b.outdir}/lib${name}.a'
}
