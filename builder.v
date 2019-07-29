module main

import os

const (
    build_dir = 'build'
    cc = 'gcc'
    cxx = 'g++'
)

struct CBuilder {
    dir string
    outdir string
    outobjsdir string
mut:
    ld string
    cfiles []string
    cxxfiles []string
    ofiles []string
    modified bool
}

fn new_builder(dir string) CBuilder {
    return CBuilder {
        ld: cc
        dir: dir
        outdir: '${dir}/${build_dir}'
        outobjsdir: '${dir}/${build_dir}/objs'
    }
}

// 扫描文件
fn (b mut CBuilder) scan_files() {
    println('--scan_files--')
    mut cfiles := []string
    mut cxxfiles := []string
    folder_contents := os.ls(b.dir)
    // println(folder_contents)
    for file in folder_contents {
        if file.ends_with('.c') {
            cfiles << file
        } else if file.ends_with('.cc') {
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
fn (b mut CBuilder) build_files(cflags string, cxxflags string) {
    if !os.file_exists(b.outobjsdir) {
        os.mkdir(b.outdir)
        os.mkdir(b.outobjsdir)
    }
    println('--build_files--')
    mut ofiles := []string
    mut infile := ''
    mut outfile := ''
    mut cmd := ''
    mut has_cxx := false
    mut ret := 0
    for file in b.cfiles {
        infile = '${b.dir}/${file}'
        outfile = file.replace('.c', '.o')
        outfile = '${b.outobjsdir}/${outfile}'
        ofiles << outfile
        if os.file_last_mod_unix(infile) > os.file_last_mod_unix(outfile) {
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
        infile = '${b.dir}/${file}'
        outfile = file.replace('.cc', '.o')
        outfile = '${b.outobjsdir}/${outfile}'
        ofiles << outfile
        if os.file_last_mod_unix(infile) > os.file_last_mod_unix(outfile) {
            has_cxx = true
            b.modified = true
            cmd = '$cxx $cxxflags -c -o $outfile $infile'
            println(cmd)
            ret = os.system(cmd)
            if ret != 0 {
                exit(1)
            }
        }
    }
    if b.modified {
        b.ofiles = ofiles
    } else {
        println('no files modified, no need to compile')
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
        cmd := '${b.ld} $ldflags -o $outfile ${ofiles}'
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
        outfile := '${b.outdir}/lib${name}.a'
        ofiles := b.ofiles.join(' ')
        cmd := 'ar rcs -o $outfile ${ofiles}'
        println(cmd)
        ret := os.system(cmd)
        if ret != 0 {
            exit(1)
        }
    } else {
        println('no files modified, no neeed to ar')
    }
}
