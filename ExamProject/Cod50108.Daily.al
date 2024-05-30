codeunit 50108 Daily
{
    procedure GetSalesDataLast24Hours(var SalesLines: array[10] of Record "Sales Line"; var Count: Integer): Decimal
    var
        SalesLine: Record "Sales Line";
        TotalTurnover: Decimal;
        StartDate: Date;
        EndDate: Date;
    begin
        StartDate := Today() - 1;
        EndDate := Today();

        TotalTurnover := 0;
        Count := 0;

        SalesLine.SetRange("Shipment Date", StartDate, EndDate);

        if SalesLine.FindSet() then begin
            repeat
                if Count >= 10 then
                    Error('Increase the array size.');

                SalesLines[Count] := SalesLine;
                Count += 1;

                TotalTurnover += SalesLine."Line Amount";
            until SalesLine.Next() = 0;
        end;

        exit(TotalTurnover);
    end;

    procedure SendSalesOverviewEmail()
    var
        SalesLines: array[10] of Record "Sales Line";
        TotalTurnover: Decimal;
        ProductSales: array[10] of Record "Item Sales Summary";
        Count, ProductCount : Integer;
        EmailBody: Text;
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
        SalesAdminEmail: Text;
        i: Integer;
        Found: Boolean;
        j: Integer;
        EmailScenario: Enum "Email Scenario";
    begin
        TotalTurnover := GetSalesDataLast24Hours(SalesLines, Count);

        ProductCount := 0;

        for i := 0 to Count - 1 do begin
            Found := false;
            for j := 0 to ProductCount - 1 do begin
                if ProductSales[j]."No." = SalesLines[i]."No." then begin
                    ProductSales[j].Quantity += SalesLines[i].Quantity;
                    Found := true;
                    break;
                end;
            end;

            if not Found then begin
                if ProductCount >= 10 then
                    Error('Increase the array size.');

                ProductSales[ProductCount]."No." := SalesLines[i]."No.";
                ProductSales[ProductCount].Quantity := SalesLines[i].Quantity;
                ProductCount += 1;
            end;
        end;

        EmailBody := 'Sales Overview for the Last 24 Hours:';
        for i := 0 to ProductCount - 1 do
            EmailBody += StrSubstNo('%1: %2 units sold', ProductSales[i]."No.", ProductSales[i].Quantity);

        EmailBody += StrSubstNo('Total Turnover: %1', Format(TotalTurnover));

        EmailMessage.Create('alekur01@easv365.dk', 'Daily turnover', EmailBody);

        Email.Send(EmailMessage, Enum::"Email Scenario"::SalesAdminScenario);
    end;

    trigger OnRun()
    begin
        SendSalesOverviewEmail();
    end;
}
