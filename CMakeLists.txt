cmake_minimum_required(VERSION 3.0.0)
project(a.out VERSION 0.1.0)

include(CTest)
enable_testing()

add_executable(a.out run_main.s func_select.s pstring.s makefile)

set(CPACK_PROJECT_NAME ${PROJECT_NAME})
set(CPACK_PROJECT_VERSION ${PROJECT_VERSION})
include(CPack)
