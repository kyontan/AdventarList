class Application < ActiveRecord::Base
	has_and_belongs_to_many :programs
	belongs_to :elected_program, class_name: "Program"
end

class Program < ActiveRecord::Base
	has_and_belongs_to_many :applications
	has_many :elected_applications, class_name: "Application", foreign_key: "elected_program_id"
end

class ApplicationProgram < ActiveRecord::Base

end