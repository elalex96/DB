
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ConsultaEstudioPrecios'
)
    DROP PROCEDURE SP_FI_ConsultaEstudioPrecios
GO
-- =============================================
-- Author:		Manuel CD
-- Create date: 12-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaEstudioPrecios]
@IdContrato INT, 
@IdUsuario  INT = 0
AS
     BEGIN

         SET NOCOUNT ON;

         SELECT IdEstudioPrecioTransfer, 
                FI_EstudioPreciosTransfer.Nombre, 
                SUBSTRING(Descripcion, 0, 30) AS Descripcion, 
                FolioOperacion,
                CASE
                    WHEN ISNULL(ProcesadoSIPAC, 0) = 0
                    THEN 'NO'
                    ELSE 'SI'
                END AS Presentado, 
                FI_EstudioPreciosTransfer.FechaInicioVigencia, 
                FI_EstudioPreciosTransfer.FechaFinVigencia, 
                FI_EstudioPreciosTransfer.FechaCargaSIPAC, 
                S.RazonSocial AS EmpresaRelacionada, 
                AP_Usuario.Nombre AS CreadoPor, 
                FI_EstudioPreciosTransfer.CreadoEn,
                CASE
                    WHEN FI_EstudioPreciosTransfer.Archivo LIKE 0x
                         OR FI_EstudioPreciosTransfer.Archivo IS NULL
                    THEN '¡PDF NO CARGADO!'
                    ELSE 'Pdf Cargado'
                END AS Archivo
         FROM FI_EstudioPreciosTransfer (NOLOCK)
              JOIN AP_Usuario (NOLOCK) 
				ON FI_EstudioPreciosTransfer.CreadoPor = AP_Usuario.UsuarioID
				AND FI_EstudioPreciosTransfer.IdContrato = @IdContrato
              JOIN dbo.PV_Subcontratista S (NOLOCK)
				ON FI_EstudioPreciosTransfer.IdSubcontratista = S.IdSubcontratista
         WHERE FI_EstudioPreciosTransfer.IdContrato = @IdContrato
         ORDER BY IdEstudioPrecioTransfer DESC;
     END;