import React from 'react';
import { Formik } from 'formik';

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
          Name:
          <input 
            type="text"
            name="name"
            onChange={handleChange}
            onBlur={handleBlur}
            value={values.name}
            /> 
          {errors.name && touched.name && errors.name}
          <br/>
          Size: 
          <input 
            type="number"
            name="size"
            onChange={handleChange}
            onBlur={handleBlur}
            value={values.size}
            /> 
          {errors.size && touched.size && errors.size}
          <br/>
          Price:
          <input 
            type="number"
            name="price"
            onChange={handleChange}
            onBlur={handleBlur}
            value={values.price}
            /> 
          {errors.price && touched.price && errors.price}
          <br/>
          Commission:
          <input 
            type="number"
            name="ownerCommission"
            onChange={handleChange}
            onBlur={handleBlur}
            value={values.ownerCommission}
            /> 
          {errors.ownerCommission && touched.ownerCommission && errors.ownerCommission}
          <br/>
          <button type="submit" disabled={isSubmitting}>Submit</button>
        </form>
      )
      }
      </Formik>
    </div>
  )
}