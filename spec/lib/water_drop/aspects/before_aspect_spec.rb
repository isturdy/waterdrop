require 'spec_helper'

RSpec.describe WaterDrop::Aspects::BeforeAspect do
  specify { expect(described_class).to be < WaterDrop::Aspects::BaseAspect }

  describe 'aspect hook' do
    let(:klass) do
      ClassBuilder.build do
        attr_accessor :instance_variable
        def run(*_args)
          @instance_variable = 5
        end
      end
    end

    let(:message) do
      proc do
        @instance_variable ||= 98
        puts @instance_variable.inspect
      end
    end
    let(:delegate) { double }
    let(:options) { { method: :run, topic: 'before_topic', message: message } }
    let(:formatter) { double }

    it 'hooks to a given klass' do
      described_class.apply(klass, method: :run,
                                   topic: 'before_topic',
                                   message: message)

      instance = klass.new
      expect(WaterDrop::Aspects::Formatter).to receive(:new).with(options, ['arg1'], nil)
        .and_return(formatter)

      allow(formatter).to receive(:message) { 'msg' }
      expect(WaterDrop::Event)
        .to receive(:new).with(options[:topic], formatter.message).and_return(delegate)
      expect(delegate).to receive(:send!)
      expect(instance).to receive(:puts).with('98')
      instance.run('arg1')
    end
  end
end
