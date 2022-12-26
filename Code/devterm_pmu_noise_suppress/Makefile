all: devterm_pmu_noise_suppress
devterm_pmu_noise_suppress: main.cpp
	g++ main.cpp -O2 -o devterm_pmu_noise_suppress
install: devterm_pmu_noise_suppress devterm-pmu-suppress-noise.service
	install devterm_pmu_noise_suppress /usr/local/bin/
	install -m644 devterm-pmu-suppress-noise.service /etc/systemd/system/
	systemctl daemon-reload
