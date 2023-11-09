#!/bin/bash
cp *.sh git/macfirewallah/filesystem/Users/someuser/
cp *.conf git/macfirewallah/filesystem/Users/someuser/
cp hosts.* git/macfirewallah/filesystem/Users/someuser/
rm -rf git/macfirewallah/filesystem/Users/someuser/git/py_browser_history
cp -r git/py_browser_history git/macfirewallah/filesystem/Users/someuser/git/
cp git/README.txt git/macfirewallah/filesystem/Users/someuser/git
cp /Library/LaunchDaemons/*.simple.*.plist git/macfirewallah/filesystem/Library/LaunchDaemons
