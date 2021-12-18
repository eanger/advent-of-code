#include "util.h"
#include <unordered_map>
#include <unordered_set>

/*
  simple first: node with parent pointer.
  also a hash from name to node, to hook up parents

  PART 2
  Find list of steps from SAN to COM
  Walk backwards from YOU and count until you hit something on the list
  when you hit, add the steps walking backwards from SAN to hit
 */

struct Node {
  Node(): parent{nullptr} {}
  Node* parent;
};

int count(Node* cur) {
  if(!cur->parent) { return 0; }
  return 1 + count(cur->parent);
}

int main() {
  std::unordered_map<std::string, Node> orbit_map;
  auto lines = get_lines<std::string>("day6.input");
  // auto lines = get_lines_str<std::string>("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L");
  // auto lines = get_lines_str<std::string>("COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN");
  for(const auto& l : lines) {
    auto elems = get_line_elems<std::string>(l, ')');
    // elems[1] orbits around elems[0]
    auto& node = orbit_map[elems[1]];
    node.parent = &orbit_map[elems[0]];
  }

  std::unordered_map<Node*, int> seen;
  int cnt = 0;
  for(auto& e : orbit_map) {
    cnt += count(&e.second);
  }
  std::cout << "Part1: " << cnt << "\n";

  std::unordered_set<Node*> san_path;
  for(Node* s = orbit_map["SAN"].parent; s->parent; s = s->parent) {
    san_path.insert(s);
  }
  int transfers = 0;
  for(Node* s = orbit_map["YOU"].parent; s->parent; s = s->parent) {
    if(san_path.find(s) != std::end(san_path)) {
      for(Node* ss = orbit_map["SAN"].parent; ss != s; ss = ss->parent) {
        transfers++;
      }
      break;
    }
    transfers++;
  }
  std::cout << "Part2: " << transfers << "\n";
}
