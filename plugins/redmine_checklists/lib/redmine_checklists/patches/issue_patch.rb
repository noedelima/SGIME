# This file is a part of Redmine Checklists (redmine_checklists) plugin,
# issue checklists management plugin for Redmine
#
# Copyright (C) 2011-2025 RedmineUP
# http://www.redmineup.com/
#
# redmine_checklists is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# redmine_checklists is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with redmine_checklists.  If not, see <http://www.gnu.org/licenses/>.

require_dependency 'issue'

module RedmineChecklists
  module Patches
    module IssuePatch
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
        base.class_eval do
          attr_accessor :old_checklists, :removed_checklist_ids, :checklists_from_params
          attr_reader :copied_from

          alias_method :after_create_from_copy_without_checklists, :after_create_from_copy
          alias_method :after_create_from_copy, :after_create_from_copy_with_checklists

          has_many :checklists, lambda { order("#{Checklist.table_name}.position") }, :class_name => 'Checklist', :dependent => :destroy, :inverse_of => :issue

          accepts_nested_attributes_for :checklists, :allow_destroy => true, :reject_if => proc { |attrs| attrs['subject'].blank? }

          validate :block_issue_closing_if_checklists_unclosed

          safe_attributes 'checklists_attributes',
            :if => lambda { |issue, user| (user.allowed_to?(:done_checklists, issue.project) || user.allowed_to?(:edit_checklists, issue.project)) }
        end
      end

      module InstanceMethods
        def copy_checklists
          checklists_attributes = copied_from.checklists.map { |checklist| checklist.attributes.dup.except('id', 'issue_id').merge('issue_id' => id) }
          checklists.create(checklists_attributes)
        end

        def after_create_from_copy_with_checklists
          after_create_from_copy_without_checklists
          copy_checklists if copy? && checklists.blank? && copied_from.checklists.present? && !checklists_from_params
        end

        def all_checklist_items_is_done?
          (checklists - checklists.where(id: removed_checklist_ids)).reject(&:is_section).all?(&:is_done)
        end

        def need_to_block_issue_closing?
          RedmineChecklists.block_issue_closing? &&
            checklists.reject(&:is_section).any? &&
            status.is_closed? &&
            !all_checklist_items_is_done?
        end

        def block_issue_closing_if_checklists_unclosed
          if need_to_block_issue_closing?
            errors.add(:checklists, l(:label_checklists_must_be_completed))
          end
        end
      end
    end
  end
end

unless Issue.included_modules.include?(RedmineChecklists::Patches::IssuePatch)
  Issue.send(:include, RedmineChecklists::Patches::IssuePatch)
end
