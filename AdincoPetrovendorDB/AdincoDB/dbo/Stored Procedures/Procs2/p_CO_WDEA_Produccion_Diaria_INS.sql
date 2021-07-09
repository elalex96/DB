
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE PROC [dbo].[p_CO_WDEA_Produccion_Diaria_INS]
@Id	int out,
@IdAWS int,
@IdContrato int,
@Fecha	datetime,
@AceiteBrutoOG2_Balance	float,
@AceiteBrutoOG5_Balance	float,
@AceiteBrutoTotal_Balance	float,
@AceiteNetoOG2_Balance float,
@AceiteNetoOG5_Balance float,
@AceiteNetoTotal_Balance float,
@CDeAguaOG2_Balance	float,
@CDeAguaOG5_Balance	float,
@CDeAguaTotal_Balance	float,
@GasFormOG2_Balance	float,
@GasFormOG5_Balance	float,
@GasFormTotal_Balance	float,
@GasInyTotalOG2_Balance	float,
@GasInyTotalOG5_Balance	float,
@GasInyTotal_Balance	float,
@GasInySecoOG2_Balance	float,
@GasInySecoOG5_Balance	float,
@GasInySecoTotal_Balance	float,
@GasInyHumedoOG2_Balance	float,
@GasInyHumedoOG5_Balance	float,
@GasInyHumedoTotal_Balance	float,
@AceiteBrutoOG2_PEP	float,
@AceiteBrutoOG5_PEP	float,
@AceiteBrutoTotal_PEP	float,
@AceiteNetoOG2_PEP float,
@AceiteNetoOG5_PEP float,
@AceiteNetoTotal_PEP float,
@CDeAguaOG2_PEP	float,
@CDeAguaOG5_PEP	float,
@CDeAguaTotal_PEP	float,
@GasFormOG2_PEP	float,
@GasFormOG5_PEP	float,
@GasFormTotal_PEP	float,
@GasInyTotalOG2_PEP	float,
@GasInyTotalOG5_PEP	float,
@GasInyTotal_PEP	float,
@GasInySecoOG2_PEP	float,
@GasInySecoOG5_PEP	float,
@GasInySecoTotal_PEP	float,
@GasInyHumedoOG2_PEP	float,
@GasInyHumedoOG5_PEP	float,
@GasInyHumedoTotal_PEP	float,
@CreadoPor	int,
@Error VARCHAR(250) out
AS
BEGIN

BEGIN TRY

	INSERT INTO [dbo].[CO_WDEA_Produccion_Diaria]
			   (
			   [IdContrato]
			   ,[IdAWS]
			   ,[Fecha]
			   ,[AceiteBrutoOG2_Balance]
			   ,[AceiteBrutoOG5_Balance]
			   ,[AceiteBrutoTotal_Balance]
			   ,AceiteNetoOG2_Balance
				,AceiteNetoOG5_Balance
				,AceiteNetoTotal_Balance
			   ,[CDeAguaOG2_Balance]
			   ,[CDeAguaOG5_Balance]
			   ,[CDeAguaTotal_Balance]
			   ,[GasFormOG2_Balance]
			   ,[GasFormOG5_Balance]
			   ,[GasFormTotal_Balance]
			   ,[GasInyTotalOG2_Balance]
			   ,[GasInyTotalOG5_Balance]
			   ,[GasInyTotal_Balance]
			   ,[GasInySecoOG2_Balance]
			   ,[GasInySecoOG5_Balance]
			   ,[GasInySecoTotal_Balance]
			   ,[GasInyHumedoOG2_Balance]
			   ,[GasInyHumedoOG5_Balance]
			   ,[GasInyHumedoTotal_Balance]
			   ,[AceiteBrutoOG2_PEP]
			   ,[AceiteBrutoOG5_PEP]
			   ,[AceiteBrutoTotal_PEP]
				,AceiteNetoOG2_PEP 
				,AceiteNetoOG5_PEP 
				,AceiteNetoTotal_PEP 
			   ,[CDeAguaOG2_PEP]
			   ,[CDeAguaOG5_PEP]
			   ,[CDeAguaTotal_PEP]
			   ,[GasFormOG2_PEP]
			   ,[GasFormOG5_PEP]
			   ,[GasFormTotal_PEP]
			   ,[GasInyTotalOG2_PEP]
			   ,[GasInyTotalOG5_PEP]
			   ,[GasInyTotal_PEP]
			   ,[GasInySecoOG2_PEP]
			   ,[GasInySecoOG5_PEP]
			   ,[GasInySecoTotal_PEP]
			   ,[GasInyHumedoOG2_PEP]
			   ,[GasInyHumedoOG5_PEP]
			   ,[GasInyHumedoTotal_PEP]
			   ,[CreadoPor]
			   ,[CreadoEl])
		 VALUES
			   (
			   @IdContrato,
			   @IdAWS,
			   @Fecha, 
			   @AceiteBrutoOG2_Balance, 
			   @AceiteBrutoOG5_Balance, 
			   @AceiteBrutoTotal_Balance, 
			   @AceiteNetoOG2_Balance,
				@AceiteNetoOG5_Balance,
				@AceiteNetoTotal_Balance,
			   @CDeAguaOG2_Balance, 
			   @CDeAguaOG5_Balance, 
			   @CDeAguaTotal_Balance, 
			   @GasFormOG2_Balance, 
			   @GasFormOG5_Balance, 
			   @GasFormTotal_Balance, 
			   @GasInyTotalOG2_Balance, 
			   @GasInyTotalOG5_Balance, 
			   @GasInyTotal_Balance, 
			   @GasInySecoOG2_Balance, 
			   @GasInySecoOG5_Balance, 
			   @GasInySecoTotal_Balance, 
			   @GasInyHumedoOG2_Balance, 
			   @GasInyHumedoOG5_Balance, 
			   @GasInyHumedoTotal_Balance, 
			   @AceiteBrutoOG2_PEP, 
			   @AceiteBrutoOG5_PEP, 
			   @AceiteBrutoTotal_PEP, 
			   @AceiteNetoOG2_PEP ,
				@AceiteNetoOG5_PEP ,
				@AceiteNetoTotal_PEP ,
			   @CDeAguaOG2_PEP, 
			   @CDeAguaOG5_PEP, 
			   @CDeAguaTotal_PEP, 
			   @GasFormOG2_PEP, 
			   @GasFormOG5_PEP, 
			   @GasFormTotal_PEP, 
			   @GasInyTotalOG2_PEP, 
			   @GasInyTotalOG5_PEP, 
			   @GasInyTotal_PEP, 
			   @GasInySecoOG2_PEP, 
			   @GasInySecoOG5_PEP, 
			   @GasInySecoTotal_PEP, 
			   @GasInyHumedoOG2_PEP, 
			   @GasInyHumedoOG5_PEP, 
			   @GasInyHumedoTotal_PEP, 
			   @CreadoPor, 
			   GETDATE() )

		SET @Id = SCOPE_IDENTITY()

END TRY
BEGIN CATCH
	SET @Error = ERROR_MESSAGE()
END CATCH

END

