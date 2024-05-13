tableextension 50100 "Item Table Ext" extends Item
{
    trigger OnAfterInsert()
    var
        WooCommerce: Codeunit WooCommerce;
    begin
        if Rec.Description <> '' then begin
            WooCommerce.NewProduct(Rec);
        end;
    end;
}
