import React from 'react';
import styled from 'styled-components';
import Web3 from 'web3';


const Item = styled.div`
  padding: 5px;
  padding-bottom: 10px;
`;

const ItemList = styled.div`
  display: flex;
  flex-direction: row;
`

const LotteryItem = ({title, value}) => {
  return (<Item><b>{title}</b>: {value}</Item>)
}

const Lottery = ({ lottery, active, contract }) => {

  const handleBuyTicket = async() => {
    try {
      await contract.buyTicket(lottery.id, lottery.ticketPrice);
    } catch(e) {
      console.log(e);
    }
  }
  
  const { name, size, ticketPrice, ticketHolderCount, ownerCommission, completed, winner } = lottery;
  return (
    <ItemList>
      <LotteryItem title={'Name'} value={name} />
      <LotteryItem title={'Size'} value={`${ticketHolderCount}/${size}`} />
      <LotteryItem title={'Price (Ether)'} value={Web3.utils.fromWei(ticketPrice.toString(), "ether")} />
      <LotteryItem title={'Owner Commission (%)'} value={ownerCommission} />
      <LotteryItem title={'Completed'} value={completed.toString()} />
      <LotteryItem title={'Winner'} value={winner} />
      {active && !completed ? <button onClick={handleBuyTicket}>buy ticket</button> : null}
    </ItemList>
  )
}

export const LotteryList = ({lotteries, active, contract}) => {
  return (
    <div>
      <h2>Lottery List</h2>
      {lotteries.map(lottery => <Lottery key={lottery.id} lottery={lottery} active={active} contract={contract}/>)}
    </div>
  )
}