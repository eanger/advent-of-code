#include "util.h"
#include <optional>


/*
How do you tell if and where two line segments intersect?


(x,y)->(z,w) represent ONE segment
(a,b)->(c,d) represent ONE segment
1. if parallel, don't intersect
2. if one segment is fully left or fully above the other, they don't intersect
3. otherwise, intersection is y of horizantal segment and x of vertical segment

0,0 -> 7,0
1,1 -> 5,1

p1 x p2 > 0 ? clockwise : ccw

b.x . a.x . b.y is ordered
3 2 1 : 1 1
1 2 3 : -1 -1
1 8 9 : -7 -1
sign of a.x - b.x is same as b.y - a.x

x1 - x2,y1 - y2

===== PART 2 =====
keep track of distances up to a segment.
when intersecting, sum distances plus distance to intersection.

 */

int orientation(int x1, int y1, int x2, int y2, int x3, int y3) {
  auto orient = (y2 - y1) * (x3 - x2) - (x2 - x1) * (y3 - y2);
  if(orient == 0) { return 0; }
  return orient > 0 ? 1 : 2;
}

struct Segment {
  int x,y,z,w;
  int distance_to;
  bool vert;
  Segment(int x, int y, int z, int w, int t) : x{x}, y{y}, z{z}, w{w}, distance_to{t}, vert{is_vert()} {}
  bool is_vert() const {
    return (z - x) == 0;
  }

  std::optional<int> get_intersection(Segment other) const {
    if(does_intersect(other)) {
      if(vert) {
        return std::abs(x) + std::abs(other.y);
      } else {
        return std::abs(other.x) + std::abs(y);
      }
    }
    return {};
  }

  std::optional<int> get_intersection_part2(Segment other) const {
    if(does_intersect(other)) {
      if(vert) {
        return distance_to + other.distance_to + std::abs(other.y - y) + std::abs(x - other.x);
      } else {
        return distance_to + other.distance_to + std::abs(y - other.y) + std::abs(other.x - x);
      }
    }
    return {};
  }

  bool does_intersect(Segment s) const {
    auto o1 = orientation(x, y, z, w, s.x, s.y);
    auto o2 = orientation(x, y, z, w, s.z, s.w);
    auto o3 = orientation(s.x, s.y, s.z, s.w, x, y);
    auto o4 = orientation(s.x, s.y, s.z, s.w, z, w);
    return o1 != o2 && o3 != o4;
  }

  friend std::ostream& operator<<(std::ostream& os, const Segment& s);
};

std::ostream& operator<<(std::ostream& os, const Segment& s)
{
  os << "Seg(" << s.x << "," << s.y << "," << s.z << "," << s.w
     << ") dist: " << s.distance_to
     << "\n";
  return os;
}

int cross(int x1, int y1, int x2, int y2) {
  return x1 * y2 - y1 * x2;
}

std::vector<Segment> to_segs(std::string line) {
  int x = 0, y = 0;
  int cur_dist = 0;
  std::vector<Segment> res;
  std::istringstream input{line};
  for(std::string word; std::getline(input, word, ',');) {
    auto inc = std::stoi(word.substr(1));
    switch(word[0]) {
      case 'R': {
        res.emplace_back(x, y, x + inc, y, cur_dist);
        x += inc;
        cur_dist += inc;
      } break;
      case 'L': {
        res.emplace_back(x, y, x - inc, y, cur_dist);
        x -= inc;
        cur_dist += inc;
      } break;
      case 'D': {
        res.emplace_back(x, y, x, y - inc, cur_dist);
        y -= inc;
        cur_dist += inc;
      } break;
      case 'U': {
        res.emplace_back(x, y, x, y + inc, cur_dist);
        y += inc;
        cur_dist += inc;
      } break;
    }
  }
  return res;
}

int main() {
  auto lines = get_lines<std::string>("day3.input");
  auto wire1 = to_segs(lines[0]);
  auto wire2 = to_segs(lines[1]);
  // auto wire1 = to_segs("R8,U5,L5,D3");
  // for(const auto& w : wire1) {
  //   std::cout << "wire1: " << w << "\n";
  // }
  // auto wire2 = to_segs("U7,R6,D4,L4");
  // for(const auto& w : wire2) {
  //   std::cout << "wire2: " << w << "\n";
  // }
  std::vector<int> intersections_part1;
  std::vector<int> intersections_part2;
  for(const auto& seg1 : wire1) {
    for(const auto& seg2 : wire2) {
      if(auto intersect = seg1.get_intersection(seg2); intersect) {
        intersections_part1.push_back(*intersect);
      }
      if(auto intersect = seg1.get_intersection_part2(seg2); intersect) {
        intersections_part2.push_back(*intersect);
      }
    }
  }
  int min_dist_part1 = INT_MAX;
  for(const auto& intersection : intersections_part1) {
    if((intersection != 0) && (intersection < min_dist_part1)) {
      min_dist_part1 = intersection;
    }
  }
  int min_dist_part2 = INT_MAX;
  for(const auto& intersection : intersections_part2) {
    if((intersection != 0) && (intersection < min_dist_part2)) {
      min_dist_part2 = intersection;
    }
  }
  std::cout << "Part1 Min dist: " << min_dist_part1 << "\n";
  std::cout << "Part2 Min dist: " << min_dist_part2 << "\n";
}
