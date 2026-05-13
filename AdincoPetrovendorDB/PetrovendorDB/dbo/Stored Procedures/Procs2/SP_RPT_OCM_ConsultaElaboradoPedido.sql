-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_RPT_OCM_ConsultaElaboradoPedido 
	-- Add the parameters for the stored procedure here
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT SU.Nombre NOMBRE,
		   SP.FechaAlta AS FECHA,
		   SP.IdFirma
	FROM dbo.MM_Pedido AS P
	LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	LEFT JOIN dbo.S_Usuario AS SU ON SU.IdUsuario = SP.IdUsuarioSolicitante
	WHERE P.IdPedido = @IdPedido
END

