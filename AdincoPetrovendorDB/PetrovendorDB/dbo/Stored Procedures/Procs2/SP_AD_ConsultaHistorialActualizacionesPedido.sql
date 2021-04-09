USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_AD_ConsultaHistorialActualizacionesPedido]    Script Date: 08/04/2021 01:32:53 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <31/03/2021>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultaHistorialActualizacionesPedido]
	-- Add the parameters for the stored procedure here
	@IdPedido INT,
	@Tipo NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		Responsable,
		ComentarioEditado,
		Descripcion,
		Fecha
	FROM dbo.AD_HistorialActualizacionPedido
	WHERE IdPedido = @IdPedido
		AND TipoEdicion = @Tipo
	ORDER BY Fecha DESC

END
