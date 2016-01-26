require 'spec_helper'

describe RSwift::Shared do

  describe 'clean task' do

    before do
      @clean_task = Rake::Task[:clean]
    end

    describe 'execute' do

      before do
        @captured_commands = []
        allow_any_instance_of(Kernel).to receive(:system) { |_, command| @captured_commands << command }
        allow(Dir).to receive(:home).and_return('fixture_home_directory')
        allow(Dir).to receive(:glob).with('*.xcodeproj').and_return(['fixture.xcodeproj'])
        allow(Dir).to receive(:glob).with('fixture_home_directory/Library/Caches/AppCode*/').and_return(['fixture_appcode_directory'])
        fixture_build_configurations = [spy(name: 'fixtureDebugBuildConfiguration'), spy(name: 'fixtureReleaseBuildConfiguration')]
        @spy_project = spy(app_scheme_name: 'fixtureAppScheme', build_configurations: fixture_build_configurations)
        allow(Xcodeproj::Project).to receive(:open).with('fixture.xcodeproj').and_return(@spy_project)
        allow(FileUtils).to receive(:rm_rf)
        allow(RSwift::WorkspaceProvider).to receive(:workspace).and_return('fixture.xcworkspace')
        @clean_task.execute
      end

      it 'should remove derived data directory' do
        expect(FileUtils).to have_received(:rm_rf).with('~/Library/Developer/Xcode/DerivedData', verbose: true)
      end

      it 'should remove build directory' do
        expect(FileUtils).to have_received(:rm_rf).with('build', verbose: true)
      end

      it 'should remove appcode derived data directory' do
        expect(FileUtils).to have_received(:rm_rf).with('fixture_appcode_directory/DerivedData', verbose: true)
      end

      describe 'executed commands' do

        it 'should execute 2 commands' do
          expect(@captured_commands.count).to eq(2)
        end

        describe 'first executed command' do

          before do
            @captured_command = @captured_commands[0]
          end

          it 'should clean workspace with debug build configuration' do
            expect(@captured_command).to eq('xcodebuild clean -workspace fixture.xcworkspace -scheme fixtureAppScheme -configuration fixtureDebugBuildConfiguration | xcpretty')
          end
        end

        describe 'second executed command' do

          before do
            @captured_command = @captured_commands[1]
          end

          it 'should clean workspace with release build configuration' do
            expect(@captured_command).to eq('xcodebuild clean -workspace fixture.xcworkspace -scheme fixtureAppScheme -configuration fixtureReleaseBuildConfiguration | xcpretty')
          end
        end
      end
    end
  end

  describe 'pod namespace' do

    describe 'clean task' do

      before do
        @pod_clean_task = Rake::Task['pod:clean']
      end

      describe 'execute' do

        before do
          allow(FileUtils).to receive(:rm_rf)
          allow_any_instance_of(Kernel).to receive(:system) { |_, command| @captured_command = command }
          allow(RSwift::WorkspaceProvider).to receive(:workspace).and_return('fixture.xcworkspace')
          @pod_clean_task.execute
        end

        it 'should delete workspace' do
          expect(FileUtils).to have_received(:rm_rf).with('fixture.xcworkspace', verbose: true)
        end

        it 'should delete pods directory' do
          expect(FileUtils).to have_received(:rm_rf).with('Pods/', verbose: true)
        end

        it 'should delete cocoapods repos' do
          expect(FileUtils).to have_received(:rm_rf).with('~/.cocoapods/repos/', verbose: true)
        end

        it 'should delete workspace' do
          expect(FileUtils).to have_received(:rm_rf).with('fixture.xcworkspace', verbose: true)
        end

        it 'should clean cocoapods cache' do
          expect(@captured_command).to eq('pod cache clean --all')
        end
      end
    end
  end

  describe 'simulator namespace' do

    describe 'clean task' do

      before do
        @simulator_clean_task = Rake::Task['simulator:clean']
      end

      describe 'execute' do

        before do
          @captured_commands = []
          allow_any_instance_of(Kernel).to receive(:system) { |_, command| @captured_commands << command }
          @simulator_clean_task.execute
        end

        describe 'executed commands' do

          it 'should execute 2 commands' do
            expect(@captured_commands.count).to eq(2)
          end

          describe 'first executed command' do

            before do
              @captured_command = @captured_commands[0]
            end

            it 'should kill Simulator' do
              expect(@captured_command).to eq('killall Simulator')
            end
          end

          describe 'second executed command' do

            before do
              @captured_command = @captured_commands[1]
            end

            it 'should erase all simulators' do
              expect(@captured_command).to eq('xcrun simctl erase all')
            end
          end
        end
      end
    end
  end
end
