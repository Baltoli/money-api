class Transaction
  def initialize(from, to, amount, comment)
    @from = from
    @to = to
    @amount = amount
    @comment = comment
  end

  attr_reader :from, :to, :amount, :comment
end

class Record
  def initialize(file_name)
    File.open(file_name, "r") do |file|
      names = file.gets.strip.split(" ")
      @entries = Hash[names.map { |name| [name, {}] }]
      @transactions = []

      file.each do |line|
        entry = line.strip.split(":")
        unless [3, 4].include?(entry.size)
          STDERR.puts "Ignoring invalid line: #{line}"
          next
        end

        add_entry(*entry)
        add_transaction(*entry)
      end
    end
  end
  attr_reader :transactions

  def people
    @entries.keys
  end

  def write
  end

  def active_debts
    []
  end

  def add_entry(from, to, amount, comment=nil)
    previous_from = @entries[from][to]
    previous_to = @entries[to][from]
    amount = amount.to_i
    
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
        @entries[to][from] -= net
      else
        @entries[to].delete(from)
      end
    elsif previous_to.nil?
      @entries[from][to] += amount
    else
      STDERR.puts("Invalid ledger state!")
    end
  end

  def add_transaction(from, to, amount, comment=nil)
    @transactions << Transaction.new(from, to, amount, comment)
  end
end
