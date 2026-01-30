USE [Petrovendor]
GO
DROP PROC IF EXISTS [SP_ValidarUsuarioAprobador]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================  
-- Author:  Daniel AC   
-- Create date: 30/01/2026  
-- Description: Validar si el usuario actual es aprobador de una aprobación
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_ValidarUsuarioAprobador]
@IdUsuario INT,
@IdOperacion INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @TipoFlujoAprobacion INT;
    DECLARE @IdFlujoAprobacion INT;
    DECLARE @IdEstatusUsuarioAnteriorSecuencia INT;
    DECLARE @NoSecuenciaUsuarioActual INT;
    DECLARE @NoSecuenciaAprobadorAnterior INT;

	SELECT @IdFlujoAprobacion = IdFlujoTarea
    FROM TA_Operacion
    WHERE IdOperacion = @IdOperacion;

    SELECT @TipoFlujoAprobacion = IdTipoFlujo
    FROM TA_FlujoTarea (NOLOCK)
    WHERE IdFlujoTarea = @IdFlujoAprobacion;

	 IF @TipoFlujoAprobacion = 1 --> ES FLUJO SERIAL  
    BEGIN

        ---OBTENER EL NUMERO DE SECUENCIA DEL USUARIO ACTUAL SI ES APROBADOR DEL FLUJO SERIAL  
        SELECT @NoSecuenciaUsuarioActual = TT.NoSecuencia
        FROM TA_Operacion O
            JOIN TA_Tarea TT
                ON O.IdOperacion = TT.IdOperacion
        WHERE O.IdOperacion = @IdOperacion
              AND TT.IdAprobador = @IdUsuario
              AND TT.Activo = 1;

        ---OBTENER EL ESTATUS DEL APROBADOR ANTERIOR   
        --- ESTO ES PARA BLOQUEAR BOTONES DE APROBACIÓN SI LA APROBACIÓN ES DE TIPO SERIAL  
        SELECT @IdEstatusUsuarioAnteriorSecuencia = TT.IdEstatus,
               @NoSecuenciaAprobadorAnterior = TT.NoSecuencia
        FROM TA_Operacion O
            JOIN TA_Tarea TT
                ON O.IdOperacion = TT.IdOperacion
        WHERE O.IdOperacion = @IdOperacion
              AND TT.NoSecuencia = (ISNULL(@NoSecuenciaUsuarioActual, 0) - 1)
              AND TT.Activo = 1;

    END;

	 SELECT 'ES_APROBADOR',
     TT.IdEstatus,
     TT.NoSecuencia,                                                       
     @TipoFlujoAprobacion AS TipoFlujoAprobacion,                         
     ISNULL(@IdEstatusUsuarioAnteriorSecuencia, 0) AS IdEstatusAnterior,   
     ISNULL(@NoSecuenciaAprobadorAnterior, 0) AS NoSecuenciaAnterior     
	 FROM  TA_Operacion  O 
	 JOIN TA_Tarea TT 
        ON O.IdOperacion =TT.IdOperacion
	 WHERE O.IdOperacion= @IdOperacion 
     AND TT.IdAprobador=@IdUsuario
     AND TT.Activo = 1;


END
