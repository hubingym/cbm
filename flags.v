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
    run_args string
    cflags string
    cxxflags string
    ldflags string
    win32ldflags string
}

fn write_build_json(dir string) {
    name := os.filename(dir)
    path := '$dir/$json_filename'
    mut prefix := '/usr/local/bin'
    if os.user_os() == 'windows' {
        prefix = 'C:/bin'
    }
    text := '
{
  "name": "$name",
  "desc": "",
  "version": "1.0.0",
  "buildtype": "${type_program}",
  "install_dir": "$prefix",
  "run_args": "",
  "cflags": "",
  "cxxflags": "",
  "ldflags": "",
  "win32ldflags": ""
}
'
    os.write_file(path, text)
}

fn read_build_json(dir string) ?BuildJson {
    path := '$dir/$json_filename'
    content := os.read_file(path) or {
        return error('error reading file $path')
    }
    build_json := json.decode(BuildJson, content) or {
        return error('Failed to decode build.json')
    }
    return build_json
}
