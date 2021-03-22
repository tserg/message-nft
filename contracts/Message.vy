# @version ^0.2.0

event MessageCreated:
  sender: indexed(address)
  message: String[100]

messages: HashMap[address, String[100]]

@external
def __init__():
  self.messages[msg.sender] = "Hello World!"

@external
def createMessage(_message: String[100]):
  self.messages[msg.sender] = _message
  log MessageCreated(msg.sender, _message)

@view
@external
def viewMessage(_from: address) -> String[100]:
  return self.messages[_from]
