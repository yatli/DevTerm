install:
	install -m 644 devterm-keyboard.service /etc/systemd/system/
	install devterm_keyboard.py /usr/local/bin/
	pip install pyserial
	systemctl daemon-reload
	systemctl enable devterm-keyboard.service
	systemctl start devterm-keyboard.service
