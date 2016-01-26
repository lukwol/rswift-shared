require 'rake'
require 'rswift'

desc 'Clean build objects'
task :clean do
  FileUtils.rm_rf('~/Library/Developer/Xcode/DerivedData', verbose: true)
  FileUtils.rm_rf('build', verbose: true)

  caches_directory = File.join(Dir.home, 'Library', 'Caches')
  appcode_directory = Dir.glob("#{caches_directory}/AppCode*/").first
  if appcode_directory
    appcode_derived_data_directory = File.join(appcode_directory, 'DerivedData')
    FileUtils.rm_rf(appcode_derived_data_directory, verbose: true)
  end

  workspace = RSwift::WorkspaceProvider.workspace
  project_path = Dir.glob('*.xcodeproj').first
  project = Xcodeproj::Project.open(project_path)
  project.build_configurations.each do |build_configuration|
    system "xcodebuild clean -workspace #{workspace} -scheme #{project.app_scheme_name} -configuration #{build_configuration.name} | xcpretty"
  end
end

namespace :pod do

  desc 'Clean cocoapods'
  task :clean do
    workspace = RSwift::WorkspaceProvider.workspace
    FileUtils.rm_rf(workspace, verbose: true)
    FileUtils.rm_rf('Pods/', verbose: true)
    FileUtils.rm_rf('~/.cocoapods/repos/', verbose: true)
    system 'pod cache clean --all'
  end
end

namespace :simulator do

  desc 'Clean all simulators'
  task :clean do
    system 'killall Simulator'
    system 'xcrun simctl erase all'
  end
end

namespace :update do

  desc 'Renew file references'
  task :references do
    project_path = Dir.glob('*.xcodeproj').first
    project = Xcodeproj::Project.open(project_path)
    files_references_manager = RSwift::FilesReferencesManager.new
    project.targets.each do |target|
      group_name = RSwift::Constants::TARGET_PROPERTIES[target.product_type_uti][:group_name]
      group = project.main_group[group_name]
      files_references_manager.update_target_references(group, target)
    end

    project.save
  end
end
