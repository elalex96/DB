USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_CAT_ValidarTiempoEntrega]    Script Date: 07/10/2021 12:23:52 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/10/2021
-- Description:	Validar si ya existe el tiempo de entrega
-- =============================================
CREATE PROCEDURE [dbo].[SP_CAT_ValidarTiempoEntrega]
	-- Add the parameters for the stored procedure here
	@TiempoEntrega NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EXISTE_REGISTRO INT = (SELECT COUNT(1) FROM EN_TiempoEntrega WHERE UPPER(TiempoEntrega) = UPPER(@TiempoEntrega));

	IF @EXISTE_REGISTRO > 0
	BEGIN 
		SELECT 1
	END
	ELSE
	BEGIN
		SELECT 0
	END


END
