# SynoSudoNoPasswd

This scripts enables you to define sets of users and commands for passwordless `sudo`. Comes in handy when you want to execute scripted commands via `ssh` like shutting down a Synology NAS after successful backup.

#### 1. Notes

- The script is able to automatically update itself using `git`.
- You pass the user and command sets in the following format `users:commands` (separate with commas if needed)

    Examples:
    - `./synoSudoNoPasswd.sh "bob:/usr/bin/rsync"`
    - `./synoSudoNoPasswd.sh "bob,tom,tim:/sbin/shutdown,/sbin/reboot"`
    - `./synoSudoNoPasswd.sh "bob:/usr/bin/rsync" "tom,bob:/sbin/shutdown,/sbin/reboot"`


#### 2. Installation

##### 2.1 Install Git (optional)

- install the package `Git Server` on your Synology NAS, make sure it is running (requires sometimes extra action in `Package Center` and `SSH` running)
- alternatively add SynoCommunity to `Package Center` and install the `Git` package ([https://synocommunity.com/](https://synocommunity.com/#easy-install))
- you can also use `entware` (<https://github.com/Entware/Entware>)

##### 2.2 Install this script (using git)

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- connect via `ssh` to the NAS and execute the following commands

```bash
# navigate to the shared folder
cd /volume1/sysadmin
# clone the following repo
git clone https://github.com/alexanderharm/syno-sudo-no-passwd
# to enable autoupdate
touch syno-sudo-no-passwd/autoupdate
```

##### 2.3 Install this script (manually)

- create a shared folder e. g. `sysadmin` (you want to restrict access to administrators and hide it in the network)
- copy your `synoSudoNoPasswd.sh ` to `sysadmin` using e. g. `File Station` or `scp`
- make the script executable by connecting via `ssh` to the NAS and executing the following command

```bash
chmod 755 /volume1/sysadmin/synoSudoNoPasswd.sh
```

#### 3. Setup

- run script manually

```bash
sudo /volume1/sysadmin/syno-sudo-no-passwd/synoSudoNoPasswd.sh  "userset 1:commandset 1" "userset 2: commandset 2"
```

*AND/OR*

- create a task in the `Task Scheduler` via WebGUI

```
# Type
Scheduled task > User-defined script

# General
Task:    SynoSudoNoPasswd
User:    root
Enabled: yes

# Schedule
Run on the following days: Daily
First run time:            00:00
Frequency:                 Every hour
Last run time:				23:00

# Task Settings
Send run details by email:      yes
Email:                          (enter the appropriate address)
Send run details only when
  script terminates abnormally: yes
  
User-defined script: /volume1/sysadmin/syno-sudo-no-passwd/synoSudoNoPasswd.sh  "userset 1:commandset 1" "userset 2: commandset 2"
```
