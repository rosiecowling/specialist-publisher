#!/usr/bin/env groovy

library("govuk")

node {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-specialist-publisher")
  govuk.buildProject(
    rubyLintDiff: false,
    sassLint: false, 
    publishingE2ETests: true, 
    brakeman: true
  )
}
