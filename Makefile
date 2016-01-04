#!/usr/bin/env make -f

PREFIX=/usr
IDENTIFIER=net.CloudFarm.RDM

VERSION=2.2

CC=llvm-g++
PACKAGE_BUILD=/usr/bin/pkgbuild
ARCH_FLAGS=-arch x86_64
CFLAGS = -O2 -pipe

.PHONY: build

RDM.app: SetResX Resources Info.plist monitor.icns
	mkdir -p RDM.app/Contents/MacOS/
	cp SetResX RDM.app/Contents/MacOS/
	cp -r Info.plist Resources RDM.app/Contents
	mv monitor.icns RDM.app/Contents/Resources


SetResX: main.o SRApplicationDelegate.o ResMenuItem.o cmdline.o utils.o 
	$(CC) $^ -o $@ $(ARCH_FLAGS) -framework Foundation -framework ApplicationServices -framework AppKit 


clean:
	rm -f SetResX
	rm -f *.o
	rm -f *icns
	rm -rf RDM.app
	rm -rf pkgroot dmgroot
	rm -f *.pkg *.dmg

%.o: %.mm
	$(CC) $(CPPFLAGS) $(CFLAGS) $(ARCH_FLAGS) $< -c -o $@


%.icns: %.png
	sips -s format icns $< --out $@

pkg: RDM.app
	mkdir -p pkgroot/Applications
	mv $< pkgroot/Applications/
	$(PACKAGE_BUILD) --root pkgroot/  --identifier $(IDENTIFIER) \
		--version $(VERSION) "RDM-$(VERSION).pkg" 
	rm -f RDM.pkg
	ln -s RDM-$(VERSION).pkg RDM.pkg

dmg: pkg
	mkdir -p dmgroot
	cp RDM-$(VERSION).pkg dmgroot/
	rm -f RDM-$(VERSION).dmg
	hdiutil makehybrid -hfs -hfs-volume-name "RDM $(VERSION)" \
		-o "RDM-$(VERSION).dmg" dmgroot/
	rm -f RDM.dmg
	ln -s RDM-$(VERSION).dmg RDM.dmg

.PHONY: pkg dmg install build clean
