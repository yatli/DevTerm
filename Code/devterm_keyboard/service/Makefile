install:
	install -m 644 devterm-keyboard.service /etc/systemd/system/
	install -m 644 devterm-mouse.service /etc/systemd/user/
	install devterm_keyboard.py /usr/local/bin/
	install devterm_mouse.py /usr/local/bin/
	install root-notify-send /usr/local/bin/
	ln -s `which gearbox-clockworkpi-a06` /usr/local/bin/devterm_gearbox.py
	pip install pyserial
	install 99-uinput.rules /usr/lib/udev/rules.d/
	udevadm control --reload
	systemctl daemon-reload
	systemctl enable devterm-keyboard.service
	systemctl restart devterm-keyboard.service
	@echo ">> Note: run these commands manually (without sudo):"
	@echo "  systemctl --user enable devterm-mouse.service"
	@echo "  systemctl --user restart devterm-mouse.service"
update:
	install devterm_keyboard.py /usr/local/bin/
	install devterm_mouse.py /usr/local/bin/
	install 99-uinput.rules /usr/lib/udev/rules.d/
	udevadm control --reload
	systemctl daemon-reload
	systemctl restart devterm-keyboard.service
	@echo ">> Note: run these commands manually (without sudo):"
	@echo "  systemctl --user enable devterm-mouse.service"
	@echo "  systemctl --user restart devterm-mouse.service"
