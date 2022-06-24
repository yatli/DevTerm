install:
	install -m 644 devterm-keyboard.service /etc/systemd/system/
	install devterm_keyboard.py /usr/local/bin/
	install root-notify-send /usr/local/bin/
	sudo ln -s `which gearbox-clockworkpi-a06` /usr/local/bin/devterm_gearbox.py
	# pip install pyserial
	systemctl daemon-reload
	systemctl enable devterm-keyboard.service
	systemctl restart devterm-keyboard.service
