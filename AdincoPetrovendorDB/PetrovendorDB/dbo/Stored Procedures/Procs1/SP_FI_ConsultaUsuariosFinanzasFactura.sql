-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/01/2019
-- Description:	Consultar los usuarios de finanzas de un proveedor poe factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaUsuariosFinanzasFactura] --236
	-- Add the parameters for the stored procedure here
	@IdAprobacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		US.IdUsuario,
		US.Nombre,
		US.Correo,
		PR.RazonSocial
	FROM dbo.MM_Pedido AS P 
		JOIN dbo.MM_AceptacionPedido AS AP ON
				AP.IdPedido = P.IdPedido
		JOIN dbo.S_UsuarioProveedor AS USP ON
				USP.IdProveedor = P.IdSubcontratista
		JOIN dbo.S_Usuario AS US ON
				US.IdUsuario = USP.IdUsuario
		JOIN dbo.S_Proveedor AS PR ON
				PR.IdProveedor = P.IdProveedorCompras
	WHERE AP.IdAceptacionPedido = @IdAprobacionPedido
		AND US.IdTipoUsuario = 6 --FINANZAS
END
