#include "util.h"

/*
  Parsing the instruction:
  ABCDE
  01002 (for example)

  2 digit op-code = ip % 100
  mode1 = ip % 1000 / 100
  mode2 = ip % 10000 / 1000
  mode3 = ip % 100000 / 10000
 */

class IntCode {
 public:
  IntCode(std::vector<int> prog) : program{prog}, ip{0}, retval{0} {}

  int run(int input) {
    for(; program[ip] != 99;){
      if(retval != 0) {
        std::cout << "ERROR: output non zero before end\n";
        return -999;
      }

      int opcode = program[ip] % 100;
      switch(opcode) {
        case 1: { // ADD
          program[program[ip + 3]] = op_1() + op_2();
          ip += 4;
        } break;
        case 2: { // MUL
          program[program[ip + 3]] = op_1() * op_2();
          ip += 4;
        } break;
        case 3: { // INPUT
          program[program[ip + 1]] = input;
          ip += 2;
        } break;
        case 4: { // OUTPUT
          retval = op_1();
          ip += 2;
        } break;
        case 5: { // JUMP IF TRUE
          auto cond = op_1();
          if(cond != 0) {
            ip = op_2();
          } else {
            ip += 3;
          }
        } break;
        case 6: { // JUMP IF FALSE
          auto cond = op_1();
          if(cond == 0) {
            ip = op_2();
          } else {
            ip += 3;
          }
        } break;
        case 7: { // LESS THAN
          auto p1 = op_1();
          auto p2 = op_2();
          if(p1 < p2) {
            program[program[ip + 3]] = 1;
          } else {
            program[program[ip + 3]] = 0;
          }
          ip += 4;
        } break;
        case 8: { // EQUALS
          auto p1 = op_1();
          auto p2 = op_2();
          if(p1 == p2) {
            program[program[ip + 3]] = 1;
          } else {
            program[program[ip + 3]] = 0;
          }
          ip += 4;
        } break;
      }
    }
    return retval;
  }

  void print() {
    std::cout << "program:\n";
    for(auto e : program) {
      std::cout << e << "\n";
    }
  };

 private:
  std::vector<int> program;
  int ip;
  int retval;

  int access(int addr, int mode) {
    switch(mode) {
      case 0: {
        return program[program[addr]];
      } break;
      case 1: {
        return program[addr];
      } break;
    }
    return -1;
  }
  int op_1() {
    auto mode = program[ip] % 1000 / 100;
    return access(ip + 1, mode);
  }

  int op_2() {
    auto mode = program[ip] % 10000 / 1000;
    return access(ip + 2, mode);
  }

  int op_3() {
    auto mode = program[ip] % 100000 / 10000;
    return access(ip + 3, mode);
  }
};

int main() {
  auto lines = get_lines<std::string>("day5.input");
  IntCode computer1{get_line_elems<int>(lines[0], ',')};
  IntCode computer2{get_line_elems<int>(lines[0], ',')};
  // std::vector<int> tmp = {3,0,4,0,99};
  // std::vector<int> tmp = {3,9,8,9,10,9,4,9,99,-1,8};
  // std::vector<int> tmp = {3,3,1105,-1,9,1101,0,0,12,4,12,99,1};
  // IntCode computer{tmp};
  // auto retval = computer.run(9);
  // std::cout << "Test retval: " << retval << "\n";

  auto retval1 = computer1.run(1);
  std::cout << "Part 1 retval: " << retval1 << "\n";

  auto retval2 = computer2.run(5);
  std::cout << "Part 2 retval: " << retval2 << "\n";
}
