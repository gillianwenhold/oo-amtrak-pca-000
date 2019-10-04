class VendingMachine
  attr_reader :stationed_at
  attr_accessor :route, :tickets

  def initialize(path, location)
    @route = self.load_json_file(path)
    @tickets = []
    @stationed_at = location
  end

  def load_json_file(path)
    file = File.read(path)
    JSON.parse(file)
  end

  def purchase_tickets(destination, num_tickets, purchaser_name)
    start = @route.index{ |r| r["station name"] == @stationed_at }
    finish = @route.index{ |r| r["station name"] == destination }
    if available?(start, finish, destination, num_tickets)
      decrease_available(start, finish, num_tickets, purchaser_name, destination)
      for i in 1...(num_tickets + 1)
        ticket = Ticket.new(@stationed_at, destination, purchaser_name)
        @tickets << ticket
      end
      "Transaction completed, thank you for choosing Amtrak."
    else
      "Tickets can't be purchased because there are not enough seats. We aplogize for the inconvenience."
    end

  end

private
  def available?(start, finish, destination, num_tickets)
    available = true
    puts "Traveling from " + @stationed_at + " to " + destination
    if finish > start
      @route[start, finish].each do |r|
        break if r["station name"] == destination
        available = false if r["remaining seats"] < num_tickets
      end
    else
      @route[(finish + 1), start].each do |r|
        available = false if r["remaining seats"] < num_tickets
        break if r["station name"] == @stationed_at
      end
    end
    available
  end

  def decrease_available(start, finish, num_tickets, purchaser_name, destination)
    if finish > start
      @route[start, finish].each do |r|
        r["remaining seats"] -= num_tickets
        break if r["station name"] == destination
      end
    else
      @route[finish, start].each do |r|
        r["remaining seats"] -= num_tickets
        break if r["station name"] == @stationed_at
      end
    end
  end
end
