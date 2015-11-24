module MyAcademics
  class GpaUnits
    extend Cache::Cacheable
    include AcademicsModule
    include ClassLogger
    include Cache::UserCacheExpiry

    def merge(data)
      gpa_units = self.class.fetch_from_cache(@uid) do
        student_info = CampusOracle::Queries.get_student_info(@uid) || {}
        {
          cumulativeGpa: student_info['cum_gpa'].nil? ? nil: student_info['cum_gpa'].to_s,
          totalUnits: student_info['tot_units'].nil? ? nil : student_info['tot_units'].to_f,
          totalUnitsAttempted: student_info['lgr_tot_attempt_unit'].nil? ? nil : student_info['lgr_tot_attempt_unit'].to_f
        }
      end
      data[:gpaUnits] = gpa_units
    end
  end
end
