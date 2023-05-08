-- =============================================
-- Author:      Marcos Garcia
-- Create date: 18-02-2020
-- Description:	Seleccion de Datos
--				Por Cadena de Solicitudes 
-- =============================================
CREATE PROCEDURE [dbo].[SP_RP_SolicitudUsuarioSIPAC] 
--[SP_RP_SolicitudUsuarioSIPAC] 3,'10000,10001,'
@IdContrato      INT, 
@CadenaSolicitud VARCHAR(MAX)
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT CA.IDSIPAC AS [RF_00], 
                C.IDRegFiducidiario AS [RI_00], 
                C.NumeroContrato AS [RI_01], 
                SPS.IdContrComerAsigFMP AS [IFC_01], 
                SPS.IdUsuarioSIPAC AS [ADM_000], 
                SPS.Nombre AS [ADM_001], 
                SPS.Apellido AS [ADM_002], 
                SPS.Correo AS [ADM_003], 
                SPS.IdPerfilAsignado AS [ADM_004], 
                SPS.RFC AS [ADM_005], 
                SPS.IdAccion AS [ADM_006],
                CASE
                    WHEN ISNULL(SPS.IdFacultado, 0) = 0
                    THEN 0
                    ELSE 1
                END AS [ADM_007]
         FROM dbo.CO_SolicitudUsuariosSIPAC SPS
              LEFT JOIN dbo.CO_Contrato C ON SPS.IdContrato = C.IdContrato
              LEFT JOIN dbo.CO_Contratista CA ON C.IdContratista = CA.IdContratista
         WHERE SPS.IdSolicitudUsuariosSIPAC IN
         (
             SELECT *
             FROM [fn_FI_StringList2Table](@CadenaSolicitud)
         );
     END;