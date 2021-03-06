module Oec
  class SisImportSheet < Worksheet

    attr_reader :dept_code

    def initialize(opts={})
      if (@dept_code = opts.delete :dept_code)
        opts[:export_name] = Berkeley::Departments.get(@dept_code, concise: true)
      end
      super(opts)
    end

    def headers
      %w(
        COURSE_ID
        COURSE_ID_2
        COURSE_NAME
        CROSS_LISTED_FLAG
        CROSS_LISTED_NAME
        DEPT_NAME
        CATALOG_ID
        INSTRUCTION_FORMAT
        SECTION_NUM
        PRIMARY_SECONDARY_CD
        LDAP_UID
        SIS_ID
        FIRST_NAME
        LAST_NAME
        EMAIL_ADDRESS
        EVALUATE
        DEPT_FORM
        EVALUATION_TYPE
        MODULAR_COURSE
        START_DATE
        END_DATE
      )
    end

  end
end
