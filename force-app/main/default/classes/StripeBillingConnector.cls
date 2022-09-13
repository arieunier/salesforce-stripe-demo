public with sharing class StripeBillingConnector {
    
    @future(callout=true)
    public static void handleOrderUpdate(String orderId)
    {
        System.debug(orderId);
        String priceId='';

        Order o = [select id, OrderNumber, CustomerAuthorizedById,Pricebook2Id from Order where id = :orderId];
        System.debug(o);

        // gets the Contact Data
        Contact contact = [select firstname, lastname, email, id from Contact where id = :o.CustomerAuthorizedById];

        // now gets the producs 
        for (OrderItem ordItem : [select id, ListPrice, Product2Id from OrderItem where OrderId= :o.Id])
        {
            System.debug(ordItem);
            // gets pricebook entry
            System.debug('select id, Stripe_UID__c from PricebookEntry where Product2Id = ' + ordItem.Product2Id + 'and Pricebook2Id = ' + o.Pricebook2Id + ' and UnitPrice= ' + ordItem.ListPrice + ' LIMIT 1 ');
            List<PricebookEntry> entries = [ select id, Stripe_UID__c from PricebookEntry where Product2Id = :ordItem.Product2Id and Pricebook2Id = :o.Pricebook2Id and UnitPrice= :ordItem.ListPrice LIMIT 1];
            for (PriceBookEntry entry : entries)
            {
                System.debug(entry);
                priceId = entry.Stripe_UID__c;
                System.debug(priceId);
            }
        }

        String StripeCustomerId = StripeApiHandler.createCustomer(contact.email,  contact.firstname ,contact.lastname, contact.id);
        System.debug(StripeCustomerId);
        System.debug('### stripecustomerId=' + StripeCustomerId);
        System.debug('### priceId=' + priceId);
        System.debug('### OrderNumber=' + o.OrderNumber);

        
        String StripeURLS=StripeApiHandler.createCheckoutSession(StripeCustomerId, priceId, o.OrderNumber);
        String StripeCheckoutSessionURL = StripeURLS.split(';',3)[0];
        String StripePaymentIntentURL = StripeURLS.split(';',3)[1];
        System.debug(StripeCheckoutSessionURL);
        System.debug(StripePaymentIntentURL);
        // generates a platform event
        List<StripeEmail__e> stripeEmail = new List<StripeEmail__e>();
        stripeEmail.add(new StripeEmail__e(CheckoutURL__c=StripeCheckoutSessionURL, 
        CustomerEmail__c=contact.email, 
        OrderNumber__c=o.OrderNumber,
        PaymentIntentURL__c=StripePaymentIntentURL));
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(stripeEmail);

        // updates contact
        contact.Stripe_UID__c=StripeCustomerId;
        update contact;

        }

    }
