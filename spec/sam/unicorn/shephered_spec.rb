# frozen_string_literal: true

RSpec.describe Sam::Unicorn::Shephered do
  let(:cmd) { TTY::Command.new(printer: :null) }
  let(:config) { Pathname.new(Dir.pwd).join('spec/fixtures/server_settings.rb') }

  subject(:shephered) { described_class.new }

  before(:each) { cmd.run! 'bundle exec sam unicorn start -c spec/fixtures/server_settings.rb' }
  after(:each) { cmd.run! 'bundle exec sam unicorn stop -c spec/fixtures/server_settings.rb' }

  context 'Signal handling' do
    it 'forwards SIGTTOU and SIGTTIN to the unicorn process'

    it 'when HUP is send, the process is reloaded' do
      monit = Process.fork { shephered.call(config, timeout: 3) }
      Process.detach(monit)
      expect { Process.kill('HUP', monit); sleep 5 }.to change { Sam::Unicorn::Identifier.new.call(config) }
    ensure
      Process.kill('KILL', monit)
    end
  end

  it 'exits in case the unicorn process dies' do
    thread = Thread.fork { shephered.call(config) }
    cmd.run 'bundle exec sam unicorn stop -c spec/fixtures/server_settings.rb'
    expect { thread.join }.to raise_error Sam::Unicorn::ProcessNotFound
  end
end