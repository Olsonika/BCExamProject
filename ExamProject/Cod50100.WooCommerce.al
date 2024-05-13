codeunit 50107 WooCommerce
{
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

}
