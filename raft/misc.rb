module Misc
  require 'thread'
  class Timer
    attr_accessor(:last_timestamp, :timeout_in_sec)
    @mutex = Mutex.new

    def initialize(timeout)
      @timeout_in_sec = timeout
      @last_timestamp = Time.now
      @mutex = Mutex.new
    end

    def set_timeout(timeout)
      self.timeout_in_sec = timeout
      self.last_timestamp = Time.now
    end


    def reset_timer
      #Avoid read timeout when resetting
      @mutex.synchronize {
        freeze = false
        self.last_timestamp = Time.now
      }
    end

    # # Freeze the timer. Call to timeout? will return false util reset_timer is called
    # # This is used when doing AppendEntries RPC. When there is a callback received from the Peer.
    # # Caller freeze the RPC timer for that Peer and will reset the timer when it's HeartbeatTimer timeout (Another round of AppendEntries)
    # def freeze
    #   freeze = true;
    # end

    def timeout?
      @mutex.synchronize {
        temp = Time.now
        if time_diff_in_sec(@last_timestamp, temp) > self.timeout_in_sec then
          @last_timestamp = temp
          true
        else
          false
        end
      }
    end

    def time_diff_in_sec(start, finish)
       finish - start
    end
  end

  def self.generate_uuid
    "#{rand}#{rand}#{rand}"
  end


  #Constants
  ELECTION_TIMEOUT = 3.freeze
  #For both AppendEntries RPC and Request Vote RPC. This is used by each Peer object for a Datacenter. In second
  RPC_TIMEOUT = 2.freeze
  #For calculating when to send an AppendEntries request to peers. This is used by Datacenter object. Only Leader need this. In mill
  HEARTBEAT_TIMEOUT = 2.freeze
  #The interval for each state main loop
  STATE_LOOP_INTERVAL = 1.freeze
  #AppendEntries Exchange name
  APPEND_ENTRIES_DIRECT_EXCHANGE = 'AppendEntriesDirect'.freeze
  #VoteRequest Exchange name
  REQUEST_VOTE_DIRECT_EXCHANGE = 'RequestVoteDirect'.freeze

  #For state
  RUNNING_STATE = 'Running'
  KILLED_STATE = 'Killed'

  #For log entry
  PREPARE = 'Prepare'
  COMMITTED = 'Committed'
end