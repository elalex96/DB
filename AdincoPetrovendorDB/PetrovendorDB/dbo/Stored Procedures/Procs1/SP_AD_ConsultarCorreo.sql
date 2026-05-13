USE [Petrovendor]
GO
-- Evaluamos si el SP existe; si es asi, lo eliminamos.
DROP PROCEDURE IF EXISTS [dbo].[SP_AD_ConsultarCorreo];
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-17
-- Modified:    Retornar columnas de auditoría con nombre de usuario
-- Description:	Consulta las plantillas de correo incluyendo
--              quién creó y quién modificó cada registro.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultarCorreo]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT C.IdCorreo,
           C.HTML,
           C.Asunto,
           C.Descripcion,
           C.IdServidor,
           C.CreadoPor,
           C.CreadoEl,
           C.ModificadoPor,
           C.ModificadoEl,
           ucreador.Nombre     AS NombreCreadoPor,
           umodificador.Nombre AS NombreModificadoPor
    FROM dbo.TA_Correo AS C WITH (NOLOCK)
        LEFT JOIN dbo.S_Usuario AS ucreador WITH (NOLOCK)
            ON ucreador.IdUsuario = C.CreadoPor
        LEFT JOIN dbo.S_Usuario AS umodificador WITH (NOLOCK)
            ON umodificador.IdUsuario = C.ModificadoPor
    ORDER BY C.IdCorreo ASC;
END
GO