-- =============================================
-- Author:		Alexander Gomez
-- Create date: 09/01/2019
-- Description:	Consultar los usuarios de finanzas de un proveedor poe factura
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/11/2022
-- Description:	Se validan los usuarios activos
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
		PR.RazonSocial,
		US.IdTipoUsuario
	FROM dbo.MM_Pedido AS P (NOLOCK)
		 JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK) ON
				P.IdPedido = AP.IdPedido
		 JOIN dbo.S_UsuarioProveedor AS USP (NOLOCK) ON
				P.IdSubcontratista = USP.IdProveedor
		 JOIN dbo.S_Usuario AS US (NOLOCK) ON
				USP.IdUsuario = US.IdUsuario
		 JOIN dbo.S_Proveedor AS PR (NOLOCK) ON
				P.IdProveedorCompras = PR.IdProveedor
	WHERE AP.IdAceptacionPedido = @IdAprobacionPedido
		AND US.IdTipoUsuario = 6 --FINANZAS
		AND ISNULL(US.Activo,0) = 1
END
