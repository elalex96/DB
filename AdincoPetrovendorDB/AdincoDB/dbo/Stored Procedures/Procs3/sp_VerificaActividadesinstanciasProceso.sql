-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20190330
-- Description:	Extrae las actividades del proceso que selecciono
-- =============================================
CREATE PROCEDURE [dbo].[sp_VerificaActividadesinstanciasProceso]--3,10061,10035,10030--SIMULACION 
    @idContrato INT,
    @idUsuario INT,
    @idInstanciaProceso INT
AS
BEGIN
  SELECT IA.idInstanciaActividad,
       A.NombreActividad,
       A.Dias,
       CASE A.DiasNaturales
            WHEN 1 THEN 'Días Naturales'
            WHEN 0 THEN 'Días Habiles' END AS TipoDeDias,
       IA.FechaActividad
  FROM dbo.EN_InstanciasActividades IA
  JOIN dbo.EN_InstanciasProcesosFecha IP
    ON IP.IdInstanciasProcesos = IA.IdInstanciasProcesos
  JOIN dbo.EN_Actividades A
    ON A.IdActividad           = IA.IdActividad
 WHERE IA.IdInstanciasProcesos = @idInstanciaProceso;
END;