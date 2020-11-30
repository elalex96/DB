-- =============================================
-- Author:		Manuel CD
-- Create date: 23-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_AA_ReportesCagados] --10010,'01/09/2017'
    -- Add the parameters for the stored procedure here
    -- SP_PC_ExcelesCagados 10010,'01/09/2017'
@IdContrato INT,
@MesReporte NVARCHAR(50),
@IdUsuario  INT
AS
         BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
             SET NOCOUNT ON;
             SET LANGUAGE Spanish;
    -- Insert statements for procedure here
             DECLARE @IdContratista INT;
             SELECT @IdContratista = CC.IdContratista
             FROM CO_Contratista CC
                  JOIN CO_Contrato C ON CC.IdContratista = C.IdContratista
             WHERE C.IdContrato = @IdContrato;

    /**/

             CREATE TABLE #TablaTemp
(IdReporteCargado INT,
 NombreArchivo    NVARCHAR(MAX),
 FechaReporte     DATETIME,
 NombreReporte    NVARCHAR(MAX),
 Nombre           NVARCHAR(MAX),
 Cargado          BIT,
 IdTipoReporte    INT,
 IdContrato       INT,
 FechaCarga       DATETIME
);
             INSERT INTO #TablaTemp
                    SELECT DISTINCT
                           RC.IdReporteCargado,
                           RC.NombreArchivo AS 'Nombre del archivo',
                           CONVERT(VARCHAR(11), RC.FechaReporte, 103) AS 'Mes del reporte',
                           AA.NombreReporte AS 'Nombre del reporte',
                           U.Nombre AS 'Cargado por',
                           CASE
                               WHEN RC.ReporteArchivo IS NULL
                               THEN 0
                               ELSE 1
                           END AS Cargado,
                           AA.IdTipoReporte,
                           RC.IdContrato,
                           RC.CreadoEn
                    FROM AA_TipoReporte AS AA
                         LEFT OUTER JOIN AA_ReportesCargados AS RC ON RC.IdTipoReporte = AA.IdTipoReporte
        --AND EP.IdContrato = @IdContrato
        --AND CONVERT(VARCHAR(11), RC.FechaReporte, 103) = @MesReporte
                         LEFT OUTER JOIN AP_Usuario AS U ON RC.CreadoPor = U.UsuarioID
                         LEFT OUTER JOIN CO_Contrato C ON RC.IdContrato = C.IdContrato
                         LEFT OUTER JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista --@IdContratista;
                    WHERE CC.IdContratista = @IdContratista
						AND AA.CountColumnas IS NOT NULL
                          AND CONVERT(VARCHAR(11), RC.FechaReporte, 103) = @MesReporte;
            
/****/

             SELECT TT.IdReporteCargado,
                    TT.NombreArchivo AS 'Nombre del archivo',
                    CONVERT(VARCHAR(11), TT.FechaReporte, 103) AS 'Mes del reporte',
                    TEP.NombreReporte AS 'Nombre del reporte',
                    TT.Nombre AS 'Cargado por',
                    CASE
                        WHEN TT.Cargado IS NULL
                        THEN 0
                        ELSE 1
                    END AS Cargado,
                    TT.IdTipoReporte,
                    TT.IdContrato,
                    TT.FechaCarga
             FROM #TablaTemp TT
                  RIGHT JOIN dbo.AA_TipoReporte TEP 
				  ON TT.IdTipoReporte = TEP.IdTipoReporte
			WHERE TEP.CountColumnas IS NOT NULL
			ORDER BY TEP.NombreReporte;
--[SP_AA_ReportesCagados] 10010,'01/10/2017',1
         END;

