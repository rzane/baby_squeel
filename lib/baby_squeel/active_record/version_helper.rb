require 'baby_squeel/dsl'

module BabySqueel
  module ActiveRecord
    class VersionHelper
      # Example
      #   BabySqueel::ActiveRecord::VersionHelper.at_least_7_1?
      #
      # def self.at_least_7_1?
      #   ::ActiveRecord::VERSION::MAJOR > 7 ||
      #     ::ActiveRecord::VERSION::MAJOR == 7 && ::ActiveRecord::VERSION::MINOR >= 1
      # end

      def self.at_least_7_2?
        ::ActiveRecord::VERSION::MAJOR == 7 && ::ActiveRecord::VERSION::MINOR >= 2
      end

    end
  end
end
