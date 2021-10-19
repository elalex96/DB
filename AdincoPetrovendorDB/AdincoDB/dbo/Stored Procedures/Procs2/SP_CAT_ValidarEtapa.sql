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
-- Create date: 19/10/2021
-- Description:	Validacion de etapa existente
-- =============================================
CREATE PROCEDURE SP_CAT_ValidarEtapa
	-- Add the parameters for the stored procedure here
	@Etapa NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EXISTE_REGISTRO INT = (SELECT COUNT(1) FROM EN_Etapa WHERE Etapa = 'Accidente');

	IF @EXISTE_REGISTRO > 0
	BEGIN 
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END

END
GO