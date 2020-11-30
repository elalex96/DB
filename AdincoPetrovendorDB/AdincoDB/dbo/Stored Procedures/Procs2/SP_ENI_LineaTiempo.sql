-- =============================================
-- Author:		Manuel Cruz
-- Create date: 13-05-2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_ENI_LineaTiempo] 
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT DISTINCT 
                IE.idInstanciaEntregable AS idInstanciaEntregable, 
                CAST(IE.FechaCalculadaEntregaReg AS DATE) AS FechaEntrega, 
                E.DocumentoEntregable, 
                YEAR(CAST(IE.FechaCalculadaEntregaReg AS DATE)) AS Anio 
         --SELECT *
         FROM dbo.EN_ContratoEntregable CE
              JOIN dbo.EN_Entregable E ON CE.IdEntregable = E.IdEntregable
				AND E.BITJOA = 0
              JOIN dbo.EN_InstanciasEntregable IE ON CE.IdContratoEntregable = IE.IdContratoEntregable
              JOIN EN_Actividad A ON IE.ActividadID = A.ActividadID
                                     AND A.EstadoID = 10003	--Aprobado Internamente    
              LEFT JOIN dbo.EN_HistorialAprobacionesLineaTiempo HALT ON IE.idInstanciaEntregable = HALT.idInstanciaEntregable
                                                                        AND HALT.Rechazado = 0
              LEFT JOIN dbo.EN_DocumentoVersion DE ON HALT.idInstanciaEntregable = DE.idInstanciaEntregable
              LEFT JOIN dbo.EN_EntregableDocumento ED ON DE.DocumentoEntregableId = ED.DocumentoEntregableId
                                                         AND ED.idTipoArchivo = 10000
                                                         AND ED.Activo = 1
              LEFT JOIN dbo.EN_MarcoLegal ML ON E.IdMarcoLegal = ML.IdMarcoLegal
              LEFT JOIN dbo.EN_FrecuenciaEntregable F ON E.IdFrecuenciaEntregable = F.IdFrecuenciaEntregable
              LEFT JOIN dbo.CO_Regulador R ON E.IdRegulador = R.IdRegulador
         WHERE CE.IdContrato = @IdContrato
               AND CE.BitMostrarLineaTiempo = 1
         ORDER BY Anio, 
                  CAST(IE.FechaCalculadaEntregaReg AS DATE);
     END;