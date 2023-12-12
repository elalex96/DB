
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_CO_ConsultaInstalaciones'
)
    DROP PROCEDURE sp_CO_ConsultaInstalaciones
GO
-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	09 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaInstalaciones]
    @IdContrato INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdAreacontractual AS INT;
    --
    SELECT @IdAreacontractual = dbo.CO_Contrato.IdAreaContractual
    FROM dbo.CO_Contrato (NOLOCK)
    WHERE dbo.CO_Contrato.idcontrato = @IdContrato;
    --
    SELECT dbo.CO_Instalacion.IdInstalacion,
           dbo.CO_Instalacion.NombreInstalacion,
           dbo.CO_Instalacion.IdInstalacionPemex,
           dbo.CO_ActividadCIEP.NombreActividad
    FROM dbo.CO_Instalacion (NOLOCK)
        INNER JOIN dbo.CO_ActividadCIEP (NOLOCK)
            ON dbo.CO_Instalacion.IdAreaContractual = @IdAreaContractual
               AND dbo.CO_Instalacion.IdActividad = dbo.CO_ActividadCIEP.IdActividad
		ORDER BY CO_Instalacion.NombreInstalacion, CO_ActividadCIEP.NombreActividad
END;