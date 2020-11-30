-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/03/2019>
-- Description:	<Store para retornar los representanes legales que tienen dados de alta en la empresa>
-- =============================================

CREATE PROCEDURE SP_CartaNombresRepresentanteLegal @IdProveedor INT, @IdTipoRegimen INT
AS
	BEGIN
		IF @IdTipoRegimen = 2
			BEGIN
				SELECT	P.IdProveedor AS IdRepresentanteLegal, P.RazonSocial AS RepLegal
				  FROM	S_Proveedor AS P
						JOIN dbo.S_Documento_S3 AS DOC
							 ON DOC.IdProveedor = P.IdProveedor
								AND DOC.Activo = 1
				 WHERE
						P.IdProveedor = @IdProveedor
						AND DOC.IdTipoDocumento = 2
			END

		IF @IdTipoRegimen = 1
			BEGIN
				SELECT	legal.IdRepresentanteLegal ,
						legal.APaterno + ' ' + legal.AMaterno + ' ' + legal.Nombre AS RepLegal
				  FROM	dbo.DG_RepresentanteLegal legal
						INNER JOIN dbo.S_Documento_S3 s3
								   ON legal.IdDocumento = s3.IdDocumento
									  AND	s3.IdProveedor = @IdProveedor
									  AND	s3.Activo = 1
									  AND	legal.IdProveedor = s3.IdProveedor
				 WHERE
						legal.IdProveedor = @IdProveedor
						AND legal.IsActivo = 1
			END

		IF @IdTipoRegimen = 3
			BEGIN
				SELECT	TOP 1
						U.IdUsuario AS IdRepresentanteLegal, U.Nombre AS RepLegal
				  FROM	S_Proveedor AS P
						JOIN S_UsuarioProveedor UP
							 ON P.IdProveedor = UP.IdProveedor
						JOIN S_Usuario U
							 ON UP.IdUsuario = U.IdUsuario
				 WHERE
						U.IdTipoUsuario = 3
						AND P.IdProveedor = @IdProveedor
			END
	END