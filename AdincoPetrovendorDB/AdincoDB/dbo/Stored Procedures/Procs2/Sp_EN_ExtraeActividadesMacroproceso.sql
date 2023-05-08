-- ============================================= 
-- Author:    Reyna Olvera 
-- Create date: 20191030 
-- ============================================= 
CREATE	PROCEDURE [dbo].[Sp_EN_ExtraeActividadesMacroproceso]--3,10061,12142 
  @IdContrato     INT, 
  @IdUsuario      INT, 
  @IdMacroproceso INT 
AS 
  BEGIN 
      SET nocount ON; 

      DECLARE @procesos TABLE 
        ( 
           idproceso INT,orden int
        ); 

      INSERT INTO @procesos 
                  (idproceso,orden) 
      SELECT idprocesohijo,orden
      FROM   en_macroprocesosrelacion 
      WHERE  idmacroproceso = @idMacroproceso  AND IdprocesoOriginal IS NULL

      SELECT PA.idproceso, 
             PA.idactividad, 
           Isnull( Ltrim(PG.orden),'' )+'-'+ P.nombreproceso as nombreproceso, 
             A.nombreactividad, 
             A.dias, 
             CASE diasnaturales 
               WHEN 1 THEN 'Días naturales' 
               WHEN 0 THEN 'Días Habiles' 
             END AS DiasNaturales, 
             PA.bitiniciasigproceso, 
             PA.orden,
			 PG.orden as OrdenProcesos
      FROM   [en_procesosactividades] PA 
             JOIN @procesos PG 
               ON PA.idproceso = PG.idproceso 
             JOIN en_procesos P 
               ON PA.idproceso = P.idproceso 
             JOIN en_actividades A 
               ON PA.idactividad = A.idactividad 
	 WHERE 
			PA.orden is not null
			AND PA.Activo	=	1
			AND PA.Orden	>=	0
      ORDER  BY PG.orden, PA.Orden; 
  END; 


