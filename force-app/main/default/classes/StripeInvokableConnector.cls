public with sharing class StripeInvokableConnector {


    @InvocableMethod(label='Stripe Checkout Session' description='Creates the customer in Stripe and send out checkout link')
    public static void handleOrderUpdate(List<Id> Ids)
    {
        System.debug(Ids);
        String orderId = ids[0];
        System.debug(orderId);
        StripeBillingConnector.handleOrderUpdate(orderId);
    }
}
