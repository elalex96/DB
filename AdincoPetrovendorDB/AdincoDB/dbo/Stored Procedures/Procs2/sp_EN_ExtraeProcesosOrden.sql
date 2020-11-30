-- =============================================
-- Author:		Reyna Olvera
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeProcesosOrden] --3,10061
    @idContrato INT,
    @idUsuario INT,
    @IdMacroProceso INT
AS
BEGIN

    SET NOCOUNT ON;
    SELECT 
		   idProcesoHijo,
           NombreProceso as Proceso,
           Descripcion,
           Orden--,*
    FROM EN_MacroProcesosRelacion mpr
		JOIN EN_procesos p on mpr.idProcesoHijo=p.IdProceso and IdprocesoOriginal is null
    WHERE idMacroProceso = @IdMacroProceso;

END;

