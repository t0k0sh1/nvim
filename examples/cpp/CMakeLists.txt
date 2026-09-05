cmake_minimum_required(VERSION 3.20)
project(greeting LANGUAGES CXX)

enable_testing()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(GTest CONFIG REQUIRED)

add_executable(greeting_test
  src/greeting.cpp
  tests/greeting_test.cpp
)
target_include_directories(greeting_test PRIVATE include)
target_link_libraries(greeting_test PRIVATE GTest::gtest_main)

include(GoogleTest)
gtest_discover_tests(greeting_test)
