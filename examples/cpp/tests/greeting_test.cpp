#include "greeting.hpp"

#include <gtest/gtest.h>

TEST(GreetingTest, GreetsNamedPerson) {
  EXPECT_EQ(greeting("C++"), "Hello, C++!");
}

TEST(GreetingTest, GreetsWithoutName) { EXPECT_EQ(greeting(""), "Hello!"); }
