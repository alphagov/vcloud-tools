## 2.1.0 (2017-06-24)

  - Bring version number into line with the rest of the vCloud Tools estate
  - Make Ruby 2.2.2 the lowest possible version of Ruby to use as per the rest
    of the toolset.

## 1.0.0 (2014-05-19)

Features:

  - We no longer specify a version for the gems that this meta-gem installs;
    installing this gem should now install the most recent versions of its dependencies.
  - Include vCloud Tools Tester gem

## 0.8.0 (2014-04-23)

Features:

  - First release of vCloud Tools as a gem
  - vCloud Tools is now a meta-gem incorporating:
    - vCloud Core
    - vCloud Edge Gateway
    - vCloud Launcher
    - vCloud Net Launcher
    - vCloud Walker

## 0.7.0 (2014-01-07)

  - Storage profile can be provisioned using name only. Structure of yaml input has changed: d7a69e3
  - orgVdcNetwork can be provisioned using the tool
  - Integration test variable names have changed: 2f97634
  - Better error messages are raised when link is not found: 26a04f4
