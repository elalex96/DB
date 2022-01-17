USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[SP_EN_EliminarArchivo]    Script Date: 17/01/2022 02:44:31 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/01/2022>
-- Description:	<Eliminar archivo cargado en visor V2>
-- =============================================
CREATE PROCEDURE [dbo].[SP_EN_EliminarArchivo]
	-- Add the parameters for the stored procedure here
	@Id int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE EN_CarpetasArchivosVisor
	SET Activo = 0,
		FechaEliminado = GETDATE()
	WHERE IdElemento = @Id;


	SELECT Activo FROM EN_CarpetasArchivosVisor WHERE IdElemento = @Id;

END
