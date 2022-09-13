# How to use
- Deploy the source package to a scratch org
- Update the named credential , add your stripe key as username, and : as password
- Activate flows
- Create products. Make sure price book entries contain the proper stripe id (price in stripe)
- Create an order and contract, make sure 'Customer authorized by' field is set up
- Validate the order

Note: only supports one time payment and one order item. 
If willing to use subscription update the StripeApiHandler.createCheckoutSesssion : change mode to subscription, remove the payment intent data part
If willing to have multi products order, iterate over the order products  (StripeBillingConnector.handleOrderUpdate) and pass a list to the StripeAPIHandler.createCheckoutSession

