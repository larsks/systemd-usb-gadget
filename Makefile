sbindir=/sbin
unitdir=/etc/systemd/system

UNITS = \
	usb-gadget@.service

SCRIPTS = \
	configure-gadget.sh \
	remove-gadget.sh

all:

install: install-scripts install-units

install-scripts: $(SCRIPTS)
	for s in $(SCRIPTS); do \
		install -m 755 $$s $(DESTDIR)$(sbindir)/$${s%.sh}; \
	done

install-units: $(UNITS)
	for u in $(UNITS); do \
		install -m 600 $$u $(DESTDIR)$(unitdir); \
	done
