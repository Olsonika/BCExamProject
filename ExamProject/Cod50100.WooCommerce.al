codeunit 50107 WooCommerce
{
    var
        Client: HttpClient;
        Ck: Label 'ck_1cf31c0049854b21f89c3b894feb8020c9d56788';
        Cs: Label 'cs_dc1ae3b13e6cbaf56c5ae6b19fd90d154b4b3467';

    procedure NewSalesOrder(Name: Text; OrderNo: Code[20]; ItemNo: Code[20]; Quantity: Integer) result: Text
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Customer: Record Customer;
        Item: Record Item;
        confirmation: Codeunit "Send Mail";
    begin
        Customer.SetRange(Customer.Name, Name);
        if Customer.FindFirst() then begin
            SalesHeader.Init();
            SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
            SalesHeader."Sell-to Customer No." := Customer."No.";
            SalesHeader."Sell-to Customer Name" := Customer.Name;
            SalesHeader."No." := OrderNo;

            if SalesHeader.Insert() then begin
                result := 'Inserted';
                confirmation.SendConfMail(Customer);
                Item.SetRange(Item."No.", ItemNo);
                if Item.FindFirst() then begin
                    SalesLine.Init();
                    SalesLine."Document Type" := SalesHeader."Document Type";
                    SalesLine."Document No." := SalesHeader."No.";
                    SalesLine."Line No." := SalesLine.Count * 10000 + 10000;
                    SalesLine."Type" := SalesLine."Type"::Item;
                    SalesLine."No." := Item."No.";
                    SalesLine.Quantity := Quantity;
                    if SalesLine.Insert() then begin
                        result := 'Inserted';
                    end else begin
                        result := 'Couldnt insert salesline';
                    end;
                end else begin
                    result := 'Couldnt insert salesheader';
                end;
            end else begin
                result := 'Customer not found';
            end;
        end;
    end;

    procedure NewCustomer(Name: Text; Email: Text; No: Code[20]) result: Boolean
    var
        customerRec: Record Customer;
        welcome: Codeunit "Send Mail";
    begin
        customerRec.Init();
        customerRec.Validate(Name, Name);
        customerRec.Validate("E-Mail", Email);
        customerRec."No." := No;


        if not customerRec.Insert() then begin
            result := false;
        end else begin
            result := true;
            welcome.SendWelcomeMail(customerRec);
        end;
    end;

    procedure NewProduct(Item: Record Item) JsonBody: JsonObject

    var
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        Body: Text;
        Url: Text;
        ErrorMessage: Text;
    begin
        SetAuth();
        JsonBody.Add('name', Item.Description);
        JsonBody.Add('regular_price', Format(Item."Unit Price"));
        JsonBody.Add('manage_stock', true);
        JsonBody.Add('stock_quantity', Item.Inventory);
        JsonBody.WriteTo(Body);

        Message('Request Body: %1', Body);

        Url := 'http://ALEXROG:81/wordpress/wp-json/wc/v3/products';


        CreateHttpRequestMessage('POST', Url, Body, Request);

        if Client.Send(Request, Response) then begin
            if Response.IsSuccessStatusCode then begin
                Message('Status code OK, Product added to WC');
            end
            else begin
                Message('PROBLEM %1', Response.HttpStatusCode);
            end;
        end else begin
            ErrorMessage := 'HTTP Status Code: ' + Format(Response.HttpStatusCode);
            Message('ERROR: %1', ErrorMessage);
        end;
    end;

    local procedure SetAuth()
    begin
        if not (Client.DefaultRequestHeaders.Contains('User-Agent') and
            Client.DefaultRequestHeaders.Contains('Authorization')
        ) then begin
            Client.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
            Client.DefaultRequestHeaders.Add('Authorization', CreateAuthString());
        end;
    end;

    local procedure CreateHttpRequestMessage(Method: Text; Url: Text; Body: Text; Request: HttpRequestMessage)
    var
        Content: HttpContent;
        Headers: HttpHeaders;
    begin
        Content.WriteFrom(Body);

        Content.GetHeaders(headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.Content := Content;
        Request.SetRequestUri(Url);
        Request.Method := Method;
    end;

    local procedure CreateAuthString() AuthString: Text
    var
        TypeHelper: Codeunit "Base64 Convert";
    begin
        AuthString := STRSUBSTNO('%1:%2', Ck, Cs);
        AuthString := TypeHelper.ToBase64(AuthString);
        AuthString := STRSUBSTNO('Basic %1', AuthString);
    end;

    local procedure GetBodyAsJsonObject(Response: HttpResponseMessage) JsonBody: JsonObject
    var
        Body: Text;
    begin
        Response.Content.ReadAs(Body);
        JsonBody.ReadFrom(Body);
    end;

    local procedure getFieldTextAsText(JObject: JsonObject; fieldName: Text): Text
    var
        returnVal: Text;
        JToken: JsonToken;
    begin
        if JObject.Get(fieldName, JToken) then
            returnVal := JToken.AsValue().AsText();

        exit(returnVal);
    end;
}
