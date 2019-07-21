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
    buildtype string  // lib or program
    cflags string
    cxxflags string
    ldflags string
    desc string
}

fn write_build_json(dir string) {
    name := dir.all_after('/')
    path := '$dir/$json_filename'
    text := '
{
  "name": "$name",
  "buildtype": "lib",
  "cflags": "",
  "cxxflags": "",
  "ldflags": "",
  "desc": ""
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
        return error('Failed to decode $json_filename')
    }
    return build_json
}
