#include "module_top.cc"
#include <fmt/core.h>
#include <fmt/format.h>
#include <fstream>
#include <vector>
int main() {
  using module = cxxrtl_design::p_user__module__xoroshiro128;
  module mod;
  mod.step();
  auto &io_in = mod.p_io__in;
  auto &io_out = mod.p_io__out;
  bool success = true;
  std::ofstream outf("outfile.uint64", std::ofstream::binary);
  io_in.set<unsigned int>(1 << 1); // reset
  mod.step();
  io_in.set<unsigned int>(0b11); // reset high, clock
  mod.step();
  unsigned int howmany = 8 * 1000 * 1000;
  for (unsigned int i = 0; i < 8*howmany; ++i) {
    if(!(i & 0xFFFF)) {
      fmt::print("{} of {}\n", i/8, howmany);
    }
    io_in.set<unsigned int>(0);
    mod.step();
    auto val = static_cast<unsigned char>(io_out.get<unsigned int>());
    outf.write(reinterpret_cast<const char *>(&val), 1);
    io_in.set<unsigned int>(1);
    mod.step();
  }
  outf.close();
  return !success;
}
