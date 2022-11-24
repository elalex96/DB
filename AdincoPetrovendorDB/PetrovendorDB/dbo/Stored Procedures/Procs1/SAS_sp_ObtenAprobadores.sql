-- =============================================
-- Author:		Luis David
-- Create date: 21/04/2022
-- Description:	Obtiene los usuarios de DEA excluyendo los de dominio @adinco.mx
-- =============================================
CREATE PROC SAS_sp_ObtenAprobadores
@IdProveedor int,
@IdContrato int,
@IdSolicitudAceptacionPedido int
AS
BEGIN

DECLARE @AprobadorActual varchar(300) = (
			SELECT 
			 u.Correo
			 FROM TA_Operacion O
			 JOIN TA_Tarea T 
				ON O.IdOperacion = T.IdOperacion
			 JOIN S_Usuario U
				ON T.IdAprobador = U.IdUsuario
			 JOIN TA_Estatus E
				ON T.IdEstatus = E.IdEstatus
			WHERE O.IdDocumento = @IdSolicitudAceptacionPedido
			AND O.IdTipoOperacion=20		
			AND T.Activo=1);

	SELECT
				U.IdUsuario,
				U.Nombre,
				U.Correo
			FROM dbo.S_UsuarioProveedor AS UP WITH (NOLOCK)
				JOIN dbo.S_Usuario AS U WITH (NOLOCK) ON UP.IdUsuario = U.IdUsuario 
					AND UP.IdProveedor = @IdProveedor
					AND U.Activo = 1
					AND (u.IsEliminado = 0 OR u.IsEliminado IS NULL)
					AND UP.IdContrato = @IdContrato
				JOIN dbo.S_Proveedor AS P WITH (NOLOCK) ON UP.IdProveedor = P.IdProveedor
			WHERE 
			U.Correo NOT LIKE '%@adinco.mx%' 
			and
			U.Correo <> @AprobadorActual
			GROUP BY U.IdUsuario, U.Nombre,U.Correo, P.IdProveedor, UP.IdUsuario
END