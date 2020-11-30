-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ObtenerIdMySTemporal]
@IdOperacion INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CT.IdAltaCatalogoProveedor 
	FROM [dbo].[PV_MM_AltaCatalogoProveedorTemp] CT
	INNER JOIN [dbo].[TA_Operacion] O ON O.IdDocumento = CT.IdAltaCatalogoProveedor
	WHERE O.IdOperacion = @IdOperacion


END

