CREATE proc [dbo].[p_CO_InsUpdSAPFI_Invoice]
@pIdContrato    int,
@pInvoiceNumber    varchar(20),
@pInvoiceLine    tinyint,
@pFiscalYear    smallint,
@pPostingDate    varchar(10),
@pVendorNumber    varchar(20),
@pVendorName    varchar(20),
@pInvoiceAmount    float,
@pCurrency    varchar(5),
@pReferenceDocumentNumber    varchar(10),
@pCostCentre    varchar(10),
@pWBS    varchar(20),
@pGLAccount    varchar(20),
@pLineAmount    float
as
 

    if not exists (
        select 1
        from CO_SAPFI_Invoice
        where IdContrato = @pIdContrato and 
        InvoiceNumber = @pInvoiceNumber and
        InvoiceLine = @pInvoiceLine
    )
    begin
 
        insert into CO_SAPFI_Invoice(
            IdContrato,        InvoiceNumber,        InvoiceLine,        FiscalYear,
            PostingDate,    VendorNumber,        VendorName,            InvoiceAmount,
            Currency,        ReferenceDocumentNumber,CostCentre,        WBS,
            GLAccount,        LineAmount,            CreadoEl
        )
        values(
            @pIdContrato,        @pInvoiceNumber,@pInvoiceLine,        @pFiscalYear,
            @pPostingDate,    @pVendorNumber,        @pVendorName,            @pInvoiceAmount,
            @pCurrency,        @pReferenceDocumentNumber,@pCostCentre,        @pWBS,
            @pGLAccount,        @pLineAmount,    GETDATE()
        )
 
    end
    Else
    Begin
 
        update CO_SAPFI_Invoice
        set FiscalYear = @pFiscalYear,
            PostingDate = @pPostingDate,    
            VendorNumber = @pVendorNumber,        
            VendorName = @pVendorName,            
            InvoiceAmount = @pInvoiceAmount,
            Currency = @pCurrency,        
            ReferenceDocumentNumber = @pReferenceDocumentNumber,
            CostCentre = @pCostCentre,        
            WBS = @pWBS,
            GLAccount = @pGLAccount,        
            LineAmount = @pLineAmount
        where IdContrato = @pIdContrato and 
        InvoiceNumber = @pInvoiceNumber and
        InvoiceLine = @pInvoiceLine
 
    End
 

    EXEC p_COSAP_RecalcularContrato
 