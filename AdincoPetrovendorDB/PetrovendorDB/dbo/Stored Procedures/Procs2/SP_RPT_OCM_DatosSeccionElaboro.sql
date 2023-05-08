-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_OCM_DatosSeccionElaboro]
	-- Add the parameters for the stored procedure here
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	SU.Nombre AS ELABORO,
	P.CreadoEl AS FECHA,
	TT.IdTarea AS IDFIRMAELECTRONICA
	FROM dbo.MM_Pedido AS P
	LEFT JOIN dbo.S_Usuario AS SU ON SU.IdUsuario = P.CreadoPor
	LEFT JOIN dbo.TA_Operacion AS OP ON OP.IdDocumento = P.IdSolicitudPedido AND OP.IdAsignador = P.CreadoPor
	LEFT JOIN dbo.TA_Tarea AS TT ON TT.IdOperacion = OP.IdOperacion AND TT.IdEstatus = 2
	WHERE P.IdPedido = @IdPedido 
END
