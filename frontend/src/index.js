import React from 'react';
import ReactDOM from 'react-dom';
import { Web3Provider } from "@ethersproject/providers";
import App from './App';
import { Web3ReactProvider } from '@web3-react/core';

ReactDOM.render(
  <React.StrictMode>
      <App />
  </React.StrictMode>,
  document.getElementById('root')
);
