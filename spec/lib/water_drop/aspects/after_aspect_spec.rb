require 'spec_helper'

RSpec.describe WaterDrop::Aspects::AfterAspect do
  specify { expect(described_class).to be < WaterDrop::Aspects::BaseAspect }

  describe 'aspect hook' do
    let(:delegate) { double }
    let(:formatter) { double }
    let(:klass) do
      ClassBuilder.build do
        attr_accessor :instance_variable
        def run(*_args)
          @instance_variable = 5
        end

        def call(*_args)
          @instance_variable = 5
          5780
        end
      end
    end

    before do
      @instance = klass.new
      expect(WaterDrop::Aspects::Formatter).to receive(:new)
        .with(options, ['arg'], nil)
        .and_return(formatter)

      allow(formatter).to receive(:message) { 'msg' }

      expect(WaterDrop::Event)
        .to receive(:new).with(options[:topic], formatter.message).and_return(delegate)
      expect(delegate).to receive(:send!)
    end

    context 'message without parameter' do
      let(:message) do
        proc do
          @instance_variable ||= 98
          puts @instance_variable.inspect
        end
      end
      let(:options) { { method: :run, topic: 'topic', message: message } }

      it 'hooks to a given klass' do
        described_class.apply(klass, method: :run,
                                     topic: 'topic',
                                     message: message)
        expect(@instance).to receive(:puts).with('5')
        @instance.run('arg')
      end
    end

    context 'message with parameter' do
      let(:message_with_parameter) do
        ->(result) { puts result.inspect }
      end
      let(:options) { { method: :call, topic: 'topic4', message: message_with_parameter } }

      it 'hooks to given klass and get result of function execution' do
        described_class.apply(klass, method: :call,
                                     topic: 'topic4',
                                     message: message_with_parameter)
        expect(message_with_parameter).to receive(:call).with(5780)
        @instance.call('arg')
      end
    end
  end
end
