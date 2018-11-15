require_relative './concerns/slugifiable'

class Entry < ActiveRecord::Base
  belongs_to :applicant
end
