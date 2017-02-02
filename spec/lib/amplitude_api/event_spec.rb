require 'spec_helper'

describe AmplitudeAPI::Event do
  user = Struct.new(:id)

  context 'with a user object' do
    describe '#body' do
      it "populates with the user's id" do
        event = described_class.new(
          user_id: user.new(123),
          event_type: 'clicked on home'
        )
        expect(event.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context 'with a user id' do
    describe '#body' do
      it "populates with the user's id" do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash[:user_id]).to eq(123)
      end
    end
  end

  context 'without a user' do
    describe '#body' do
      it 'populates with the unknown user' do
        event = described_class.new(
          user_id: nil,
          event_type: 'clicked on home'
        )
        expect(event.to_hash[:user_id]).to eq(AmplitudeAPI::USER_WITH_NO_ACCOUNT)
      end
    end
  end

  describe 'init' do
    context 'attributes' do
      it 'accepts string attributes' do
        time = Time.parse('2016-01-01 00:00:00 -0000')
        event = described_class.new(
          'user_id' => 123,
          'device_id' => 'abcd',
          'event_type' => 'sausage',
          'event_properties' => { 'a' => 'b' },
          'user_properties' => { 'c' => 'd' },
          'time' => time,
          'ip' => '127.0.0.1',
          'insert_id' => 'bestId',
          'session_id' => 1_396_381_378_123
        )

        expect(event.to_hash).to eq(event_type: 'sausage',
                                    user_id: 123,
                                    device_id: 'abcd',
                                    event_properties: { 'a' => 'b' },
                                    user_properties: { 'c' => 'd' },
                                    time: 1_451_606_400_000,
                                    ip: '127.0.0.1',
                                    insert_id: 'bestId',
                                    session_id: 1_396_381_378_123)
      end

      it 'accepts symbol attributes' do
        time = Time.parse('2016-01-01 00:00:00 -0000')
        event = described_class.new(
          user_id: 123,
          device_id: 'abcd',
          event_type: 'sausage',
          event_properties: { 'a' => 'b' },
          user_properties: { 'c' => 'd' },
          time: time,
          ip: '127.0.0.1',
          insert_id: 'bestId',
          session_id: 1_396_381_378_123
        )

        expect(event.to_hash).to eq(event_type: 'sausage',
                                    user_id: 123,
                                    device_id: 'abcd',
                                    event_properties: { 'a' => 'b' },
                                    user_properties: { 'c' => 'd' },
                                    time: 1_451_606_400_000,
                                    ip: '127.0.0.1',
                                    insert_id: 'bestId',
                                    session_id: 1_396_381_378_123)
      end
    end

    context 'the user does not send in a price' do
      it 'raises an error if the user sends in a product_id' do
        expect do
          described_class.new(
            user_id: 123,
            event_type: 'bad event',
            product_id: 'hopscotch.4lyfe'
          )
        end.to raise_error(ArgumentError)
      end

      it 'raises an error if the user sends in a revenue_type' do
        expect do
          described_class.new(
            user_id: 123,
            event_type: 'bad event',
            revenue_type: 'tax return'
          )
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe '#to_hash' do
    it 'includes the event type' do
      event = described_class.new(
        user_id: 123,
        event_type: 'clicked on home'
      )
      expect(event.to_hash[:event_type]).to eq('clicked on home')
    end

    it 'includes arbitrary properties' do
      event = described_class.new(
        user_id: 123,
        event_type: 'clicked on home',
        event_properties: { abc: :def }
      )
      expect(event.to_hash[:event_properties]).to eq(abc: :def)
    end

    describe 'time' do
      it 'includes a time for the event' do
        time = Time.parse('2016-01-01 00:00:00 -0000')
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          time: time
        )
        expect(event.to_hash[:time]).to eq(1_451_606_400_000)
      end

      it 'does not drop milliseconds' do
        time = Time.parse('2016-01-01 00:00:00.001 -0000')
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          time: time
        )
        expect(event.to_hash[:time]).to eq(1_451_606_400_001)
      end

      it 'does not include time if it is not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:time)
      end
    end

    describe 'insert_id' do
      it 'includes an insert_id for the event' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          insert_id: 'foo-bar'
        )
        expect(event.to_hash[:insert_id]).to eq('foo-bar')
      end

      it 'does not include insert_id if it is not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:insert_id)
      end
    end

    describe 'session_id' do
      it 'includes a session_id for the event' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          session_id: 1_396_381_378_123
        )
        expect(event.to_hash[:session_id]).to eq(1_396_381_378_123)
      end

      it 'accepts time as session_id' do
        session_id_time = Time.parse('2014-04-01 19:42:58.123 UTC')
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          session_id: session_id_time
        )
        expect(event.to_hash[:session_id]).to eq(1_396_381_378_123)
      end

      it 'does not include session_id if it is not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:session_id)
      end
    end

    describe 'revenue params' do
      it 'includes the price if it is set' do
        price = 100_000.99
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: price
        )
        expect(event.to_hash[:price]).to eq(price)
      end

      it 'sets the quantity to 1 if the price is set and the quantity is not' do
        price = 100_000.99
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: price
        )
        expect(event.to_hash[:quantity]).to eq(1)
      end

      it 'includes the quantity if it is set' do
        quantity = 100
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          quantity: quantity,
          price: 10.99
        )
        expect(event.to_hash[:quantity]).to eq(quantity)
      end

      it 'includes the productID if set' do
        product_id = 'hopscotch.subscriptions.rule'
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: 199.99,
          product_id: product_id
        )
        expect(event.to_hash[:productId]).to eq(product_id)
      end

      it 'includes the revenueType if set' do
        revenue_type = 'income'
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',
          price: 199.99,
          revenue_type: revenue_type
        )
        expect(event.to_hash[:revenueType]).to eq(revenue_type)
      end

      it 'does not include revenue params if they are not set' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home'
        )
        expect(event.to_hash).not_to have_key(:quantity)
        expect(event.to_hash).not_to have_key(:revenueType)
        expect(event.to_hash).not_to have_key(:productId)
        expect(event.to_hash).not_to have_key(:price)
      end
    end

    describe 'device info params' do
      it 'includes all device-related params' do
        event = described_class.new(
          user_id: 123,
          event_type: 'clicked on home',

          app_version: '1.70',
          platform: 'Android',
          os_name: 'Android',
          os_version: '7.1.1',

          device_manufacturer: 'Xiaomi',
          device_model: 'MI 5',
          carrier: nil
        )

        expect(event.to_hash).to have_key(:app_version)
        expect(event.to_hash).to have_key(:platform)
        expect(event.to_hash).to have_key(:os_name)
        expect(event.to_hash).not_to have_key(:device_brand)
        expect(event.to_hash).to have_key(:device_manufacturer)
        expect(event.to_hash).to have_key(:device_model)
        expect(event.to_hash).not_to have_key(:device_type)
        expect(event.to_hash).not_to have_key(:carrier)
      end
    end
  end
end
