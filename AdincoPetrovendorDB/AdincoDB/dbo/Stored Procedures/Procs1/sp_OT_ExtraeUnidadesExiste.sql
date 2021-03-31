use adinco;
GO
CREATE PROCEDURE sp_OT_ExtraeUnidadesExiste
 @IdContrato INT,
 @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

		SELECT  DISTINCT Unidad
        FROM Petrovendor..PV_MM_MaterialUnidad
        WHERE	IsActivo = 1
		ORDER BY Unidad ASC

END;


