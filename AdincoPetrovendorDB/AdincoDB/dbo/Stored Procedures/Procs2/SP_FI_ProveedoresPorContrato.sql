--╔════════════════════════════════════════════╗
--║Uso de SP en Sistema de ADINCO y PETROVENDOR║
--╚════════════════════════════════════════════╝
-- =============================================
-- Author:		Manuel CD
-- ALTER date: 24-08-17
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK y Nombrado de Tablas en select
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ProveedoresPorContrato] @IdContrato INT
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT DISTINCT
        PV_Subcontratista.IdSubcontratista,
        UPPER(PV_Subcontratista.RazonSocial) AS RazonSocial,
        PV_Subcontratista.RFC
    FROM PV_Subcontratista (NOLOCK)
    WHERE PV_Subcontratista.RazonSocial <> ''
          AND PV_Subcontratista.RazonSocial <> '-'
          AND PV_Subcontratista.RFC IS NOT NULL
          AND PV_Subcontratista.RFC <> '-'
          AND PV_Subcontratista.RFC <> ''
          AND ISNULL(PV_Subcontratista.IsEliminado, 0) = 0
          AND PV_Subcontratista.IsActivo = 1
    ORDER BY UPPER(PV_Subcontratista.RazonSocial);
END;

