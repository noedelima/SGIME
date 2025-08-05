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

requires_redmineup version_or_higher: '1.0.10' rescue raise "\n\033[31mRedmine requires newer redmineup gem version.\nPlease update with 'bundle update redmineup'.\033[0m"

CHECKLISTS_VERSION_NUMBER = '3.1.27'.freeze
CHECKLISTS_VERSION_TYPE = "Light version"

Redmine::Plugin.register :redmine_checklists do
  name "Redmine Checklists plugin (#{CHECKLISTS_VERSION_TYPE})"
  author 'RedmineUP'
  description 'This is a issue checklist plugin for Redmine'
  version CHECKLISTS_VERSION_NUMBER
  url 'https://www.redmineup.com/pages/plugins/checklists'
  author_url 'mailto:support@redmineup.com'

  requires_redmine version_or_higher: '4.0'

  settings default: {
    save_log: true,
    issue_done_ratio: false
  }, partial: 'settings/checklists/checklists'

  Redmine::AccessControl.map do |map|
    map.project_module :issue_tracking do |map|
      map.permission :view_checklists, { checklists: [:show, :index] }
      map.permission :done_checklists, { checklists: :done }
      map.permission :edit_checklists, { checklists: [:done, :create, :destroy, :update] }
    end
  end
end

if (Rails.configuration.respond_to?(:autoloader) && Rails.configuration.autoloader == :zeitwerk) || Rails.version > '7.0'
  Rails.autoloaders.each { |loader| loader.ignore(File.dirname(__FILE__) + '/lib') }
end
require File.dirname(__FILE__) + '/lib/redmine_checklists'
require 'redmineup/patches/compatibility_patch'
