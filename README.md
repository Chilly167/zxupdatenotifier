zxUpdateNotifier

A lightweight, injectable tweak that runs in the background and periodically checks for App Store updates of installed apps — ideal for sideloaded or cloned apps that don’t receive native update notifications.

✨ Features
	
•	⏱ Checks for updates every 6 hours
	
•	📲 Works with all App Store apps (even sideloaded ones)
	
•	🇦🇺 Optimized for Australian App Store region (changeable)
	
•	🔒 Encrypted link delivery for update downloads (future support)

CREDIT ZXCVBN

	•	🛠 Supports injection into:
	•	IPA files (via insert_dylib)
	•	.dylib tweaks using MobileSubstrate
	•	.deb packages for jailbroken environments
	•	🧊 UI styled like iOS 26 “Liquid Glass” notification pill
	•	🎯 Filter system to skip system apps or monitor only specific vendors
	•	📦 Optional: Save app metadata locally or to iCloud