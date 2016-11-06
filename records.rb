class Transaction
  def initialize(from, to, amount, comment)
    @from = from
    @to = to
    @amount = amount
    @comment = comment
  end

  def to_json(*a)
    h = {
      from: from,
      to: to,
      amount: amount
    }
    h[:comment] = comment unless comment.nil?
    h.to_json(*a)
  end

  attr_reader :from, :to, :amount, :comment
end

class Record
  def initialize(file_name)
    @file_name = file_name
    @new_transactions = []

    File.open(@file_name, "r") do |file|
      names = file.gets.strip.split(" ")
      @entries = Hash[names.map { |name| [name, {}] }]
      @transactions = []

      file.each do |line|
        entry = line.strip.split(":")
        unless [3, 4].include?(entry.size)
          STDERR.puts "Ignoring invalid line: #{line}"
          next
        end

        add_transaction(*entry)
      end
    end

    @new_transactions = []
  end
  attr_reader :transactions

  def people
    @entries.keys
  end

  def write!
    File.open(@file_name, "a") do |file|
      @new_transactions.each do |t|
        file.write("#{t.from}:#{t.to}:#{t.amount}")
        file.write(":#{t.comment}") unless t.comment.nil?
        file.write("\n")
      end
    end

    @new_transactions = []
  end

  def active_entries
    @entries.select { |_, v| v != {} }
  end

  def add_transaction(from, to, amount, comment=nil)
    amount = amount.to_i

    if amount < 0
      from, to = to, from
      amount = 0 - amount
    end

    unless valid_transfer?(from, to, amount)
      STDERR.puts("Invalid transfer!")
      return nil
    end

    add_entry(from, to, amount)

    t = Transaction.new(from, to, amount, comment)
    @transactions << t
    @new_transactions << t
    t
  end

  private

  def add_entry(from, to, amount)
    previous_from = @entries[from][to]
    previous_to = @entries[to][from]
    
    if previous_from.nil? && previous_to.nil?
      # Neither owes the other any money at all
      @entries[from][to] = amount
    elsif previous_from.nil?
      # To owed From some money previously - take the new debt of From to To and
      # subtract it from the current debt. If the new value is -ve, then From
      # owes To some money now
      net = previous_to - amount
      if net < 0
        @entries[from][to] = 0 - net
        @entries[to].delete(from)
      elsif net > 0
        @entries[to][from] = net
      else
        @entries[to].delete(from)
      end
    elsif previous_to.nil?
      @entries[from][to] += amount
    else
      STDERR.puts("Invalid ledger state!")
    end
  end

  def valid_transfer?(from, to, amount)
    @entries.keys.include?(from) && 
      @entries.keys.include?(to) && 
      amount.is_a?(Integer) &&
      from != to
  end
end
