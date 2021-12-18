#include "util.h"

class IntCode {
 public:
  IntCode(std::vector<int64_t> prog)
      : program{prog}, ip{0}, opcode{program[ip] % 100},
        outputs{}, retval{0}, inputs{}, cur_input{inputs.begin()},
        relative_base{0}
  {}

  IntCode(std::vector<int64_t> prog, int64_t phase) : IntCode{prog} {
    take_input(phase);
  }

  bool halted() const {
    return opcode == 99;
  }

  void run() {
    while(!halted() &&
          !(opcode == 3 && cur_input == inputs.end())) {
      step();
    }
  }

  void run(std::vector<int64_t> new_inputs) {
    take_inputs(new_inputs);
    run();
  }

  void run(int64_t new_input) {
    take_input(new_input);
    run();
  }

  std::vector<int64_t> pop_outputs() {
    auto res = outputs;
    outputs.clear();
    return res;
  }

  int64_t last_output() const {
    return retval;
  }

  void step() {
    switch(opcode) {
      case 1: { // ADD
        auto p1 = op_1();
        auto p2 = op_2();
        auto p3 = op_3();
        program[p3] = program[p1] + program[p2];
        ip += 4;
      } break;
      case 2: { // MUL
        auto p1 = op_1();
        auto p2 = op_2();
        auto p3 = op_3();
        program[p3] = program[p1] * program[p2];
        ip += 4;
      } break;
      case 3: { // INPUT
        auto input = *cur_input;
        cur_input++;
        auto p1 = op_1();
        program[p1] = input;
        ip += 2;
      } break;
      case 4: { // OUTPUT
        auto p1 = op_1();
        retval = program[p1];
        outputs.push_back(retval);
        ip += 2;
      } break;
      case 5: { // JUMP IF TRUE
        auto p1 = op_1();
        auto cond = program[p1];
        if(cond != 0) {
          auto p2 = op_2();
          ip = program[p2];
        } else {
          ip += 3;
        }
      } break;
      case 6: { // JUMP IF FALSE
        auto p1 = op_1();
        auto cond = program[p1];
        if(cond == 0) {
          auto p2 = op_2();
          ip = program[p2];
        } else {
          ip += 3;
        }
      } break;
      case 7: { // LESS THAN
        auto p1 = op_1();
        auto p2 = op_2();
        auto p3 = op_3();
        auto v1 = program[p1];
        auto v2 = program[p2];
        if(v1 < v2) {
          program[p3] = 1;
        } else {
          program[p3] = 0;
        }
        ip += 4;
      } break;
      case 8: { // EQUALS
        auto p1 = op_1();
        auto p2 = op_2();
        auto p3 = op_3();
        auto v1 = program[p1];
        auto v2 = program[p2];
        if(v1 == v2) {
          program[p3] = 1;
        } else {
          program[p3] = 0;
        }
        ip += 4;
      } break;
      case 9: { // INC RELATIVE BASE
        auto p1 = op_1();
        auto param = program[p1];
        relative_base += param;
        ip += 2;
      } break;
    }
    opcode = program[ip] % 100;
  }

  void print() {
    std::cout << "program:\n";
    for(auto e : program) {
      std::cout << e << "\n";
    }
  };

 private:
  std::vector<int64_t> program;
  int64_t ip;
  int64_t opcode;
  std::vector<int64_t> outputs;
  int64_t retval;
  std::vector<int64_t> inputs;
  std::vector<int64_t>::iterator cur_input;
  int64_t relative_base;

  void take_input(int64_t new_input) {
    auto dist = std::distance(inputs.begin(), cur_input);
    inputs.push_back(new_input);
    cur_input = inputs.begin() + dist;
  }

  void take_inputs(std::vector<int64_t> new_inputs) {
    auto dist = std::distance(inputs.begin(), cur_input);
    inputs.insert(inputs.end(), new_inputs.begin(), new_inputs.end());
    cur_input = inputs.begin() + dist;
  }

  int64_t get_computed_addr(int64_t addr, int64_t mode) {
    int64_t computed_addr = 0;
    switch(mode) {
      case 0: { // position
        computed_addr = program[addr];
      } break;
      case 1: { // immediate
        computed_addr = addr;
      } break;
      case 2: { // relative
        computed_addr = program[addr] + relative_base;
      } break;
    }
    if(computed_addr >= program.size()) {
      program.resize(computed_addr + 1);
    }
    return computed_addr;
  }
  int64_t op_1() {
    auto mode = program[ip] % 1000 / 100;
    return get_computed_addr(ip + 1, mode);
  }

  int64_t op_2() {
    auto mode = program[ip] % 10000 / 1000;
    return get_computed_addr(ip + 2, mode);
  }

  int64_t op_3() {
    auto mode = program[ip] % 100000 / 10000;
    return get_computed_addr(ip + 3, mode);
  }
};

int main() {
  // IntCode computer{{109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99}};
  // IntCode computer{{1102,34915192,34915192,7,4,7,99,0}, 0};
  // IntCode computer{{104,1125899906842624LL,99}, 0};
  // std::vector<int64_t> program{209, 5, 204, 4, 99, 1};
  auto lines = get_lines<std::string>("day9.input");
  auto program = get_line_elems<int64_t>(lines[0], ',');
  IntCode computer{program, 2};
  computer.run();
  auto vals = computer.pop_outputs();
  for(auto v : vals) {
    std::cout << v << ",";
  }
  std::cout << "\n";
}
