# cbm
c/c++ build manager

## usage

cbm [options] cmd  

options:   
-h // 显示帮助   
-v // 显示版本信息  
-d dir // 代码目录，默认当前目录  

cmd:  
init // 初始化项目会生成build.json  
init --lib // 应用类型为静态库  
clean  
build // 构建项目  
run  // 运行项目  
install // 安装可执行文件  


## build.json


    {
    	"name": "",
    	"desc": "",
    	"version": "1.0.0",
    	"type": "program",
    	"install_dir": "/usr/local/bin",
    	"win32install_dir": "C:/bin",
    	"run_args": "",
    	"cflags": "",
    	"cxxflags": "",
    	"ldflags": "",
    	"win32ldflags": "",
    	"subdirs": [],
    }

name: 应用名称,如果是静态库,最终名称为libxx.a  
type: lib(静态库) or program(可执行程序)  
install_dir: *nix安装路径，默认/usr/local/bin  
win32install_dir: windows安装路径，默认C:/bin  
run_args: 运行参数  
cflags: c flags  
cxxflags: c++ flags  
ldflags: ld flags  
win32ldflags: windows ld flags，如果win32ldflags为空，就使用ldflags  
subdirs: 子目录(字符串数组)，例如["dir1", "dir2", "dir3"]  