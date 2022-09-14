public with sharing class StripeApiHandler {

    public StripeApiHandler() {
        
    }
    
    public static String createCustomer(String email, String firstname, String lastname,String id)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String namedCredentials='callout:Stripe';
        String requestURL='/customers?';

        String params = 'email=' + EncodingUtil.urlEncode(email, 'UTF-8') 
        + '&name=' + EncodingUtil.urlEncode(firstname + ' ' + lastname, 'UTF-8')
        + '&metadata[SalesforceContactId]=' + EncodingUtil.urlEncode(id, 'UTF-8') ;
        System.debug(params);

        request.setEndpoint(namedCredentials + requestURL + params);
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
         // Parse JSON response to get the price id field values.
         JSONParser parser = JSON.createParser(response.getBody());
         String stripeId='';

         while (parser.nextToken() != null) {
             if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                 (parser.getText() == 'id')) {
                 // Get the value.
                 parser.nextToken();
                 // Compute the grand total price for all invoices.
                 stripeId = parser.getText();
                 break;
             }
         }
         system.debug('StripeId=' + stripeId);

        return stripeId;
    }

    public static String createCheckoutSession(String stripeCustomerId,
        String priceId, String SalesforceOrderId)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String namedCredentials='callout:Stripe';
        String requestURL='/checkout/sessions?';

        String params = 'cancel_url=' + EncodingUtil.urlEncode('https://openclassrooms.com/en/', 'UTF-8') +
        '&success_url=' + EncodingUtil.urlEncode('https://openclassrooms.com/en/', 'UTF-8') 
        + '&line_items[0]price=' + EncodingUtil.urlEncode(priceId, 'UTF-8') 
        + '&line_items[0]quantity=' + EncodingUtil.urlEncode('1', 'UTF-8') 
        + '&mode=' + EncodingUtil.urlEncode('payment', 'UTF-8') 
        + '&payment_method_types[0]=' + EncodingUtil.urlEncode('card', 'UTF-8') 
        + '&payment_method_types[1]=' + EncodingUtil.urlEncode('sepa_debit', 'UTF-8') 
        + '&customer=' + EncodingUtil.urlEncode(stripeCustomerId, 'UTF-8') 
        + '&metadata[SalesforceOrderId]=' + EncodingUtil.urlEncode(SalesforceOrderId, 'UTF-8')
        + '&payment_intent_data[metadata][SalesforceOrderId]=' + EncodingUtil.urlEncode(SalesforceOrderId, 'UTF-8');

        System.debug(params);
        
        request.setEndpoint(namedCredentials + requestURL + params);
        
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');

        HttpResponse response = http.send(request);
        // Parse the JSON response
        if (response.getStatusCode() != 200) {
            System.debug('The status code returned was not expected: ' +
                response.getStatusCode() + ' ' + response.getStatus());
        } else {
            System.debug(response.getBody());
        }
         // Parse JSON response to get the price id field values.
         JSONParser parser = JSON.createParser(response.getBody());
         String checkoutURL='';
         String paymentIntentURL = '';
         while (parser.nextToken() != null) {
             if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                 (parser.getText() == 'url')) {
                 // Get the value.
                 parser.nextToken();
                 // Compute the grand total price for all invoices.
                 checkoutURL = parser.getText();
                 //break;
             }
             else if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
             (parser.getText() == 'payment_intent')) {
             // Get the value.
             parser.nextToken();
             // Compute the grand total price for all invoices.
             paymentIntentURL = 'https://dashboard.stripe.com/test/payments/'+ parser.getText();
             //break;
         }
         
         }
         system.debug('checkoutURL=' + checkoutURL);

         system.debug('paymentIntentURL=' + paymentIntentURL);


        return checkoutURL + ';' + paymentIntentURL;
    }
}

