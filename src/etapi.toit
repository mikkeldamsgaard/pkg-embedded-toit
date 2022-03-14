import monitor

TYPE_QUIT_ ::= 100
TYPE_STATUS_ ::= 101

TYPE_STREAM_START_ ::= 200


interface StreamReceiver:
  on_message stream_id/int message/ByteArray


class Stream implements SystemMessageHandler_:
  stream_id_ /int
  receiver_ /StreamReceiver
  
  constructor .stream_id_ .receiver_:
     set_system_message_handler_ TYPE_STREAM_START_ + stream_id_ this
  
  send message/ByteArray:
    try:
      process_send_ 0 TYPE_STREAM_START_ + stream_id_ message
      return null
    finally: |is_exception e|
      if is_exception: 
        print "Send failed: $e.value"
        return e.value

  on_message type gid pid message -> none:
    assert: type == TYPE_STREAM_START_ + stream_id_
    receiver_.on_message stream_id_ message


class  EmbeddedApi implements SystemMessageHandler_:
  latch_ ::= monitor.Latch

  construtor:
     set_system_message_handler_ TYPE_QUIT_ this
     set_system_message_handler_ TYPE_STATUS_ this
     5.repeat:
        set_system_message_handler_ TYPE_STREAM_START_ + it this

  on_message type gid pid message -> none:
    assert: type == TYPE_QUIT_ or type == TYPE_STATUS_

    if type == TYPE_QUIT_:
      latch_.set null
      return

    // TODO(mikkel): Add status ?

  run:
    latch_.get
    