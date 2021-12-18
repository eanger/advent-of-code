#include <iostream>
#include <fstream>
#include <vector>

int calc_fuel_part1(int mass) {
  return mass / 3 - 2;
}

int calc_fuel_part2(int mass) {
  int fuel = mass / 3 - 2;
  for(int extra_fuel = fuel / 3 - 2; extra_fuel > 0; extra_fuel = extra_fuel / 3 - 2){
    fuel += extra_fuel;
  }
  return fuel;
}

int main () {
  std::ifstream ifs("day1.input");
  int i;
  int part1 = 0;
  int part2 = 0;
  while(ifs >> i) {
    part1 += calc_fuel_part1(i);
    part2 += calc_fuel_part2(i);
  }
  std::cout << part1 << "\n";
  std::cout << part2 << "\n";
  return 0;

}
