USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ValidarEtapa]    Script Date: 03/05/2022 02:58:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 03/05/2021
-- Description:	Validacion de area existente en contrato
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ValidarAreaContrato]
	-- Add the parameters for the stored procedure here
	@NombreArea NVARCHAR(MAX),
	@idContrato INT,
	@Activo BIT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EXISTE_REGISTRO INT = (SELECT COUNT(1) 
									FROM EN_Area 
									WHERE NombreArea = @NombreArea 
									AND idContrato = @idContrato
									AND Activo = @Activo);

	IF @EXISTE_REGISTRO > 0
	BEGIN 
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END

END
