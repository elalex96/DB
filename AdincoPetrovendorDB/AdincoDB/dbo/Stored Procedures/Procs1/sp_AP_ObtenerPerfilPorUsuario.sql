-- =============================================
-- Author:		Oscar Mtz
-- Create date: 03/07/2017
-- Description:	Devuelve el listado de los perfiles existentes.
-- =============================================
--20180709		Reyna olvera		Se modifico para cuando el usuario tenga asignado el perfil 6 independientemente del contrato en el que entre el perfil 6 es para rol administrador con contrato méxico 
--==============================================
-- [sp_AP_ObtenerPerfilPorUsuario] 10061,0,10061
CREATE PROCEDURE [dbo].[sp_AP_ObtenerPerfilPorUsuario] 
--
@UsuarioID       INT, 
@SoloAsignados   BIT = 1, 
@UsuarioSesionId INT = 1
AS
     BEGIN
         DECLARE @IsAdministradorRoot INT;

         /**/

         SELECT @IsAdministradorRoot = COUNT(PerfilID)
         FROM dbo.AP_PerfilUsuario
         WHERE UsuarioID = @UsuarioSesionId
               AND PerfilID IN(128, 416); --Para saber si el usuario tiene el perfil administrador no es dependiente del contrato
         /**/

         --SELECT @IsAdministradorRoot=COUNT(PerfilID) FROM dbo.AP_PerfilUsuario WHERE UsuarioID=@UsuarioSesionId AND PerfilID=128	  --******Para pr  (SOLO PARA ADMINISTRADORES ADINCO SERA EL PERFIL 128 ADMINISTRADOR ROOT)
         IF @IsAdministradorRoot > 0
             BEGIN
                 SELECT [PerfilUsuarioID] = ISNULL(pu.[PerfilUsuarioID], 0), 
                        Asignado = CAST(CASE
                                            WHEN pu.[PerfilUsuarioID] > 0
                                            THEN 1
                                            ELSE 0
                                        END AS BIT), 
                        pu.[UsuarioID], 
                        PerfilID = p.IdPerfil, 
                        p.Descripcion, 
                        c.NumeroContrato, 
                        --SUBSTRING(c.DescripcionContrato,1,1000) AS DescripcionContrato, 
						CA.NombreContratista	AS DescripcionContrato,
                        ISNULL(p.[CreadoPor], 0) CreadoPor
                 FROM AP_Perfil p
                      JOIN CO_Contrato c 
						ON p.IdContrato = c.IdContrato
					  JOIN CO_Contratista	CA
						ON	C.IdContratista	=	CA.IdContratista
                      LEFT JOIN [dbo].[AP_PerfilUsuario] pu 
						ON p.IdPerfil = pu.PerfilID
                        AND pu.UsuarioID = @UsuarioID
                 ORDER BY pu.[PerfilUsuarioID] DESC, 
                          p.Descripcion;
             END;
             ELSE
             BEGIN
                 SELECT
                 --RowNumber = ROW_NUMBER ( ) OVER(ORDER BY pu.[PerfilUsuarioID] ASC)  ,
                 [PerfilUsuarioID] = ISNULL(pu.[PerfilUsuarioID], 0), 
                 Asignado = CAST(CASE
                                     WHEN pu.[PerfilUsuarioID] > 0
                                     THEN 1
                                     ELSE 0
                                 END AS BIT), 
                 pu.[UsuarioID], 
                 PerfilID = p.IdPerfil, 
                 p.Descripcion, 
                 c.NumeroContrato, 
                 --SUBSTRING(c.DescripcionContrato,1,1000) AS DescripcionContrato, 
				 CA.NombreContratista	AS DescripcionContrato,
                 ISNULL(p.[CreadoPor], 0) CreadoPor
                 FROM AP_Perfil p
                      JOIN CO_Contrato c 
						ON p.IdContrato = c.IdContrato
					  JOIN CO_Contratista	CA
						ON	C.IdContratista	=	CA.IdContratista
                      INNER JOIN AP_Usuario u2 
						ON u2.UsuarioID = @UsuarioSesionId
                      INNER JOIN AP_PerfilUsuario pu2 
						ON u2.UsuarioID = pu2.UsuarioID
                      INNER JOIN AP_Perfil p2 
						ON pu2.PerfilID = p2.IdPerfil
                        AND p.IdContrato = p2.IdContrato
                      LEFT JOIN [dbo].[AP_PerfilUsuario] pu 
						ON p.IdPerfil = pu.PerfilID
                        AND pu.UsuarioID = @UsuarioID
                 WHERE(@SoloAsignados = 1
                       AND pu.[PerfilUsuarioID] > 0)
                      OR @SoloAsignados = 0
                 ORDER BY pu.[PerfilUsuarioID] DESC, 
					p.Descripcion;
             END;
     END;