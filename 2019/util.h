#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <string>
#include <stdint.h>

template<typename T>
std::vector<T> get_lines(const char* filename) {
  std::ifstream ifs(filename);
  T elem;
  std::vector<T> lines;
  while(ifs >> elem) {
    lines.push_back(elem);
  }
  return lines;
}

template<typename T>
std::vector<T> get_lines_str(const char* str) {
  std::istringstream iss{str};
  T elem;
  std::vector<T> lines;
  while(iss >> elem) {
    lines.push_back(elem);
  }
  return lines;
}

template<typename T>
std::vector<T> get_line_elems(std::string line, char sep) {
  std::vector<T> res;
  std::istringstream iss(line);
  std::string token;
  while(std::getline(iss, token, sep)) {
    T elem;
    std::istringstream(token) >> elem;
    res.push_back(elem);
  }
  return res;
}
