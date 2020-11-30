-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <08/03/2019>
-- Description:	<Store para retornar los representanes legales que tienen dados de alta en la empresa>
-- =============================================

CREATE PROCEDURE [dbo].[SP_CartaNombresRepresentanteLegalxIds] @IdTipoRegimen        INT, 
                                                              @IdRepresentanteLegal NVARCHAR(MAX)
AS
    BEGIN
        DECLARE @TablaIdsRepresentanteLegal TABLE(IdRepresentante INT);
        INSERT INTO @TablaIdsRepresentanteLegal(IdRepresentante)
               SELECT splitdata
               FROM dbo.fnSplitString(@IdRepresentanteLegal, ',');
        IF @IdTipoRegimen = 2
            BEGIN
                SELECT P.IdProveedor, 
                       P.RazonSocial
                FROM S_Proveedor AS P
                     INNER JOIN dbo.S_Documento_S3 AS DOC ON DOC.IdProveedor = P.IdProveedor
                                                             AND DOC.Activo = 1
                     INNER JOIN @TablaIdsRepresentanteLegal legal ON legal.IdRepresentante = P.IdProveedor
                WHERE DOC.IdTipoDocumento = 2;
        END;
        IF @IdTipoRegimen = 1
            BEGIN
                SELECT legal.IdRepresentanteLegal, 
                       legal.Nombre + ' ' + legal.APaterno + ' ' + legal.AMaterno AS RepLegal
                FROM dbo.DG_RepresentanteLegal legal
                     INNER JOIN dbo.S_Documento_S3 s3 ON legal.IdDocumento = s3.IdDocumento
                                                         AND s3.Activo = 1
                                                         AND legal.IdProveedor = s3.IdProveedor
                     INNER JOIN @TablaIdsRepresentanteLegal t ON t.IdRepresentante = legal.IdRepresentanteLegal
                WHERE legal.IsActivo = 1;
        END;
        IF @IdTipoRegimen = 3
            BEGIN
                SELECT TOP 1 U.IdUsuario, 
                             U.Nombre AS RepresentanteLegal
                FROM S_Proveedor AS P
                     INNER JOIN S_UsuarioProveedor UP ON P.IdProveedor = UP.IdProveedor
                     INNER JOIN S_Usuario U ON UP.IdUsuario = U.IdUsuario
                     INNER JOIN @TablaIdsRepresentanteLegal legal ON u.IdUsuario = legal.IdRepresentante
                WHERE U.IdTipoUsuario = 3;
        END;
    END;