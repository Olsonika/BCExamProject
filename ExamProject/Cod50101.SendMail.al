codeunit 50110 "Send Mail"
{
    procedure SendWelcomeMail(Customer: Record Customer)
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Create(Customer."E-Mail", 'Welcome!', 'Happy to have you here!');
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    procedure SendConfMail(Customer: Record Customer)
    var
        Email: Codeunit Email;
        EmailMessage: Codeunit "Email Message";
    begin
        EmailMessage.Create(Customer."E-Mail", 'Thank you for your order!', 'We will update you as soon as we ship your order!');
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;
}
