import React from 'react';
import { Formik } from 'formik';
import styled from 'styled-components';

const Item = styled.div`
  display: flex;
  flex-direction: row;
  padding: 5px;
  padding-bottom: 10px;
`

const Title = styled.div`
  width: 100px;
`

export const LotteryCreator = ({contract}) => {
  const handleCreateLottery = async ({name, size, price, ownerCommission}, {setSubmitting}) => {
    try {
      await contract.createLottery(name, size, price, ownerCommission);
    } catch (e) {
      console.log(e);
    }
    setSubmitting(false)
  }
  return (
    <div>
      <h2>Create New Lottery</h2>
      <Formik 
        initialValues={{name: '', size: 2, price: 0.5, ownerCommission: 1}}
        onSubmit={handleCreateLottery}
      >
      {({ values, errors, touched, handleChange, handleBlur, handleSubmit, isSubmitting }) => (
        <form onSubmit={handleSubmit}>
          <Item>
            <Title>Name:</Title>
            <input 
              type="text"
              name="name"
              onChange={handleChange}
              onBlur={handleBlur}
              value={values.name}
            /> 
            {errors.name && touched.name && errors.name}
          </Item>
          <Item>
            <Title>Size:</Title>
            <input 
              type="number"
              name="size"
              onChange={handleChange}
              onBlur={handleBlur}
              value={values.size}
            /> 
            {errors.size && touched.size && errors.size}
          </Item>
          <Item>
            <Title>Price:</Title>
            <input 
              type="number"
              name="price"
              onChange={handleChange}
              onBlur={handleBlur}
              value={values.price}
            /> 
            {errors.price && touched.price && errors.price}
          </Item>
          <Item>
            <Title>Commission:</Title>
            <input 
              type="number"
              name="ownerCommission"
              onChange={handleChange}
              onBlur={handleBlur}
              value={values.ownerCommission}
            /> 
            {errors.ownerCommission && touched.ownerCommission && errors.ownerCommission}
          </Item>
          <button type="submit" disabled={isSubmitting}>Submit</button>
        </form>
      )
      }
      </Formik>
    </div>
  )
}