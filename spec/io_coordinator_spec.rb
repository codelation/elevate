describe Elevate::IOCoordinator do
  before do
    @coordinator = Elevate::IOCoordinator.new
  end

  it "is not cancelled" do
    @coordinator.should.not.be.cancelled
  end

  describe "#install" do
    it "stores the coordinator in a thread-local variable" do
      @coordinator.install()

      Thread.current[:io_coordinator].should == @coordinator
    end
  end

  [:signal_blocked, :signal_unblocked].each do |method|
    describe method.to_s do
      describe "when IO has not been cancelled" do
        it "does not raise CancelledError" do
          lambda { @coordinator.send(method, 42) }.should.not.raise
        end
      end

      describe "when IO was cancelled" do
        it "raises CancelledError" do
          @coordinator.cancel()

          lambda { @coordinator.send(method, "hello") }.should.raise(Elevate::CancelledError)
        end
      end

      describe "when IO has timed out" do
        it "raises TimeoutError" do
          @coordinator.cancel(Elevate::TimeoutError)

          lambda { @coordinator.send(method, "hello") }.should.raise(Elevate::TimeoutError)
        end
      end
    end
  end

  describe "#uninstall" do
    it "removes the coordinator from a thread-local variable" do
      @coordinator.install()
      @coordinator.uninstall()

      Thread.current[:io_coordinator].should.be.nil
    end
  end
end
