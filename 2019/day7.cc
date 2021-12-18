#include "util.h"

class IntCode {
 public:
  IntCode(std::vector<int> prog, int phase)
      : program{prog}, ip{0}, opcode{program[ip] % 100},
        outputs{}, retval{0}, inputs{phase}, cur_input{inputs.begin()} {}

  bool halted() const {
    return opcode == 99;
  }

  void run(std::vector<int> new_inputs) {
    auto dist = std::distance(inputs.begin(), cur_input);
    inputs.insert(inputs.end(), new_inputs.begin(), new_inputs.end());
    cur_input = inputs.begin() + dist;
    while(!halted() &&
          !(opcode == 3 && cur_input == inputs.end())) {
      step();
    }
  }

  void run(int new_input) {
    auto dist = std::distance(inputs.begin(), cur_input);
    inputs.push_back(new_input);
    // inputs.insert(inputs.end(), new_inputs.begin(), new_inputs.end());
    cur_input = inputs.begin() + dist;
    while(!halted() &&
          !(opcode == 3 && cur_input == inputs.end())) {
      step();
    }
  }

  std::vector<int> pop_outputs() {
    auto res = outputs;
    outputs.clear();
    return res;
  }

  int last_output() const {
    return retval;
  }

  void step() {
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
        auto input = *cur_input;
        cur_input++;
        program[program[ip + 1]] = input;
        ip += 2;
      } break;
      case 4: { // OUTPUT
        retval = op_1();
        outputs.push_back(retval);
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
    opcode = program[ip] % 100;
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
  int opcode;
  std::vector<int> outputs;
  int retval;
  std::vector<int> inputs;
  std::vector<int>::iterator cur_input;

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

int part1(std::vector<int> prog) {
  std::vector<int> phases = {0, 1, 2, 3, 4};
  int max_signal = INT_MIN;
  do {
    IntCode computer1{prog, phases[0]};
    IntCode computer2{prog, phases[1]};
    IntCode computer3{prog, phases[2]};
    IntCode computer4{prog, phases[3]};
    IntCode computer5{prog, phases[4]};
    computer1.run(0);
    auto r1 = computer1.last_output();
    computer2.run(r1);
    auto r2 = computer2.last_output();
    computer3.run(r2);
    auto r3 = computer3.last_output();
    computer4.run(r3);
    auto r4 = computer4.last_output();
    computer5.run(r4);
    auto r5 = computer5.last_output();
    if(r5 > max_signal) { max_signal = r5; }
  } while (std::next_permutation(phases.begin(), phases.end()));
  return max_signal;
}

/*
  When a computer needs an input, it calls back into its provider.
  How does a computer receive input from another object?
  Somehow send an output when necessary?
  Or just observe an object, but has to know when its ready?

  run a computer until it hits an input, then walk back provider and run it until it produces a value, which we then hand off and continue.
  if at any time we need to wait, we walk back

  each computer starts with a phase and a callback for reading input
  on INPUT, consume the phase first
  then, call in to the callback to retrieve the next input

  OR
  run computer1 with the amplifier number until it hits an output instruction,
  which I then carry over to the next computer as another input?
  run each computer until it hits input, then send in the input phase.
  run each computer until it hits input or output? then propogate?

  in a loop, until all computers halt:
    there's a list of inputs passed to a computer
    the computer runs, emitting outputs, until it hits an input instruction
    pass all outputs to next amp, continue loop

  keep a queue of each computer's outputs
  after each runs to input, update all inputs for next computer,
  next loop
 */
int part2(std::vector<int> prog) {
  std::vector<int> phases = {5, 6, 7, 8, 9};
  int max_signal = INT_MIN;
  do {
    IntCode computer1{prog, phases[0]};
    IntCode computer2{prog, phases[1]};
    IntCode computer3{prog, phases[2]};
    IntCode computer4{prog, phases[3]};
    IntCode computer5{prog, phases[4]};
    int c1input = 0;
    while(!computer1.halted() &&
          !computer2.halted() &&
          !computer3.halted() &&
          !computer4.halted() &&
          !computer5.halted()) {
      computer1.run(c1input);
      computer2.run(computer1.last_output());
      computer3.run(computer2.last_output());
      computer4.run(computer3.last_output());
      computer5.run(computer4.last_output());
      c1input = computer5.last_output();
    }
    auto res = computer5.last_output();
    if(res > max_signal) { max_signal = res; }
  } while (std::next_permutation(phases.begin(), phases.end()));
  return max_signal;
}

int main() {
  auto lines = get_lines<std::string>("day7.input");
  auto prog = get_line_elems<int>(lines[0], ',');
  // std::vector<int> prog = {3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26, 27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5}; // should return 139629729
  // std::vector<int> prog = {3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54, -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4, 53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10}; // should return 18216

  auto p1 = part1(prog);
  std::cout << "Part 1: " << p1 << "\n";

  auto p2 = part2(prog);
  std::cout << "Part 2: " << p2 << "\n";
}
