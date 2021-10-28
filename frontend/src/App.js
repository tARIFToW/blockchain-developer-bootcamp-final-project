import React from 'react';
import { useWeb3React, Web3ReactProvider } from '@web3-react/core'
import { Web3Provider } from "@ethersproject/providers";
import { injectedProvider } from './connector';

function getLibrary(provider) {
  return new Web3Provider(provider);
}

const App = () => {
  const { active, account, library, connector, activate, deactivate } = useWeb3React()
  const connect = async () => {
    try {
      await activate(injectedProvider)
    } catch (e) {
      console.log(e);
    }
  }
  console.log(account)
  return (
    <div>
      <button onClick={connect} >Connect</button>
      {active ? <span>Connected with: <b>{account}</b></span> : <span>Not connected</span>}
    </div>
  );
}

export default function () {
  return (
    <Web3ReactProvider getLibrary={getLibrary}>
      <App />
    </Web3ReactProvider>
  );
}
