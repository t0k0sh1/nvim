#include "greeting.hpp"

std::string greeting(const std::string &name) {
  if (name.empty()) {
    return "Hello!";
  }

  return "Hello, " + name + "!";
}

std::string audience(int count) {
  if (count == 1) {
    return "person";
  }

  return "people";
}
