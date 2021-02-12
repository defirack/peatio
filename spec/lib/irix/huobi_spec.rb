# frozen_string_literal: true

describe Irix::Huobi do
  let(:upstream_huobi_config) do
    {
      "driver": 'huobi',
      "source": 'btcusdt',
      "target": 'btcusdt',
      "rest": 'https://api.huobi.pro/',
      "websocket": 'wss://api.huobi.pro/ws/'
    }.stringify_keys
  end

  let(:huobi) { Irix::Huobi.new(upstream_huobi_config) }

  let(:msg) { [{ 'id' => 10_546_668_650_576_828_480_136, 'ts' => 1_585_058_508_268, 'tradeId' => 102_103_734_360, 'amount' => 0.03817, 'price' => 6674.92, 'direction' => 'buy' }] }

  let(:trade) do
    {
      tid: 102_103_734_360,
      amount: 0.03817.to_d,
      price: 6674.92.to_d,
      date: 1_585_058_508_268 / 1000,
      taker_type: 'buy'
    }.stringify_keys
  end
  it do
    huobi.stubs(:notify_public_trade).returns(trade)
    huobi.detect_trade(msg)
  end

  context "OrderBook proxy" do
    let(:order_msg) { [[170.16, 28.67834216]] }

    it do
      huobi.snap = { 'asks' => [], 'bids' => [] }
      huobi.increment_count = 0
      huobi.snapshot_time = Time.now
      huobi.stubs(:fill_increment)
      huobi.detect_order(order_msg)
    end

    it do
      huobi.snap = { 'asks' => [], 'bids' => [] }
      huobi.increment_count = 101
      huobi.snapshot_time = Time.now - 60
      huobi.stubs(:publish_snapshot)
      huobi.stubs(:fill_increment)
      huobi.detect_order(order_msg)
    end

    context '#fill_side' do
      let(:inc) { {"prevSeqNum"=>100120546808, "seqNum"=>100120546809, "bids"=>[[1201.0, 1.0]], "asks"=>[[1203.0, 1.0]]} }

      it do
        huobi.asks = []
        huobi.bids = []
        huobi.snap = { 'asks' => [], 'bids' => [] }
        huobi.fill_side(inc, "asks")
        huobi.fill_side(inc, "bids")
        expect(huobi.asks).to eq([["1203.0", "1.0"]])
        expect(huobi.bids).to eq([["1201.0", "1.0"]])
      end
    end
  end
end
