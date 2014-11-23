class Arrival < ActiveRecord::Base
	extend SimpleCalendar
  	has_calendar :attribute => :date
	belongs_to :user
	belongs_to :building
	enum check_type: { check_in: 0, check_out: 1}
	enum begin_or_end: { begin: 0, end: 1}
end
