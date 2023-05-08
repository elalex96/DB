-- =============================================
-- Author:  Reyna Olvera
-- Create date: 12/01/2018
-- Description: Extrae las actividades
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeActividadesProceso] --10010,10061,10011
    @idContrato INT,
    @idUsuario INT,
    @idProceso INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT A.IdActividad AS IdActividad,
           NombreActividad,
           Dias,
           CASE DiasNaturales
               WHEN 0 THEN
      
             'Habiles'
               ELSE
                   'Naturales'
           END AS Tipodias,
           (Orden+1) AS Orden ,
           COUNT(AE.IdEntregable) AS CantEntreg
    FROM EN_Actividades A
    JOIN EN_ProcesosActividades p ON A.IdActividad = p.idActividad
    LEFT JOIN dbo.EN_ActividadesEntregables AE 
        ON A.IdActividad = AE.IdActividad
        AND AE.Activo = 1
    WHERE p.IdProceso = @idProceso 
		AND IdContrato=@idContrato
        AND p.Activo = 1
		AND A.Activo = 1
		AND P.ORDEN	>=0
    GROUP BY A.IdActividad,
             NombreActividad,
             Dias,
             DiasNaturales,
             Orden
    ORDER BY Orden ASC;
END;
