if exists(select * from sys.procedures where name = 'SP_ObtenerDatosPorCorreo')
begin
	drop proc SP_ObtenerDatosPorCorreo
end

go

-- =============================================
-- Author:		<Jose Roman>
-- Modified date: <16-03-2018>
-- Description:	<Se obtienen datos del usaurio para el inicio de sesi�n, login v3>
-- =============================================
-- =============================================
-- Author:		Ramón Portales
-- Modified date: <29-03-2022>
-- Description:	Se agregó el IdProveedor a la consulta resultante
-- =============================================
CREATE PROCEDURE [dbo].[SP_ObtenerDatosPorCorreo]
(
    @Correo NVARCHAR(MAX),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
)
AS
BEGIN
    
	DECLARE @IdProveedor INT 
	
	
	SELECT @IdProveedor = up.IdProveedor
	                      FROM dbo.S_Usuario U
						  INNER JOIN dbo.S_UsuarioProveedor UP
						  ON UP.IdUsuario = U.IdUsuario WHERE U.Correo = @Correo AND 
						  U.Activo = 1 AND U.IsEliminado = 0

	SELECT		u.IdUsuario,
				u.Contrasena,
				u.Nombre,
				i.ImagenProveedorThumb,
				u.FechaRegistro,
				Activo	=		CASE WHEN (		SELECT		COUNT(*) 	
												FROM		dbo.S_UsuarioProveedor	UP
												INNER JOIN	dbo.S_Usuario			U
												ON			u.IdUsuario				=	UP.IdUsuario
												WHERE		UP.IdProveedor			=	@IdProveedor 
												AND			U.IdTipoUsuario			=	3 
												AND			U.Activo				=	1 
												AND			U.IsEliminado			=	0
											) > 0 THEN U.Activo ELSE 0 END,
				u.IsEliminado,
				ISNULL(u.CorreoVerificado,0),
				p.RFC,
				p.RazonSocial,
				ISNULL(p.IdPais,42),
				ISNULL(p.IdTipoRegimen,1),
				IdProveedor					=	@IdProveedor
	FROM		dbo.S_Usuario u
	LEFT JOIN	dbo.S_UsuarioProveedor		up
	ON			up.IdUsuario				=	u.IdUsuario
	LEFT JOIN	dbo.S_Proveedor				p
	ON			p.IdProveedor				=	up.IdProveedor	
	LEFT JOIN	dbo.S_ImagenPerfil			i	
	ON			i.IdProveedor				=	up.IdProveedor
	WHERE		u.Correo					=	@Correo 
	AND			u.IsEliminado				=	0
END