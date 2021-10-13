USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ValidarEscenarioENI]    Script Date: 13/10/2021 01:50:47 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/10/2021
-- Description:	Validar si ya existe el escenario
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ValidarEscenarioENI]
	-- Add the parameters for the stored procedure here
	@Descripcion NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EXISTE_REGISTRO INT = (SELECT COUNT(1) FROM PRE_Escenario WHERE UPPER(Descripcion) = UPPER(@Descripcion));

	IF @EXISTE_REGISTRO > 0
	BEGIN 
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END


END
