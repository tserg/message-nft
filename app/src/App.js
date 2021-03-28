import logo from './logo.svg';
import './App.css';

import { MessageNFT_Abi } from './abis';
import React, { useState } from 'react';
import Web3 from 'web3';

const web3 = new Web3(Web3.givenProvider);
const { REACT_APP_CONTRACT_ADDR } = process.env;
const MessageNFTContract = new web3.eth.Contract(MessageNFT_Abi, REACT_APP_CONTRACT_ADDR);

function App() {

  const [getCurrentWallet, setGetCurrentWallet] = useState('0x00');
  const [message, setMessage] = useState("");
  const [messageRecipient, setMessageRecipient] = useState("0x00");
  const [messageId, setViewMessage] = useState("0");
  const [getMessage, setGetMessage] = useState("");
  const [getMessageCreator, setGetMessageCreator] = useState('0x00');

  const handleGetCurrentWallet = async (e) => {
    e.preventDefault();
    const accounts = await window.ethereum.enable();
    const account = accounts[0];
    setGetCurrentWallet(account);
    console.log(account);
  }

  const handleCreateMessage = async (e) => {
    e.preventDefault();
    const accounts = await window.ethereum.enable();
    const account = accounts[0];
    console.log(message);
    console.log(messageRecipient);
    const result = await MessageNFTContract.methods.mint(messageRecipient, message).send({ from: account });
    console.log(result);
  }

  const handleRetrieveMessage = async (e) => {
    e.preventDefault();
    const accounts = await window.ethereum.enable();
    const account = accounts[0];
    const message = await MessageNFTContract.methods.viewMessage(messageId).call();
    const messageCreator = await MessageNFTContract.methods.viewMessageCreator(messageId).call();
    console.log(message);
    console.log(messageCreator);
    setGetMessage(message);
    setGetMessageCreator(messageCreator);
  }

  return (
    <div className="App">
      <header className="App-header">

        <button
          onClick={handleGetCurrentWallet}
          type="button" >
          Connect Wallet
        </button>
        <p>
          Current Wallet: &nbsp;
          { getCurrentWallet }
        </p>

        <form onSubmit={handleRetrieveMessage}>
          <p>
          <label>
            Message to retrieve: &nbsp;
            <input
              type="number"
              name="name"
              value={messageId}
              onChange={ e => setViewMessage(e.target.value) } />
          </label>
          <input type="submit" value="Retrieve" />
          </p>
        </form>
        <p>Message retrieved: &nbsp;
        { getMessage }
        </p>
        <p>From: &nbsp;
        { getMessageCreator }
        </p>

        <form onSubmit={handleCreateMessage}>
          <p>
          <label>
            Message to create: &nbsp;
            <input
              type="text"
              name="name"
              value={message}
              onChange={ e => setMessage(e.target.value) } />
          </label>
          
          <label>
            Address to send message to: &nbsp;
            <input
              type="text"
              name="name"
              value={messageRecipient}
              onChange={ e => setMessageRecipient(e.target.value) } />
          </label>
          <input type="submit" value="Create" />
          </p>
        </form>
      </header>
    </div>
  );
}

export default App;
