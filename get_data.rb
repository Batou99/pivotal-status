require 'pivotal_tracker'
require 'pry'
require 'erb'
require 'tilt'

PivotalTracker::Client.token(ARGV[0], ARGV[1])

project = PivotalTracker::Project.find(518421)
current = PivotalTracker::Iteration.current(project)

# Accepted
#
accepted_stories = current.stories.select { |s| s.accepted_at!=nil }

features = accepted_stories.select { |s| s.story_type == 'feature' }
bugs = accepted_stories.select { |s| s.story_type == 'bug' }
chores = accepted_stories.select { |s| s.story_type == 'chore' }

total_points = accepted_stories.map(&:estimate).reduce(:+)
feature_points = features.map(&:estimate).reduce(:+)
bug_points = bugs.map(&:estimate).reduce(:+)
chore_points = chores.map(&:estimate).reduce(:+)

template = Tilt.new('mail.erb')
data = {
  afeatures: features,
  abugs: bugs,
  achores: chores,
  atotal_points: total_points.to_i,
  afeature_points: feature_points.to_i,
  abug_points: bug_points.to_i,
  achore_points: chore_points.to_i
}
finished_stories = current.stories.select { |s| s.current_state=='delivered' } #&& s.accepted_at == nil && ['feature','bug','chore'].include?(s.story_type)}

features = finished_stories.select { |s| s.story_type == 'feature' }
bugs = finished_stories.select { |s| s.story_type == 'bug' }
chores = finished_stories.select { |s| s.story_type == 'chore' }

total_points = finished_stories.map(&:estimate).reduce(:+) rescue 0
feature_points = features.map(&:estimate).reduce(:+)
bug_points = bugs.map(&:estimate).reduce(:+)
chore_points = chores.map(&:estimate).reduce(:+)

data = data.merge({
  dfeatures: features,
  dbugs: bugs,
  dchores: chores,
  dtotal_points: total_points.to_i,
  dfeature_points: feature_points.to_i,
  dbug_points: bug_points.to_i,
  dchore_points: chore_points.to_i
})

puts template.render(locals = data )
