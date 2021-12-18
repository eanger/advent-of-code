#include "util.h"

#include <numeric>

/*
  for each asteroid A:
    consider each other asteroid B:
      walk back from B to A by smallest whole increment of B - A
      if we hit another asteroid, continue
      else increment count


  0,0 to 6,3 -> (6 - 0), (3 - 0) -> 2,1
  0,0 to 4,4 -> (4 - 0), (4 - 0) -> 1,1
  G = gcd(x2-x1, y2-y1), walk by (x2-x1)/G,(y2-y1)/G

  .7..7
  .....
  67775
  ....7
  ...87

 */

struct Coord {
  int x;
  int y;

  Coord(int x, int y) : x{x}, y{y} {}
  bool operator==(const Coord& rhs) const
  {
    return x == rhs.x && y == rhs.y;
  }

  bool can_see(Coord other, const std::vector<Coord>& world) const {
    auto diff_x = other.x - x;
    auto diff_y = other.y - y;
    auto divisor = std::gcd(diff_x, diff_y);
    auto inc_x = diff_x / divisor;
    auto inc_y = diff_y / divisor;
    // std::cout << "(" << x << "," << y << ")\n";
    // std::cout << "(" << other.x << "," << other.y << ")\n";
    // std::cout << divisor << ": (" << inc_x << "," << inc_y << ")\n";
    for(int i = x + inc_x, j = y + inc_y;
        !(i == other.x && j == other.y);
        // i != other.x && j != other.y;
        i += inc_x, j += inc_y) {
      // std::cout << "c(" << i << "," << j << ")\n";
      for(const auto& asteroid: world) {
        if(asteroid == Coord(i, j)) {
          // std::cout << "N\n";
          return false;
        }
      }
    }
    // std::cout << "Y\n";
    return true;
  }
};

int main() {
  auto lines = get_lines<std::string>("day10.input");

  std::vector<Coord> asteroids;
  int x;
  int y = 0;
  for(auto line: lines) {
    x = 0;
    for(auto c : line) {
      if(c == '#') {
        asteroids.emplace_back(x, y);
      }
      x++;
    }
    y++;
  }

  int max_viewable = 0;
  for(auto base: asteroids) {
    // std::cout << "(" << base.x << "," << base.y << ")\n";
    int viewable = 0;
    for(auto candidate: asteroids) {
      if(candidate == base) { continue; }
      if(base.can_see(candidate, asteroids)) {
        viewable++;
      }
    }
    // std::cout << "Viewable: " << viewable << "\n";
    if(viewable > max_viewable) {
      max_viewable = viewable;
    }
  }
  std::cout << "Part 1: " << max_viewable << "\n";
}
