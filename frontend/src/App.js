import React, { useCallback, useEffect, useMemo, useState } from 'react';
import { useWeb3React, Web3ReactProvider } from '@web3-react/core'
import Web3 from 'web3';
import {injectedProvider} from './connector';
import { LotteryContractClient } from './lotteryContractClient';
import { LotteryList } from './LotteryList';
import { LotteryCreator } from './LotteryCreator';

function getLibrary(provider) {
  return new Web3(provider);
}

const App = () => {
  const { active, account, activate } = useWeb3React()
  const [lotteries, setLotteries] = useState([]);
  const connect = async () => {
    try {
      await activate(injectedProvider);
    } catch (e) {
      console.log(e);
    }
  }

  const contract = useMemo(() => {
    return new LotteryContractClient(account);
  }, [account])

  const getLotteries = useCallback(async() => {
    const lotteries = await contract.getLotteries();
    setLotteries(lotteries);
  }, [contract])

  useEffect(() => {
    const fetchLotteries = async() => {
      await getLotteries();
    }
    fetchLotteries();
  }, [getLotteries]);

  useEffect(() => {
    const fetchLotteries = async() => {
      await getLotteries();
    }

    if (active) {
      contract.contract.events.NewLottery().on("data", (e) => {
        fetchLotteries()
      })
      contract.contract.events.NewTicketPurchase().on("data", (e) => {
        fetchLotteries()
      })
      contract.contract.events.NewWinner().on("data", (e) => {
        fetchLotteries()
      })
    }

    return () => {
      contract.contract.events.NewLottery().unsubscribe()
      contract.contract.events.NewTicketPurchase().unsubscribe()
      contract.contract.events.NewWinner().unsubscribe()
    }
  }, [account])
  
  return (
    <div>
      <button onClick={connect} >Connect</button>
      {active ? <span>Connected with: <b>{account}</b></span> : <span>Not connected</span>}
      <LotteryList active={active} lotteries={lotteries} contract={contract}/>
      {active ? <LotteryCreator contract={contract}/> : null}
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
