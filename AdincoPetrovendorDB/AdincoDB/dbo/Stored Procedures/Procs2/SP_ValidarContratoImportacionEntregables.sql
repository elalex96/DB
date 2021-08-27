-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
DROP PROCEDURE IF EXISTS SP_ValidarContratoImportacionEntregables
GO
CREATE PROCEDURE SP_ValidarContratoImportacionEntregables
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <01/06/2021>
-- Description:	<Consulta de entregables para importacion>
-- =============================================
-- Author:		<Luis David De La Cruz>
-- Create date: <26/08/2021>
-- Description:	<Formato para Shell>
-- =============================================
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @RESPONSE NVARCHAR(100) = '';
    -- Insert statements for procedure here
	IF @IdContrato IN (10093,10108,10110,10119,10120,10122)--Eni. Equinor, Murphy, Carso, Smart (México)
	BEGIN
		SET @RESPONSE= 'REPSOL'
		
	END

	IF @IdContrato IN (3,10039,10047,10048,10049,10050,10054,10055,10056,10057,10058)--REPSOL
	BEGIN
		SET @RESPONSE= 'ADINCO'
	END
	IF @IdContrato IN (10101,10103,10104,10106,10107,10112,10113,10115,10118,10131) 
	BEGIN
		SET @RESPONSE= 'SHELL'
	END
	SELECT @RESPONSE AS RESPONSE

END
