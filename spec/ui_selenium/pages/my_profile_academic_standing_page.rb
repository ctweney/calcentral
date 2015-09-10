require 'selenium-webdriver'
require 'page-object'
require_relative 'cal_central_pages'
require_relative 'my_profile_page'
require_relative '../util/web_driver_utils'

module CalCentralPages
  class MyProfileAcademicStandingPage < MyProfilePage

    include PageObject
    include ClassLogger

    elements(:careers, :div, :xpath => '//div[@data-ng-repeat="career in academicStanding.careers"]')
    div(:gpa, :xpath => '//div[@data-ng-bind="academicStanding.gpa.average"]')
    elements(:plan, :div, :xpath => '//div[@data-ng-repeat="programPlan in academicStanding.programPlans"]')
    div(:standing, :xpath => '//div[@data-ng-bind="academicStanding.standing.description"]')
    div(:units, :xpath => '//div[@data-ng-bind="academicStanding.units.unitsTaken"]')
    div(:level, :xpath => '//div[@data-ng-bind="academicStanding.level.description"]')

    def plan_desc(index)
      plan_elements[index].div_element(:xpath => '//div[@data-ng-bind="programPlan.plan.description"]')
    end

    def plan_program_desc(index)
      plan_elements[index].div_element(:xpath => '//[@data-ng-bind="programPlan.academicProgram.program.description"]')
    end

  end
end
