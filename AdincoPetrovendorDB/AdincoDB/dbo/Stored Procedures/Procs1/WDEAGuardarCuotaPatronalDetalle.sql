USE [Adinco]

IF EXISTS(SELECT 1 FROM sysobjects WHERE name = 'WDEAGuardarCuotaPatronalDetalle')
DROP PROCEDURE WDEAGuardarCuotaPatronalDetalle
GO
CREATE PROCEDURE [dbo].WDEAGuardarCuotaPatronalDetalle
@IdCuotaPatronal INT,@LineItem NVARCHAR(200), @GLAccount NVARCHAR(200), @PostingKey NVARCHAR(500),@AccountShortText NVARCHAR(500), @Amount NVARCHAR(100), @Currency NVARCHAR(100), @Text NVARCHAR(1000), @WBS NVARCHAR(200), @CC NVARCHAR(100),  @BusinessArea NVARCHAR(100), @TaxCode NVARCHAR(500), @RI NVARCHAR(100), @USD NVARCHAR(500), @EUR NVARCHAR(500), @MXN NVARCHAR(500)
AS
BEGIN
	INSERT INTO DEA_CuotaPatronalDetalle(IdCuotaPatronal, LineItem, GLAccount, PostingKey, AccountShortText, Amount, Currency, Text, WBS, CC, BusinessArea, TaxCode, RI, USD, EUR, MXN)
	SELECT @IdCuotaPatronal, @LineItem, @GLAccount, @PostingKey, @AccountShortText, @Amount, @Currency, @Text, @WBS, @CC, @BusinessArea, @TaxCode, @RI, @USD, @EUR, @MXN
END