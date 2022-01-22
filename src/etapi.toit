import monitor

TYPE_BASE_ ::= 100
TYPE_QUIT_ ::= TYPE_BASE
TYPE_STATUS_ ::= TYPE_QUIT + 1
TYPE_STREAM_START_ ::= TYPE_STATUS + 1


interface StreamReceiver:
  on_message stream_id/int message/ByteArray


class Stream implements SystemMessageHandler_:
  stream_id_ /int
  receiver_ /StreamReceiver
  
  constructor .stream_id_ .receiver_:
     set_system_message_handler_ TYPE_STREAM_START + stream_id_ this
  
  send message/ByteArray:
    process_send_ 0 TYPE_STREAM_START_ + stream_id_ message

  on_message type gid pid message -> none:
    assert: type == TYPE_STREAM_START_ + stream_id_
    receiver_.on_message stream_id_ message


class EmbeddedApi implements SystemMessageHandler_:
  latch_ ::= monitor.Latch

  construtor:
     set_system_message_handler_ TYPE_QUIT this
     set_system_message_handler_ TYPE_STATUS this
     5.repeat:
        set_system_message_handler_ TYPE_STREAM_START + it this

  on_message type gid pid message -> none:
    assert: type == TYPE_QUIT || type == TYPE_STATUS

    if type == TYPE_QUIT:
      latch_.set null
      return

    // TODO(mikkel): Add status ?

  run:
    latch_.get
    