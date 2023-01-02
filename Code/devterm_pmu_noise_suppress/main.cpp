#include <iostream>
#include <fstream>
#include <sstream>
#include <chrono>
#include <thread>
#include <string>

struct cpu_stat {
  long long idle;
  long long total;
};

constexpr auto load_strength = 1000 * 3200;
constexpr auto sleep_on_batt = std::chrono::milliseconds(15000);
constexpr auto sleep_on_ac = std::chrono::milliseconds(50);
constexpr auto ac_state_path = "/sys/class/power_supply/axp22x-ac/online";
constexpr auto bat_cap_path = "/sys/class/power_supply/axp20x-battery/capacity";
constexpr auto cpu_stat_path = "/proc/stat";

const std::string cat(const char* path) {
  std::ifstream f(path);
  std::stringstream ss;
  ss << f.rdbuf();
  return ss.str();
}

const cpu_stat get_stat() {
  std::string _;
  long long user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice;
  std::ifstream f(cpu_stat_path);
  f >> _ >> user >> nice >> system >> idle >> iowait >>  irq >> softirq >> steal >> guest >> guest_nice;
  cpu_stat ret;
  ret.idle = idle;
  ret.total = user + nice + system + idle + iowait + irq + softirq + steal + guest + guest_nice;
  return ret;
}

const float calc_util(const cpu_stat& s0, const cpu_stat& s1) {
  long long elapsed = s1.total - s0.total;
  long long idle  = s1.idle - s0.idle;
  return 1.0f - idle / (float)elapsed;
}

#pragma GCC push_options
#pragma GCC optimize ("O0")
void inject_load() {
  for(int i=0; i< load_strength; ++i) {
    double _x = rand() * (double)rand();
  }
}
#pragma GCC pop_options

int main() {
  while(true) {
    auto suppress_enable = 
      cat(ac_state_path) == "1\n"
      && cat(bat_cap_path) == "100\n";
    auto sleep_time = suppress_enable 
      ? sleep_on_ac
      : sleep_on_batt;
    auto stat_begin = get_stat();
    std::this_thread::sleep_for(sleep_time);
    auto stat_end = get_stat();
    if (suppress_enable) {
      auto util = calc_util(stat_begin, stat_end);
      if (util < 0.15) {
        inject_load();
      }
    }
  }
  return 0;
}
