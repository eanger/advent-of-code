#include <iostream>
#include <fstream>
#include <vector>
#include <sstream>
#include <string>

void run_program_part1(std::vector<int>& program) {
  for(int ip = 0; program[ip] != 99; ip += 4){
    int op1 = program[program[ip + 1]];
    int op2 = program[program[ip + 2]];
    int dest = program[ip + 3];
    if(program[ip] == 1) {
      // do ADD op
      program[dest] = op1 + op2;
    } else {
      // do MUL op
      program[dest] = op1 * op2;
    }
  }
}

int run_program_part2(const std::vector<int>& program) {
  for(int noun = 0; noun < 100; noun++) {
    for(int verb = 0; verb < 100; verb++) {
      auto candidate = program;
      candidate[1] = noun;
      candidate[2] = verb;
      run_program_part1(candidate);
      if(candidate[0] == 19690720) { return 100 * noun + verb; }
    }
  }
  return 0;
}

int main() {
  std::ifstream ifs("day2.input");
  std::string full_input;
  std::getline(ifs, full_input);
  std::istringstream iss(full_input);
  std::string token;
  std::vector<int> program;
  while(std::getline(iss, token, ',')){
    program.push_back(std::stoi(token));
  }
  auto program2 = program;
  program[1] = 12;
  program[2] = 2;
  run_program_part1(program);
  auto part_2_result = run_program_part2(program2);

  std::cout << program[0] << "\n";
  std::cout << part_2_result << "\n";
}
