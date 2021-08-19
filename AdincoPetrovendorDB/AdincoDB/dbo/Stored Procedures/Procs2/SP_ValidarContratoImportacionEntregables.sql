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
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 18/08/2021
-- Description:	Validacion de contratos para importacion
-- =============================================
CREATE PROCEDURE SP_ValidarContratoImportacionEntregables
	-- Add the parameters for the stored procedure here
	@IdContrato INT
AS
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

	SELECT @RESPONSE AS RESPONSE

END
GO
