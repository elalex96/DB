USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_AD_ConsultaRegistroIteraciones'
)
    DROP PROCEDURE USP_SEL_AD_ConsultaRegistroIteraciones;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Consulta el grid principal de registro de iteraciones con datos de auditoria.
-- =============================================
CREATE PROCEDURE [dbo].[USP_SEL_AD_ConsultaRegistroIteraciones]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RI.[IdIteracion],
           RI.[VersionIteracion],
           RI.[Modulo],
           RI.[FechaRegistro],
           RI.[Aplicacion],
           RI.[TipoActualizacion],
           UC.[Nombre] AS [CreadoPor],
           UM.[Nombre] AS [ModificadoPor],
           RI.[ModificadoEl]
    FROM [RegistroIteraciones] RI
        LEFT JOIN [S_Usuario] UC
            ON RI.[CreadoPor] = UC.[IdUsuario]
        LEFT JOIN [S_Usuario] UM
            ON RI.[ModificadoPor] = UM.[IdUsuario]
    WHERE RI.[IsEliminado] IS NULL;
END
