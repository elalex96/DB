-- =============================================
-- Author:	Reyna Olvera
-- Create date: 12/01/2018
-- Description:	Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_VerificaActividades] --3,10061,11118,12124--10010,10061,10011
    @idContrato INT,
    @idUsuario INT,
    @idActividad INT,
    @idProceso INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT   
	TOP 1 ISNULL(MAX (IE.idInstanciaEntregable),0)
	--SELECT*
      FROM      EN_ProcesosActividades p
      JOIN      EN_Actividades A
        ON p.idActividad           = A.IdActividad
      JOIN      EN_ActividadesEntregables AE
        ON A.IdActividad           = AE.IdActividad
      LEFT JOIN EN_InstanciasActividades IA
        ON A.IdActividad           = IA.IdActividad
      LEFT JOIN EN_ContratoEntregable CE
        ON AE.IdEntregable         = CE.IdEntregable
       AND CE.IdContrato           = @idContrato
      LEFT JOIN dbo.EN_InstanciasEntregable IE
        ON CE.IdContratoEntregable = IE.IdContratoEntregable
     WHERE      p.IdProceso = @idProceso
       AND      p.IdContrato     =@idContrato
       AND      p.idActividad    = @idActividad
	   AND IA.idInstanciaActividad IS NOT NULL
    
END;

