-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los aprobadores de un flujo de tarea			
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 23/01/2018
-- Description:	se toma los participantes de aprobadores dentro del grid	
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarFlujoTareaAprobadoresGridSolPed]
    @IdProveedor INT,
    @IdFlujoAprobacion INT,
    @IdTipoOperacion INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT AP.IdAprobador,
           U.Nombre AS Aprobador,
           U.Correo,
           AP.NoSecuencia,
           FT.IdFlujoTarea
    FROM TA_FlujoTarea AS FT
        INNER JOIN TA_TipoOperacion AS OPE
            ON OPE.IdTipoOperacion = FT.IdTipoOperacion
        INNER JOIN TA_TipoFlujoTarea AS TF
            ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
        INNER JOIN TA_Aprobador AS AP
            ON AP.IdFlujoTarea = FT.IdFlujoTarea
        INNER JOIN S_Usuario AS U
            ON U.IdUsuario = AP.IdUsuario
    WHERE OPE.IdTipoOperacion = @IdTipoOperacion
          AND (
                  FT.Eliminado = 0
                  OR FT.Eliminado IS NULL
              )
          AND FT.IdProveedor = @IdProveedor
          AND FT.[IdFlujoTarea] = @IdFlujoAprobacion

END

