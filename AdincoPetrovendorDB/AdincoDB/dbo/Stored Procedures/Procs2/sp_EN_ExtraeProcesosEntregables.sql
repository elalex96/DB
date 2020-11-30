-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20191029
-- Description:	Guarda relacion de procesos entregables
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeProcesosEntregables]
    @IdContrato INT,
    @IdUsuario INT,
	@IdEntregable int
AS
BEGIN

SELECT CP.IdCatProceso,
       CP.Nombre,
       CP.Descripcion,
       CASE
           WHEN CPE.IdCatProceso IS NOT NULL THEN
               1
           ELSE
               0
       END AS Seleccionado,
	   Clave,
	   IsNull(BitPrincipal,0) as BitPrincipal
FROM EN_CatalogoProcesos CP
    LEFT JOIN EN_CatalogoProcesosEntregables CPE
        ON CP.IdCatProceso = CPE.IdCatProceso
           AND CPE.IdEntregable = @IdEntregable;

END

