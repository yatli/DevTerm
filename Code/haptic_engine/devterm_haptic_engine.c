#include <fcntl.h>
#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>
#include <assert.h>
#include <signal.h>

#include <wiringPi.h>
#include <portmidi.h>
#include <porttime.h>

#include "config.h"
#include "motor.h"
#include "utils.h"

const PmDeviceInfo* pm_device;
PortMidiStream *pm_stream;
int pm_stream_ready = 0;
PmQueue *pm_queue;

void midi_proc(PtTimestamp timestamp, void *_userdata) {
  PmError result;
  PmEvent buffer;
  if (!pm_stream_ready) {
    return;
  }
  do {
    result = Pm_Poll(pm_stream);
    if (result) {
      PmError plresult = Pm_Read(pm_stream, &buffer, 1);
      if (plresult == pmBufferOverflow) {
        continue;
      }
      if (plresult != 1) {
        printf("%d\n", plresult);
      }
      assert(plresult == 1);

      Pm_Enqueue(pm_queue, &buffer.message);
    }
  } while (result);
}

int init_midi() {
  Pm_Initialize();
  pm_stream = NULL;
  pm_stream_ready = 0;
  pm_queue = Pm_QueueCreate(1000, sizeof(int32_t));

  Pt_Start(1, midi_proc, NULL);

  int n = Pm_CountDevices();
  for(int i = 0; i < n; ++i) {
    pm_device = Pm_GetDeviceInfo(i);
    if (!strcmp(pm_device->name, "Midi Through Port-0") && pm_device->input) {
      Pm_OpenInput(&pm_stream, i, NULL, 0, NULL, NULL);
      pm_stream_ready = 1;
      return 0;
    }
  }
  return -1;
}

void sig_handler(int sig_num) {
  PRINTF("DevTerm haptic engine shutting down...\n");
  Pt_Stop();
  Pm_Close(pm_stream);
  stop_motor_synth();
  Pm_QueueDestroy(pm_queue);
  exit(0);
}

void setup() {
  PRINTF("DevTerm haptic engine initializing...\n");
  wiringPiSetupGpio();
  if (init_midi()) {
    PRINTF("Midi init failed\n");
    exit(-1);
  }
  init_motor_synth(pm_queue);
  signal(SIGTERM, sig_handler);
  signal(SIGKILL, sig_handler);
  signal(SIGINT, sig_handler);
  PRINTF("DevTerm haptic engine initialized.\n");
}

int main(int argc, char **argv) {
  setup();
  while (1) {
    sleep(1);
  }
}
