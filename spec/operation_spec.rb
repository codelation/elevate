describe Elevate::ElevateOperation do
  before do
    @target = lambda { 42 }
    @operation = Elevate::ElevateOperation.alloc.initWithTarget(@target, args: {}, channel: [])
    @queue = NSOperationQueue.alloc.init
  end

  after do
    @queue.waitUntilAllOperationsAreFinished
  end

  describe "#exception" do
    describe "when no exception is raised" do
      it "returns nil" do
        @queue.addOperation(@operation)
        @operation.waitUntilFinished

        @operation.exception.should.be.nil
      end
    end

    describe "when an exception is raised" do
      it "returns the exception" do
        @target = lambda { raise IndexError }
        @operation = Elevate::ElevateOperation.alloc.initWithTarget(@target, args: {}, channel: nil)

        @queue.addOperation(@operation)
        @operation.waitUntilFinished

        @operation.exception.should.not.be.nil
      end
    end
  end

  describe "#result" do
    before do
      @target = lambda { 42 }
      @operation = Elevate::ElevateOperation.alloc.initWithTarget(@target, args: {}, channel: nil)
    end

    describe "before starting the operation" do
      it "returns nil" do
        @operation.result.should.be.nil
      end
    end

    describe "when the operation has been cancelled" do
      it "returns nil" do
        @operation.cancel

        @queue.addOperation(@operation)
        @operation.waitUntilFinished

        @operation.result.should.be.nil
      end
    end

    describe "when the operation has finished" do
      it "returns the result of the lambda" do
        @queue.addOperation(@operation)
        @operation.waitUntilFinished

        @operation.result.should == 42
      end
    end
  end
end
