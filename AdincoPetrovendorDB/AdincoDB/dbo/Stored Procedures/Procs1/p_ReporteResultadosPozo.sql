IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_ReporteResultadosPozo'
)
    DROP PROCEDURE p_ReporteResultadosPozo
GO
 
CREATE proc [dbo].[p_ReporteResultadosPozo]  
@pIdContrato int,  
@pIdPozo int,  
@pMes date,  
@pIdusuario int  
as  
 BEGIN
	
 SET LANGUAGE Spanish
 DECLARE @nombrePozo VARCHAR(1000)
  
 SELECT @nombrePozo = isnull(Nombre,'') FROM PR_pozo (NOLOCK) 
 WHERE Id = @pIdPozo  
 

  SELECT @nombrePozo AS NombrePozo, CONCAT(DATENAME(MONTH, @pMes), ' ', YEAR(@pMes)) AS Mes
 
 END  