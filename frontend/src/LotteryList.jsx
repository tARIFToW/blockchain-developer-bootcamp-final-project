import React from 'react';
import styled from 'styled-components';


const Item = styled.span`
  padding-left: 5px;
`;

const LotteryItem = ({title, value}) => {
  return (<Item>{title}: {value}</Item>)
}

const Lottery = ({ lottery, active, contract }) => {

  const handleBuyTicket = async() => {
    try {
      await contract.buyTicket(lottery.id, lottery.ticketPrice);
    } catch(e) {
      console.log(e);
    }
  }
  
  const { id, name, size, ticketPrice, ticketHolderCount, owner, ownerCommission, completed, winner } = lottery;
  return (
    <div>
      <LotteryItem title={'ID'} value={id} />
      <LotteryItem title={'Name'} value={name} />
      <LotteryItem title={'Size'} value={size} />
      <LotteryItem title={'Price (Wei)'} value={ticketPrice} />
      <LotteryItem title={'Current Holder Count'} value={ticketHolderCount} />
      <LotteryItem title={'Owner'} value={owner} />
      <LotteryItem title={'Owner Commission (%)'} value={ownerCommission} />
      <LotteryItem title={'Completed'} value={completed.toString()} />
      <LotteryItem title={'Winner'} value={winner} />
      {active && !completed ? <button onClick={handleBuyTicket}>buy ticket</button> : null}
    </div>
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