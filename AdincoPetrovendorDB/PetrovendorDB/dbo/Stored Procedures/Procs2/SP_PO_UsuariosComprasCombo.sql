-- =============================================
-- Author:		Alexander Gomez
-- Create date: <11/02/2020>
-- Description:	<Consulta de los usuarios de compras>
-- =============================================
create PROCEDURE [dbo].[SP_PO_UsuariosComprasCombo] --420
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@IdSolcitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT
		US.IdUsuario AS Asignado,
		CONCAT(US.Nombre,'(',ISNULL(TU.NombreTipoUsuario,''),')') AS Nombre 
	FROM dbo.S_Usuario AS US
		LEFT JOIN dbo.S_UsuarioProveedor AS USP ON USP.IdUsuario = US.IdUsuario
		LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = USP.IdProveedor
		LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = US.IdTipoUsuario
	WHERE PR.IdProveedor = @IdProveedor 
		AND US.Activo = 1 
		AND ISNULL(US.IsEliminado,0) = 0
		AND US.IdUsuario NOT IN (SELECT IdAsignadoA FROM dbo.MM_SolicitudPedidoComprador WHERE IdSolicitudPedido = @IdSolcitudPedido AND Activo = 1)
	GROUP BY US.IdUsuario,
             US.Nombre,
			 TU.NombreTipoUsuario;
END

