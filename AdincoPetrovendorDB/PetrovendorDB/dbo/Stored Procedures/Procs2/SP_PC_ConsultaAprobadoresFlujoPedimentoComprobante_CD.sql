-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/09/2020>
-- Description:	<consulta del los aprobadores del flujo>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaAprobadoresFlujoPedimentoComprobante_CD]
	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		TT.IdTarea,
		TT.NoSecuencia,
		US.Nombre AS Aprobador,
		TT.FechaCambioEstatus,
		TT.IdEstatus,
		TT.Comentario
	FROM dbo.FI_AceptacionPedido_PedimentoComprobante AS APC
		JOIN dbo.FI_PedimentoComprobante AS PC 
			ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
		JOIN dbo.TA_Operacion AS OP
			ON OP.IdDocumento = APC.IdAceptacionPedidoPedimentoComprobante
			AND OP.IdTipoOperacion = 19
			AND OP.IdProveedor = APC.IdProveedor
		JOIN dbo.TA_Tarea AS TT
			ON TT.IdOperacion = OP.IdOperacion
				AND TT.Activo = 1
		JOIN dbo.S_Usuario AS US
			ON US.IdUsuario = TT.IdAprobador
	WHERE APC.IdPedimentoComprobante = @IdPedimentoComprobante

END
