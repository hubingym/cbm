module main

import os
import json

const (
    json_filename = 'build.json'
    type_program = 'program'
    type_lib = 'lib'
)

struct BuildJson {
    name string
    // desc string
    // version string
    buildtype string  // lib or program
    install_dir string
    win32install_dir string
    run_args string
    cflags string
    cxxflags string
    ldflags string
    win32ldflags string
    subdirs []string
}

fn write_build_json(dir string, is_lib bool) {
    name := os.filename(dir)
    path := '$dir/$json_filename'
    mut install_dir := ''
    mut win32install_dir := ''
    mut type_ := type_lib
    if !is_lib {
        install_dir = '/usr/local/bin'
        win32install_dir = 'C:/bin'
        type_ = type_program
    }
    text := '
{
  "name": "$name",
  "desc": "",
  "version": "1.0.0",
  "buildtype": "${type_}",
  "install_dir": "$install_dir",
  "win32install_dir": "$win32install_dir",
  "run_args": "",
  "cflags": "",
  "cxxflags": "",
  "ldflags": "",
  "win32ldflags": "",
  "subdirs": []
}
'
    os.write_file(path, text)
}

fn read_build_json(dir string) ?BuildJson {
    path := '$dir/$json_filename'
    content := os.read_file(path) or {
        return error('Failed to read build.json, please check build.json exists.')
    }
    build_json := json.decode(BuildJson, content) or {
        return error('Failed to decode build.json.')
    }
    return build_json
}
