# cbm
c/c++ build manager

## usage

cbm [options] cmd  

options:   
-h // 显示帮助   
-d dir // 代码目录  

cmd:  
init // 初始化项目会生成build.json  
clean  
build // 构建项目  
run  // 运行项目  


## build.json


    {
		"name": "",
		"type": "",
		"cflags": "",
		"cxxflags": "",
		"ldflags": "",
	}

name: 应用名称,如果是静态库,最终名称为libxx.a  
type: lib(静态库) or program(可执行程序)  