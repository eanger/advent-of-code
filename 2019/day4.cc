#include "util.h"
#include <array>

#define pass_min 234208
#define pass_max 765869

// #define s 234444
// #define e 699999

bool is_valid_part1(int a, int b, int c, int d, int e, int f) {
  auto val = a * 100000 + b * 10000 + c * 1000 + d * 100 + e * 10 + f;
  return (a == b || b == c || c == d || d == e || e == f) &&
      a <= b && b <= c && c <= d && d <= e && e <= f &&
      val <= pass_max && val >= pass_min;
}

int count_valid_p1() {
  int count = 0;
  for(int a = 2; a <= 7; a++) {
    for(int b = 0; b <= 9; b++) {
      for(int c = 0; c <= 9; c++) {
        for(int d = 0; d <= 9; d++) {
          for(int e = 0; e <= 9; e++) {
            for(int f = 0; f <= 9; f++) {
              auto v = is_valid_part1(a, b, c, d, e, f);
              // std::cout << a << "," << b << "," << c << "," << d << "," << e << "," << f << (v ? "VAL" : "INV") << "\n";
              if(v) {
                count += 1;
              }
            }
          }
        }
      }
    }
  }
  return count;
}

/*
Part 2
must contain only one set of two matching digits.
vector of digit counts, and to be valid must obey other rules and also only have one group with value of 2
 */
bool one_of(std::array<int,10> c) {
  for(auto x : c) {
    if(x == 2){
      return true;
    }
  }
  return false;
}

int count_valid_p2() {
  int count = 0;
  for(int a = 2; a <= 7; a++) {
    for(int b = 0; b <= 9; b++) {
      for(int c = 0; c <= 9; c++) {
        for(int d = 0; d <= 9; d++) {
          for(int e = 0; e <= 9; e++) {
            for(int f = 0; f <= 9; f++) {
              std::array<int,10> counts = {};
              counts[a]++;
              counts[b]++;
              counts[c]++;
              counts[d]++;
              counts[e]++;
              counts[f]++;
              auto val = a * 100000 + b * 10000 + c * 1000 + d * 100 + e * 10 + f;
              if(a <= b && b <= c && c <= d && d <= e && e <= f &&
                 val <= pass_max && val >= pass_min &&
                 one_of(counts)) {
                count += 1;
              }
            }
          }
        }
      }
    }
  }
  return count;
}

int main() {
  int count_p1 = count_valid_p1();
  int count_p2 = count_valid_p2();

  std::cout << "Part 1 count: " << count_p1 << "\n";
  std::cout << "Part 2 count: " << count_p2 << "\n";

}
