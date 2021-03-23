export const MessageNFT_Abi = [
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "name": "sender",
        "type": "address"
      },
      {
        "indexed": false,
        "name": "message",
        "type": "string"
      }
    ],
    "name": "MessageCreated",
    "type": "event"
  },
  {
    "inputs": [],
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "constructor"
  },
  {
    "gas": 256561,
    "inputs": [
      {
        "name": "_message",
        "type": "string"
      }
    ],
    "name": "createMessage",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "gas": 9562,
    "inputs": [
      {
        "name": "_messageId",
        "type": "uint256"
      }
    ],
    "name": "viewMessage",
    "outputs": [
      {
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "gas": 1236,
    "inputs": [
      {
        "name": "_messageId",
        "type": "uint256"
      }
    ],
    "name": "viewMessageCreator",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "gas": 1151,
    "inputs": [],
    "name": "messageId",
    "outputs": [
      {
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "gas": 1296,
    "inputs": [
      {
        "name": "arg0",
        "type": "uint256"
      }
    ],
    "name": "messageCreators",
    "outputs": [
      {
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "gas": 9682,
    "inputs": [
      {
        "name": "arg0",
        "type": "uint256"
      }
    ],
    "name": "messages",
    "outputs": [
      {
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  }
]
