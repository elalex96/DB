use adinco

IF EXISTS(SELECT 1
          FROM   sysobjects
          WHERE  NAME = 'WDEA_ImportarGastosNomina')
  DROP PROCEDURE WDEA_ImportarGastosNomina

go

CREATE PROCEDURE [dbo].[WDEA_ImportarGastosNomina]    
@IdContrato INT,  
@IdUsuario INT,
@Assignment VARCHAR(500),
@DocumentNumber VARCHAR(100),
@BusinessArea VARCHAR(100),
@DocumentType VARCHAR(100),
@DocumentDate VARCHAR(100),
@PostingKey VARCHAR(100),
@TaxCode VARCHAR(100),
@ClearingDocument VARCHAR(500),
@Text VARCHAR(8000),
@AmountInDocCurr VARCHAR(100),
@AmountInLocalCurrency VARCHAR(100),
@AmountInLocalCurrency2 VARCHAR(100),
@AmountInLocalCurrency3 VARCHAR(100),
@WBSElement VARCHAR(200),
@Account VARCHAR(100),
@LocalCurrency3 VARCHAR(50),
@DocumentCurrency VARCHAR(50),
@GeneralLedgerCurrency VARCHAR(50),
@LocalCurrency2 VARCHAR(50),
@LocalCurrency VARCHAR(50),
@YearMonth VARCHAR(50),
@CostCenter VARCHAR(500),
@RecoveryIndicator VARCHAR(50),
@JoinVenture VARCHAR(100),
@PostingPeriod VARCHAR(50),
@ReversedWith VARCHAR(50),
@TradingPartner VARCHAR(50),
@CompanyCode VARCHAR(50),
@InvoiceReference VARCHAR(50)
AS  
BEGIN  
		
	INSERT INTO DEA_ImportarGastosNomina(Assignment, DocumentNumber, BusinessArea, DocumentType, DocumentDate, PostingKey, TaxCode, ClearingDocument,
			Text, AmountInDocCurr, AmountInLocalCurrency, AmountInLocalCurrency2, AmountInLocalCurrency3, WBSElement, Account, LocalCurrency3, DocumentCurrency,
			GeneralLedgerCurrency, LocalCurrency2, LocalCurrency, YearMonth, CostCenter, RecoveryIndicator, JoinVenture, PostingPeriod, ReversedWith,
			TradingPartner, CompanyCode, InvoiceReference, IdContrato, IdUsuario, FechaDeCargaSQL)
	SELECT	@Assignment, @DocumentNumber, @BusinessArea, @DocumentType, @DocumentDate, @PostingKey, @TaxCode, @ClearingDocument,
			@Text, @AmountInDocCurr, @AmountInLocalCurrency, @AmountInLocalCurrency2, @AmountInLocalCurrency3, @WBSElement, @Account, @LocalCurrency3, @DocumentCurrency,
			@GeneralLedgerCurrency, @LocalCurrency2, @LocalCurrency, @YearMonth, @CostCenter, @RecoveryIndicator, @JoinVenture, @PostingPeriod, @ReversedWith,
			@TradingPartner, @CompanyCode, @InvoiceReference, @IdContrato, @IdUsuario, GETDATE()

END;
