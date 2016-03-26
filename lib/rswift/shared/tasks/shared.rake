require 'rake'
require 'rswift'

workspace = RSwift::WorkspaceProvider.workspace
project = Xcodeproj::Project.open(Dir.glob('*.xcodeproj').first)

desc 'Clean build objects'
task :clean do
  FileUtils.rm_rf('build', verbose: true)
  project.build_configurations.each do |build_configuration|
    system "xcodebuild clean -workspace #{workspace} -scheme #{project.app_scheme_name} -configuration #{build_configuration.name} | xcpretty"
  end
end

namespace :pod do

  desc 'Clean cocoapods'
  task :clean do
    FileUtils.rm_rf(workspace, verbose: true)
    FileUtils.rm_rf('Pods/', verbose: true)
    FileUtils.rm_rf('~/.cocoapods/repos/', verbose: true)
    system 'pod cache clean --all'
  end
end

namespace :update do

  desc 'Renew file references'
  task :references do
    files_references_manager = RSwift::FilesReferencesManager.new
    project.targets.each do |target|
      group_name = RSwift::Constants::TARGET_PROPERTIES[target.product_type_uti][:group_name]
      group = project.main_group[group_name]
      files_references_manager.update_target_references(group, target)
    end

    project.save
  end
end
