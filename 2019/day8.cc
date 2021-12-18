#include "util.h"

const int width = 25;
const int height = 6;
// const int width = 2;
// const int height = 2;

class Image {
 public:
  Image(const std::vector<int>& raw) {
    for(auto it = raw.cbegin();
        it != std::cend(raw);
        it += width * height) {
      // std::cout << "New Layer\n";
      Layer l{it};
      layers.push_back(l);
    }
  }

  int part1() const {
    int num_zeros = INT_MAX;
    int layer_id;
    for(int id = 0; id < layers.size(); id++) {
      auto num = layers[id].get_num_zeros();
      if(num < num_zeros) {
        num_zeros = num;
        layer_id = id;
      }
    }
    return layers[layer_id].get_num_ones() * layers[layer_id].get_num_twos();
  }

  std::vector<int> part2() const {
    std::vector<int> res;
    for(int idx = 0; idx < width * height; idx++) {
      for(const auto& layer : layers) {
        if(layer.at(idx) == 0) {
          res.push_back(0);
          break;
        } else if(layer.at(idx) == 1) {
          res.push_back(1);
          break;
        }
      }
    }
    return res;
  }

 private:
  class Layer{
   public:
    Layer(std::vector<int>::const_iterator start)
        : num_zeros{0}, num_ones{0}, num_twos{0} {
      for(auto it = start; it < start + width * height; it++) {
        auto num = *it;
        // std::cout << num << "\n";
        data.push_back(num);
        switch(num) {
          case 0: {
            num_zeros++;
          } break;
          case 1: {
            num_ones++;
          } break;
          case 2: {
            num_twos++;
          } break;
        }
      }
    }
    int get_num_zeros() const { return num_zeros; }
    int get_num_ones() const { return num_ones; }
    int get_num_twos() const { return num_twos; }
    int at(int idx) const { return data[idx]; }

   private:
    std::vector<int> data;
    int num_zeros;
    int num_ones;
    int num_twos;
  };
  std::vector<Layer> layers;
};

int main() {
  auto lines = get_lines<std::string>("day8.input");
  std::vector<int> data;
  for(const auto& c : lines[0]) {
    data.push_back(c - '0');
  }
  Image image{data};
  std::cout << "Part 1: " << image.part1() << "\n";
  auto p2 = image.part2();
  std::cout << "Part 2:\n";
  for(int y = 0; y < height; y++) {
    for(int x = 0; x < width; x++) {
      std::cout << (p2[x + y*width] ? "#" : " ");
    }
    std::cout << "\n";
  }
}
