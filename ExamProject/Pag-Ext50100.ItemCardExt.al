pageextension 50100 "Item Card Ext" extends "Item Card"
{
    actions
    {
        addfirst(navigation)
        {
            action("Send Item to Woo")
            {
                Image = SendConfirmation;
                ApplicationArea = All;
                Promoted = true;

                trigger OnAction()
                var
                    WooCommerce: Codeunit WooCommerce;
                begin
                    WooCommerce.NewProduct(Rec);
                end;
            }
        }
    }
}
