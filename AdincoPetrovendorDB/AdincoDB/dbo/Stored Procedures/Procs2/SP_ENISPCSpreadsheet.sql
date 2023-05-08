-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-06-2020
-- Description:	Consulta de Archivo CNH SPC
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENISPCSpreadsheet] 
-- ============================================= 
--[SP_ENISPCSpreadsheet] 3,0
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        --=============================================  
        SET LANGUAGE Spanish;
        --=============================================  
        SELECT TOP 1 IE.FechaCalculadaEntregaReg, 
                     ED.DocumentoEntregableId, 
                     ED.NombreArchivo, 
                     MAX(HALT.IdLineaTiempo) AS Versionn, 
                     ED.Bucket, 
                     ED.Folder, 
                     UPPER(ED.UUIDAmazon) AS UUIDAmazon, 
                     IE.idInstanciaEntregable, 
                     LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.', ED.NombreArchivo, LEN(ED.NombreArchivo) - 5), LEN(ED.NombreArchivo)))) AS TipoArchivo
        FROM dbo.EN_Entregable E
             JOIN dbo.EN_ContratoEntregable CE ON E.IdEntregable = CE.IdEntregable
                                                  AND CE.IdContrato = @IdContrato
             JOIN dbo.EN_InstanciasEntregable IE ON CE.IdContratoEntregable = IE.IdContratoEntregable
                                                    AND IE.FechaCalculadaEntregaReg BETWEEN DATEADD(MM, -2, GETDATE()) AND GETDATE()
             JOIN dbo.EN_HistorialAprobacionesLineaTiempo HALT ON IE.idInstanciaEntregable = HALT.idInstanciaEntregable
                                                                  AND HALT.Rechazado = 0
             JOIN dbo.EN_DocumentoVersion DE ON HALT.idInstanciaEntregable = DE.idInstanciaEntregable
             JOIN dbo.EN_EntregableDocumento ED ON DE.DocumentoEntregableId = ED.DocumentoEntregableId
                                                   AND ED.idTipoArchivo = 10000
        WHERE E.CONSECUTIVO = 'ADINCO-PLANES174'
              AND LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.', ED.NombreArchivo, LEN(ED.NombreArchivo) - 5), LEN(ED.NombreArchivo)))) LIKE '%xls%'
        GROUP BY IE.FechaCalculadaEntregaReg, 
                 ED.DocumentoEntregableId, 
                 ED.NombreArchivo, 
                 ED.Bucket, 
                 ED.Folder, 
                 UPPER(ED.UUIDAmazon), 
                 IE.idInstanciaEntregable, 
                 LTRIM(RTRIM(SUBSTRING(ED.NombreArchivo, CHARINDEX('.', ED.NombreArchivo, LEN(ED.NombreArchivo) - 5), LEN(ED.NombreArchivo))))
        ORDER BY IE.FechaCalculadaEntregaReg DESC;
        -- =============================================
    END;