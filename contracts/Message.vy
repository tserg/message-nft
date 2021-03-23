# @version ^0.2.0

event MessageCreated:
  sender: indexed(address)
  message: String[100]

messageId: public(uint256)

messageCreators: public(HashMap[uint256, address])
messages: public(HashMap[uint256, String[100]])

@external
def __init__():
  self.messageId = 0

@external
def createMessage(_message: String[100]):
  self.messages[self.messageId] = _message
  self.messageCreators[self.messageId] = msg.sender
  self.messageId += 1
  log MessageCreated(msg.sender, _message)

@view
@external
def viewMessage(_messageId: uint256) -> String[100]:
  return self.messages[_messageId]

@view
@external
def viewMessageCreator(_messageId: uint256) -> address:
  return self.messageCreators[_messageId]
