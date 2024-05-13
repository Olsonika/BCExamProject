codeunit 50107 WooCommerce
{
    var
        Client: HttpClient;
        Ck: Label 'ck_9a45e7e61d8a620d141b932eac73899c3944478f';
        Cs: Label 'cs_08df11c3c291f08d9ee5da143cf616b847b6a363';

    procedure NewCustomer(Name: Text; Email: Text) result: Boolean
    var
        customerRec: Record Customer;
    begin
        customerRec.Init();
        customerRec.Validate(Name, Name);
        customerRec.Validate("E-Mail", Email);

        if not customerRec.Insert() then
            result := false;
        result := true;
    end;

    procedure NewProduct(Item: Record Item) JsonBody: JsonObject

    var
        Response: HttpResponseMessage;
        Request: HttpRequestMessage;
        Body: Text;
        Url: Text;
    begin
        SetAuth();
        JsonBody.Add('name', Item.Description);
        JsonBody.Add('regular_price', Format(Item."Unit Price"));
        JsonBody.WriteTo(Body);

        Url := 'http://ALEXROG:81/wordpress/wp-json/wc/v3/products';

        CreateHttpRequestMessage('POST', Url, Body, Request);

        if Client.Send(Request, Response) then begin
            //JsonBody := GetBodyAsJsonObject(Response);
            if Response.IsSuccessStatusCode() then begin
                Message('Status code OK');
            end
            else begin
                Message('PROBLEM %1', Response.HttpStatusCode());
            end;
        end else
            Message('ERROR');
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
