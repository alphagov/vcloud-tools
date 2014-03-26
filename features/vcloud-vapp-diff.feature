Feature: "vcloud-vapp-diff" works as a useful command-line tool
  In order to use "vcloud-vapp-diff" from the CLI
  I want to have it behave like a typical Unix tool
  So I don't get surprised

  Scenario: Common arguments work
    When I get help for "vcloud-vapp-diff"
    Then the exit status should be 0
    And the banner should be present
    And the following options should be documented:
      |--version|
    And the banner should document that this app's arguments are:
      |vdc_name|vdc_config_dir|
