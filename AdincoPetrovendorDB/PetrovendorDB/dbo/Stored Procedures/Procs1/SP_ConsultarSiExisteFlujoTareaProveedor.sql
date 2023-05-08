-- =============================================
-- Author:		Abel Rivera
-- Create date: 31-08-17
-- Description:	Consulta la cantidad de flujos de aprobación de solicitud de pedido, por proveedor
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarSiExisteFlujoTareaProveedor]
@IdProveedor   int,
@IdTipoUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		 SELECT count (IdFlujoTarea)
	 FROM TA_FlujoTarea
	 WHERE IdProveedor = @IdProveedor
	 AND IdTipoOperacion = 2
	 AND CreadorPor = @IdTipoUsuario
	 AND (Eliminado IS NULL OR Eliminado = 0)

END

